import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';

import '../../features/booking/draft.dart';
import '../../features/booking/places.dart';
import '../datasources/places_remote_datasource.dart';

class PlacesRepository implements PlaceLookup {
  PlacesRepository(this._remote);

  final PlacesRemoteDataSource _remote;

  @override
  Future<List<PlaceSuggestion>> autocomplete({
    required String query,
    required String session,
    CancelToken? cancelToken,
  }) async {
    final rows = await _remote.autocomplete(
      query: query,
      session: session,
      cancelToken: cancelToken,
    );
    if (rows is! List) return const [];
    return rows.map(PlaceSuggestion.tryParse).whereType<PlaceSuggestion>().toList();
  }

  @override
  Future<PlaceDetails?> details({
    required String placeId,
    required String session,
  }) async {
    return PlaceDetails.tryParse(
      await _remote.details(placeId: placeId, session: session),
    );
  }

  @override
  Future<PlaceStop?> reverse({required double lat, required double lng}) async {
    final json = jsonMap(await _remote.reverse(lat: lat, lng: lng));
    final address = json?['address'];
    if (address is! String || address.isEmpty) return null;
    return PlaceStop(address: address, lat: lat, lng: lng);
  }
}
