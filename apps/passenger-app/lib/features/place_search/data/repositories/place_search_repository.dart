import 'dart:async';
import '../models/lethbridge_place.dart';

abstract class PlaceSearchRepository {
  Future<List<LethbridgePlace>> searchPlaces(String query);
  Future<List<LethbridgePlace>> getRecentPlaces();
  Future<List<LethbridgePlace>> getPopularLandmarks();
}

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  final bool simulateOffline;

  PlaceSearchRepositoryImpl({this.simulateOffline = false});

  @override
  Future<List<LethbridgePlace>> searchPlaces(String query) async {
    if (simulateOffline) {
      throw TimeoutException('Unable to reach Lethbridge places server');
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 150));

    // Specific query matching
    if (trimmed.contains('xyz99') || trimmed.contains('nonexistent')) {
      return const [];
    }

    if (trimmed.contains('park')) {
      return LethbridgePlace.parkPlaceResults;
    }

    if (trimmed.contains('uleth') || trimmed.contains('univ')) {
      return [LethbridgePlace.popularLandmarks[0]];
    }

    if (trimmed.contains('enmax')) {
      return [LethbridgePlace.popularLandmarks[2]];
    }

    // Default search filtering
    return LethbridgePlace.parkPlaceResults
        .where((p) =>
            p.title.toLowerCase().contains(trimmed) ||
            p.subtitle.toLowerCase().contains(trimmed))
        .toList();
  }

  @override
  Future<List<LethbridgePlace>> getRecentPlaces() async {
    return LethbridgePlace.parkPlaceResults.take(2).toList();
  }

  @override
  Future<List<LethbridgePlace>> getPopularLandmarks() async {
    return LethbridgePlace.popularLandmarks;
  }
}
