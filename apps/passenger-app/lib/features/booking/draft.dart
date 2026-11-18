import 'dart:convert';
import 'dart:math';

import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingDraftProvider =
    NotifierProvider<BookingDraftController, BookingDraft>(
      BookingDraftController.new,
    );

class PlaceStop {
  const PlaceStop({
    required this.address,
    required this.lat,
    required this.lng,
    this.placeId,
  });

  final String address;
  final double lat;
  final double lng;
  final String? placeId;

  Map<String, dynamic> toStopJson() => {
    'address': address,
    'lat': lat,
    'lng': lng,
    if (placeId != null) 'placeId': placeId,
  };
}

class QuoteOption {
  const QuoteOption({
    required this.vehicleTypeId,
    required this.name,
    required this.subtotalCents,
    required this.taxCents,
    required this.totalCents,
    required this.quoteToken,
    required this.expiresAt,
    this.etaMinutes,
  });

  final String vehicleTypeId;
  final String name;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final String quoteToken;
  final DateTime expiresAt;
  final int? etaMinutes;

  static QuoteOption? tryParse(Object? data) {
    final json = jsonMap(data);
    if (json == null) return null;
    final vehicleTypeId = json['vehicleTypeId'];
    final name = json['name'];
    final subtotalCents = json['subtotalCents'];
    final taxCents = json['taxCents'];
    final totalCents = json['totalCents'];
    final quoteToken = json['quoteToken'];
    final expiresAt = json['expiresAt'];
    if (vehicleTypeId is! String ||
        name is! String ||
        subtotalCents is! int ||
        taxCents is! int ||
        totalCents is! int ||
        quoteToken is! String ||
        expiresAt is! String) {
      return null;
    }
    final parsedExpiry = DateTime.tryParse(expiresAt);
    if (parsedExpiry == null) return null;
    final eta = json['etaMinutes'];
    return QuoteOption(
      vehicleTypeId: vehicleTypeId,
      name: name,
      subtotalCents: subtotalCents,
      taxCents: taxCents,
      totalCents: totalCents,
      quoteToken: quoteToken,
      expiresAt: parsedExpiry,
      etaMinutes: eta is int ? eta : null,
    );
  }
}

class FareQuotes {
  const FareQuotes({
    required this.distanceM,
    required this.durationS,
    required this.source,
    required this.zone,
    required this.options,
    this.priceChanged = false,
  });

  final int distanceM;
  final int durationS;
  final String source;
  final String zone;
  final List<QuoteOption> options;
  final bool priceChanged;

  static FareQuotes? tryParse(Object? data, {bool priceChanged = false}) {
    final json = jsonMap(data);
    if (json == null) return null;
    final distanceM = json['distanceM'];
    final durationS = json['durationS'];
    final source = json['source'];
    final zone = json['zone'];
    final raw = json['options'];
    if (distanceM is! int ||
        durationS is! int ||
        source is! String ||
        zone is! String ||
        raw is! List) {
      return null;
    }
    final options = <QuoteOption>[];
    for (final row in raw) {
      final option = QuoteOption.tryParse(row);
      if (option != null) options.add(option);
    }
    return FareQuotes(
      distanceM: distanceM,
      durationS: durationS,
      source: source,
      zone: zone,
      options: options,
      priceChanged: priceChanged,
    );
  }

  QuoteOption? optionFor(String vehicleTypeId) {
    for (final option in options) {
      if (option.vehicleTypeId == vehicleTypeId) return option;
    }
    return null;
  }
}

class BookingDraft {
  const BookingDraft({
    this.pickup,
    this.dropoff,
    this.quotes,
    this.chosen,
    this.idemKey,
    this.idemHash,
    this.pickupNeedsSearch = false,
    this.locatingPickup = false,
  });

  final PlaceStop? pickup;
  final PlaceStop? dropoff;
  final FareQuotes? quotes;
  final QuoteOption? chosen;
  final String? idemKey;
  final String? idemHash;
  final bool pickupNeedsSearch;
  final bool locatingPickup;

  bool get canQuote => pickup != null && dropoff != null;

  bool get canConfirm =>
      pickup != null && dropoff != null && chosen != null && quotes != null;

  BookingDraft copyWith({
    PlaceStop? pickup,
    PlaceStop? dropoff,
    FareQuotes? quotes,
    QuoteOption? chosen,
    String? idemKey,
    String? idemHash,
    bool? pickupNeedsSearch,
    bool? locatingPickup,
    bool clearChosen = false,
    bool clearQuotes = false,
    bool clearIdem = false,
  }) {
    return BookingDraft(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      quotes: clearQuotes ? null : (quotes ?? this.quotes),
      chosen: clearChosen ? null : (chosen ?? this.chosen),
      idemKey: clearIdem ? null : (idemKey ?? this.idemKey),
      idemHash: clearIdem ? null : (idemHash ?? this.idemHash),
      pickupNeedsSearch: pickupNeedsSearch ?? this.pickupNeedsSearch,
      locatingPickup: locatingPickup ?? this.locatingPickup,
    );
  }
}

class BookingDraftController extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft();

  void setPickup(PlaceStop? pickup) {
    state = state.copyWith(
      pickup: pickup,
      pickupNeedsSearch: pickup == null,
      clearQuotes: true,
      clearChosen: true,
      clearIdem: true,
    );
  }

  void setDropoff(PlaceStop? dropoff) {
    state = state.copyWith(
      dropoff: dropoff,
      clearQuotes: true,
      clearChosen: true,
      clearIdem: true,
    );
  }

  void markPickupNeedsSearch() {
    state = state.copyWith(pickupNeedsSearch: true, locatingPickup: false);
  }

  void setLocatingPickup(bool value) {
    state = state.copyWith(locatingPickup: value);
  }

  void choose(QuoteOption option) {
    state = state.copyWith(chosen: option, clearIdem: true);
  }

  void applyQuotes(FareQuotes quotes, {String? keepVehicleTypeId}) {
    final previousTotal = keepVehicleTypeId == null
        ? null
        : state.quotes?.optionFor(keepVehicleTypeId)?.totalCents;
    final nextChosen = keepVehicleTypeId == null
        ? null
        : quotes.optionFor(keepVehicleTypeId);
    final priceChanged =
        previousTotal != null &&
        nextChosen != null &&
        previousTotal != nextChosen.totalCents;
    state = state.copyWith(
      quotes: FareQuotes(
        distanceM: quotes.distanceM,
        durationS: quotes.durationS,
        source: quotes.source,
        zone: quotes.zone,
        options: quotes.options,
        priceChanged: priceChanged || quotes.priceChanged,
      ),
      chosen: nextChosen,
      clearChosen: nextChosen == null,
      clearIdem: true,
    );
  }

  void reset() {
    state = const BookingDraft();
  }

  Map<String, dynamic>? createPayload({
    String paymentMethod = 'CASH',
    String? paymentMethodId,
  }) {
    final pickup = state.pickup;
    final dropoff = state.dropoff;
    final chosen = state.chosen;
    final quotes = state.quotes;
    if (pickup == null || dropoff == null || chosen == null || quotes == null) {
      return null;
    }
    return {
      'vehicleTypeId': chosen.vehicleTypeId,
      'zone': quotes.zone,
      'quoteToken': chosen.quoteToken,
      'paymentMethod': paymentMethod,
      if (paymentMethod == 'CARD' && paymentMethodId != null)
        'paymentMethodId': paymentMethodId,
      'stops': [pickup.toStopJson(), dropoff.toStopJson()],
    };
  }

  /// Reuse the key on retry; mint a new one when the payload changes.
  String idempotencyKeyFor(Map<String, dynamic> payload) {
    final hash = jsonEncode(payload);
    if (state.idemKey != null && state.idemHash == hash) {
      return state.idemKey!;
    }
    final key = _newKey();
    state = state.copyWith(idemKey: key, idemHash: hash);
    return key;
  }
}

String _newKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
