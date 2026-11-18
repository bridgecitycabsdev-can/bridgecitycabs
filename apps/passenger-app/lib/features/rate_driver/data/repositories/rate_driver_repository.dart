import 'dart:async';
import '../../../../data/datasources/rating_remote_datasource.dart';
import '../../../../data/datasources/support_remote_datasource.dart';

abstract class RateDriverRepository {
  Future<void> submitReview({
    required String tripId,
    required int rating,
    required List<String> tagIds,
    required String comment,
  });

  Future<void> reportTripIssue({
    required String tripId,
    required String reason,
  });
}

class MockRateDriverRepository implements RateDriverRepository {
  final Duration delay;
  final bool shouldFail;

  MockRateDriverRepository({
    this.delay = const Duration(milliseconds: 600),
    this.shouldFail = false,
  });

  @override
  Future<void> submitReview({
    required String tripId,
    required int rating,
    required List<String> tagIds,
    required String comment,
  }) async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception('Failed to synchronize rating with Bridge City dispatch.');
    }
  }

  @override
  Future<void> reportTripIssue({
    required String tripId,
    required String reason,
  }) async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception('Failed to submit trip issue.');
    }
  }
}

class ApiRateDriverRepository implements RateDriverRepository {
  ApiRateDriverRepository(this._ratings, this._support);

  final RatingRemoteDataSource _ratings;
  final SupportRemoteDataSource _support;

  @override
  Future<void> submitReview({
    required String tripId,
    required int rating,
    required List<String> tagIds,
    required String comment,
  }) async {
    final notes = [
      comment.trim(),
      if (tagIds.isNotEmpty) tagIds.join(', '),
    ].where((part) => part.isNotEmpty).join('\n');
    await _ratings.rateDriver(
      bookingId: tripId,
      stars: rating,
      comment: notes,
    );
  }

  @override
  Future<void> reportTripIssue({
    required String tripId,
    required String reason,
  }) async {
    await _support.create({
      'subject': 'Trip issue',
      'category': 'COMPLAINT',
      'body': reason,
      'bookingId': tripId,
    });
  }
}
