import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/performance_data.dart';
import '../models/injury.dart';
import '../models/career.dart';
import '../models/financial.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _performance => _firestore.collection('performance');
  CollectionReference get _injuries => _firestore.collection('injuries');
  CollectionReference get _careers => _firestore.collection('careers');
  CollectionReference get _financials => _firestore.collection('financials');

  // User Operations
  Stream<UserModel> getUserStream(String userId) {
    return _users.doc(userId).snapshots().map((doc) => 
      UserModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
    );
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _users.doc(user.id).update(user.toJson()..remove('id'));
    } catch (e) {
      throw _handleFirebaseError('Failed to update user', e);
    }
  }

  // Performance Operations
  Stream<List<PerformanceData>> getPerformanceStream(String userId) {
    return _performance
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PerformanceData.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList());
  }

  Future<void> addPerformanceData(PerformanceData data) async {
    try {
      await _performance.add(data.toJson()..remove('id'));
    } catch (e) {
      throw _handleFirebaseError('Failed to add performance data', e);
    }
  }

  Future<void> updatePerformanceData(PerformanceData data) async {
    try {
      await _performance.doc(data.id).update(data.toJson()..remove('id'));
    } catch (e) {
      throw _handleFirebaseError('Failed to update performance data', e);
    }
  }

  // Injury Operations
  Stream<List<Injury>> getInjuriesStream(String userId) {
    return _injuries
        .where('userId', isEqualTo: userId)
        .orderBy('dateOccurred', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Injury.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList());
  }

  Future<void> addInjury(Injury injury) async {
    try {
      await _injuries.add(injury.toJson()..remove('id'));
    } catch (e) {
      throw _handleFirebaseError('Failed to add injury', e);
    }
  }

  Future<void> updateInjury(Injury injury) async {
    try {
      await _injuries.doc(injury.id).update(injury.toJson()..remove('id'));
    } catch (e) {
      throw _handleFirebaseError('Failed to update injury', e);
    }
  }

  // Career Operations
  Stream<Career?> getCareerStream(String userId) {
    return _careers.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Career.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    });
  }

  Future<void> updateCareer(Career career) async {
    try {
      await _careers.doc(career.id).set(
        career.toJson()..remove('id'),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw _handleFirebaseError('Failed to update career', e);
    }
  }

  // Financial Operations
  Stream<Financial?> getFinancialStream(String userId) {
    return _financials.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Financial.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    });
  }

  Future<void> updateFinancial(Financial financial) async {
    try {
      await _financials.doc(financial.id).set(
        financial.toJson()..remove('id'),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw _handleFirebaseError('Failed to update financial data', e);
    }
  }

  // Batch Operations
  Future<void> batchUpdate({
    UserModel? user,
    PerformanceData? performance,
    Injury? injury,
    Career? career,
    Financial? financial,
  }) async {
    try {
      final batch = _firestore.batch();

      if (user != null) {
        batch.update(_users.doc(user.id), user.toJson()..remove('id'));
      }

      if (performance != null) {
        batch.update(_performance.doc(performance.id), 
          performance.toJson()..remove('id'));
      }

      if (injury != null) {
        batch.update(_injuries.doc(injury.id), injury.toJson()..remove('id'));
      }

      if (career != null) {
        batch.update(_careers.doc(career.id), career.toJson()..remove('id'));
      }

      if (financial != null) {
        batch.update(_financials.doc(financial.id), 
          financial.toJson()..remove('id'));
      }

      await batch.commit();
    } catch (e) {
      throw _handleFirebaseError('Failed to perform batch update', e);
    }
  }

  // Query Operations
  Future<List<UserModel>> queryUsers({
    String? sport,
    int? minAge,
    int? maxAge,
    String? gender,
  }) async {
    try {
      Query query = _users;

      if (sport != null) {
        query = query.where('sport', isEqualTo: sport);
      }
      if (minAge != null) {
        query = query.where('age', isGreaterThanOrEqualTo: minAge);
      }
      if (maxAge != null) {
        query = query.where('age', isLessThanOrEqualTo: maxAge);
      }
      if (gender != null) {
        query = query.where('gender', isEqualTo: gender);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => UserModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })).toList();
    } catch (e) {
      throw _handleFirebaseError('Failed to query users', e);
    }
  }

  // Error Handling
  Exception _handleFirebaseError(String message, dynamic error) {
    if (error is FirebaseException) {
      return Exception('$message: ${error.message}');
    }
    return Exception('$message: ${error.toString()}');
  }

  // Cleanup
  Future<void> deleteUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_users.doc(userId));

      // Delete performance data
      final performanceDocs = await _performance
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in performanceDocs.docs) {
        batch.delete(doc.reference);
      }

      // Delete injuries
      final injuryDocs = await _injuries
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in injuryDocs.docs) {
        batch.delete(doc.reference);
      }

      // Delete career
      batch.delete(_careers.doc(userId));

      // Delete financial
      batch.delete(_financials.doc(userId));

      await batch.commit();
    } catch (e) {
      throw _handleFirebaseError('Failed to delete user data', e);
    }
  }
}