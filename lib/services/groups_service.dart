import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';

class GroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== GROUPS ==========

  // Get all public groups
  Future<List<Group>> fetchPublicGroups() async {
    print('DEBUG: Buscando grupos públicos');
    
    final snapshot = await _firestore
        .collection('groups')
        .where('is_public', isEqualTo: true)
        .get();

    print('DEBUG: Encontrados ${snapshot.docs.length} grupos públicos');

    // Ordenar no código para evitar necessidade de índice composto
    final groups = snapshot.docs.map((doc) {
      print('DEBUG: Grupo público data: ${doc.data()}');
      try {
        final group = Group.fromMap(doc.data()..['id'] = doc.id);
        print('DEBUG: Grupo público criado: ${group.name}');
        return group;
      } catch (e) {
        print('DEBUG: Erro ao criar grupo público: $e');
        rethrow;
      }
    }).toList();
    
    groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    print('DEBUG: Total de grupos públicos retornados: ${groups.length}');
    return groups;
  }

  // Get group by ID
  Future<Group?> fetchGroupById(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();

    if (!doc.exists) return null;
    return Group.fromMap(doc.data()!..['id'] = doc.id);
  }

  // Get user's groups
  Future<List<Group>> fetchUserGroups(String userId) async {
    print('DEBUG: Buscando grupos para userId: $userId');
    
    // Buscar onde o usuário é membro
    final memberSnapshot = await _firestore
        .collection('group_members')
        .where('userId', isEqualTo: userId)
        .get();

    print('DEBUG: Encontrados ${memberSnapshot.docs.length} registros em group_members');
    
    if (memberSnapshot.docs.isEmpty) {
      print('DEBUG: Nenhum registro encontrado em group_members');
      return [];
    }

    final groupIds = memberSnapshot.docs.map((doc) {
      print('DEBUG: Doc data: ${doc.data()}');
      return doc['groupId'] as String;
    }).toList();

    print('DEBUG: GroupIds encontrados: $groupIds');

    if (groupIds.isEmpty) return [];

    // Dividir em chunks de 10 para garantir
    List<Group> userGroups = [];
    for (var i = 0; i < groupIds.length; i += 10) {
      final end = (i + 10 < groupIds.length) ? i + 10 : groupIds.length;
      final chunk = groupIds.sublist(i, end);
      
      print('DEBUG: Buscando grupos com IDs: $chunk');
      
      final groupSnapshot = await _firestore
          .collection('groups')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      
      print('DEBUG: Encontrados ${groupSnapshot.docs.length} grupos');
      
      for (var doc in groupSnapshot.docs) {
        print('DEBUG: Grupo data: ${doc.data()}');
        try {
          final group = Group.fromMap(doc.data()..['id'] = doc.id);
          userGroups.add(group);
          print('DEBUG: Grupo adicionado: ${group.name}');
        } catch (e) {
          print('DEBUG: Erro ao criar Group: $e');
        }
      }
    }
    
    // Ordenar manualmente já que fizemos queries separadas
    userGroups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    print('DEBUG: Total de grupos retornados: ${userGroups.length}');
    return userGroups;
  }

  // Create group
  Future<String> createGroup({
    required String name,
    String? description,
    required String type,
    String? imageUrl,
    required String createdBy,
    bool isPublic = true,
  }) async {
    final docRef = await _firestore.collection('groups').add({
      'name': name,
      'description': description,
      'type': type,
      'image_url': imageUrl,
      'created_by': createdBy,
      'members_count': 1, // Criador já é membro
      'exercises_count': 0,
      'is_public': isPublic,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Adicionar criador como admin
    await _firestore.collection('group_members').doc('${docRef.id}_$createdBy').set({
      'groupId': docRef.id,
      'userId': createdBy,
      'role': 'admin',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Join group
  Future<void> joinGroup(String groupId, String userId) async {
    final memberRef = _firestore.collection('group_members').doc('${groupId}_$userId');
    
    await _firestore.runTransaction((transaction) async {
      final memberDoc = await transaction.get(memberRef);
      if (!memberDoc.exists) {
        transaction.set(memberRef, {
          'groupId': groupId,
          'userId': userId,
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
        });

        // Incrementar contador
        transaction.update(_firestore.collection('groups').doc(groupId), {
          'members_count': FieldValue.increment(1),
        });
      }
    });
  }

  // Leave group
  Future<void> leaveGroup(String groupId, String userId) async {
    final memberRef = _firestore.collection('group_members').doc('${groupId}_$userId');

    await _firestore.runTransaction((transaction) async {
      final memberDoc = await transaction.get(memberRef);
      if (memberDoc.exists) {
        transaction.delete(memberRef);

        // Decrementar contador
        transaction.update(_firestore.collection('groups').doc(groupId), {
          'members_count': FieldValue.increment(-1),
        });
        
        // Se for admin e tiver outros membros, promover alguém? (Lógica complexa, ignorar por enquanto no MVP)
      }
    });
  }

  // Fetch group members
  Future<List<Map<String, dynamic>>> fetchGroupMembers(String groupId) async {
    print('DEBUG: Buscando membros do grupo $groupId');
    
    final memberSnapshot = await _firestore
        .collection('group_members')
        .where('groupId', isEqualTo: groupId)
        .get();

    print('DEBUG: Encontrados ${memberSnapshot.docs.length} membros');

    List<Map<String, dynamic>> members = [];

    for (var doc in memberSnapshot.docs) {
      final data = doc.data();
      final userId = data['userId'] as String;
      
      print('DEBUG: Buscando dados do usuário $userId');
      
      // Buscar dados do usuário
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        print('DEBUG: Usuário encontrado: ${userDoc.data()}');
        members.add({
          ...data,
          'users': {'id': userId, ...userDoc.data()!},
          'joined_at': (data['joinedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        });
      } else {
        print('DEBUG: Usuário $userId não encontrado na coleção users');
        // Adicionar membro mesmo sem dados do usuário
        members.add({
          ...data,
          'users': {
            'id': userId,
            'display_name': 'Usuário Desconhecido',
          },
          'joined_at': (data['joinedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        });
      }
    }

    print('DEBUG: Total de membros processados: ${members.length}');
    return members;
  }  // Check if user is member
  Future<bool> isUserMember(String groupId, String userId) async {
    final doc = await _firestore.collection('group_members').doc('${groupId}_$userId').get();
    return doc.exists;
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String groupId, String userId) async {
    final doc = await _firestore.collection('group_members').doc('${groupId}_$userId').get();
    return doc.exists && doc.data()?['role'] == 'admin';
  }

  // Get user role in group
  Future<String?> getUserRole(String groupId, String userId) async {
    final doc = await _firestore.collection('group_members').doc('${groupId}_$userId').get();
    return doc.data()?['role'] as String?;
  }

  // Remove member (admin only)
  Future<void> removeMember(String groupId, String userId) async {
    await leaveGroup(groupId, userId); // Reusa a lógica
  }

  // Update group (admin only)
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? type,
    bool? isPublic,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (type != null) updates['type'] = type;
    if (isPublic != null) updates['is_public'] = isPublic;
    updates['updated_at'] = FieldValue.serverTimestamp();

    await _firestore.collection('groups').doc(groupId).update(updates);
  }

  // Delete group (admin only)
  Future<void> deleteGroup(String groupId) async {
    await _firestore.runTransaction((transaction) async {
      // Deletar membros (pode ser caro se muitos membros, ideal usar Cloud Function)
      // MVP: Deleta apenas o grupo, membros ficam órfãos (ou limpa via Function)
      transaction.delete(_firestore.collection('groups').doc(groupId));
      
      // TODO: Implementar limpeza de membros e exercícios via Cloud Function
    });
  }

  // Share exercise in group
  Future<void> shareExerciseInGroup({
    required String groupId,
    required String exerciseId,
    required String sharedBy,
  }) async {
    final shareRef = _firestore.collection('group_exercises').doc('${groupId}_$exerciseId');
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(shareRef);
      if (!doc.exists) {
        transaction.set(shareRef, {
          'groupId': groupId,
          'exerciseId': exerciseId,
          'sharedBy': sharedBy,
          'sharedAt': FieldValue.serverTimestamp(),
        });

        // Incrementar contador
        transaction.update(_firestore.collection('groups').doc(groupId), {
          'exercises_count': FieldValue.increment(1),
        });
      }
    });
  }

  // Get group exercises
  Future<List<Map<String, dynamic>>> fetchGroupExercises(String groupId) async {
    final snapshot = await _firestore
        .collection('group_exercises')
        .where('groupId', isEqualTo: groupId)
        .get();

    // Precisamos buscar os detalhes dos exercícios
    List<Map<String, dynamic>> results = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final exerciseId = data['exerciseId'] as String;
      
      final exerciseDoc = await _firestore.collection('exercises').doc(exerciseId).get();
      if (exerciseDoc.exists) {
        var exerciseData = exerciseDoc.data()!;
        exerciseData['id'] = exerciseDoc.id;
        
        results.add({
          ...data,
          'exercises': exerciseData,
        });
      }
    }

    // Ordenar no código para evitar necessidade de índice composto
    results.sort((a, b) {
      final aTime = a['sharedAt'] as Timestamp?;
      final bTime = b['sharedAt'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    return results;
  }
}
