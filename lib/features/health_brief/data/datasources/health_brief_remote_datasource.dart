import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/health_brief_model.dart';

/// Health Brief remote data source interface
abstract class HealthBriefRemoteDataSource {
  /// Save health brief to Firestore
  Future<void> saveHealthBrief(HealthBriefModel brief);

  /// Get all health briefs for a user
  Future<List<HealthBriefModel>> getHealthBriefs({
    required String userId,
    int? limit,
  });

  /// Get a specific health brief by ID
  Future<HealthBriefModel> getHealthBriefById(String id);

  /// Delete a health brief
  Future<void> deleteHealthBrief(String id);

  /// Stream of health briefs
  Stream<List<HealthBriefModel>> watchHealthBriefs(String userId);
}

/// Health Brief remote data source implementation
class HealthBriefRemoteDataSourceImpl implements HealthBriefRemoteDataSource {
  final FirebaseFirestore firestore;

  HealthBriefRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(AppConstants.healthBriefsCollection);

  @override
  Future<void> saveHealthBrief(HealthBriefModel brief) async {
    try {
      await _collection.doc(brief.id).set(brief.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to save health brief',
        code: e.code,
      );
    }
  }

  @override
  Future<List<HealthBriefModel>> getHealthBriefs({
    required String userId,
    int? limit,
  }) async {
    try {
      var query = _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => HealthBriefModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: _userFriendlyFirestoreMessage(e),
        code: e.code,
      );
    }
  }

  @override
  Future<HealthBriefModel> getHealthBriefById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw const ServerException(
          message: 'Health brief not found',
          code: 'not-found',
        );
      }
      return HealthBriefModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get health brief',
        code: e.code,
      );
    }
  }

  @override
  Future<void> deleteHealthBrief(String id) async {
    try {
      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to delete health brief',
        code: e.code,
      );
    }
  }

  @override
  Stream<List<HealthBriefModel>> watchHealthBriefs(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthBriefModel.fromFirestore(doc))
            .toList())
        .handleError((error, stackTrace) {
      if (error is FirebaseException) {
        throw ServerException(
          message: _userFriendlyFirestoreMessage(error),
          code: error.code,
        );
      }
      throw error;
    });
  }

  /// Returns a short user-facing message for Firestore errors (e.g. missing index).
  static String _userFriendlyFirestoreMessage(FirebaseException e) {
    final msg = e.message ?? '';
    if (msg.contains('requires an index') || msg.contains('create_composite')) {
      return 'Database is being set up. Please deploy Firestore indexes (see firestore.indexes.json) or try again in a few minutes.';
    }
    return msg.isNotEmpty ? msg : 'Failed to load data.';
  }
}
