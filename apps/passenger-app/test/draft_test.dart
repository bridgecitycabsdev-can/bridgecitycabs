import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/booking/draft.dart';

void main() {
  test('reuses Idempotency-Key until the payload changes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final draft = container.read(bookingDraftProvider.notifier);
    draft.setPickup(
      const PlaceStop(address: 'A', lat: 1, lng: 2, placeId: 'p1'),
    );
    draft.setDropoff(
      const PlaceStop(address: 'B', lat: 3, lng: 4, placeId: 'p2'),
    );
    draft.applyQuotes(
      FareQuotes(
        distanceM: 1000,
        durationS: 120,
        source: 'ROUTES',
        zone: 'INSIDE_TOWN',
        options: [
          QuoteOption(
            vehicleTypeId: 'vt',
            name: 'Sedan',
            subtotalCents: 1000,
            taxCents: 50,
            totalCents: 1050,
            quoteToken: 'tok-1',
            expiresAt: DateTime.utc(2030),
          ),
        ],
      ),
    );
    draft.choose(container.read(bookingDraftProvider).quotes!.options.first);

    final payload = draft.createPayload()!;
    final first = draft.idempotencyKeyFor(payload);
    final second = draft.idempotencyKeyFor(payload);
    expect(second, first);

    draft.choose(
      QuoteOption(
        vehicleTypeId: 'vt',
        name: 'Sedan',
        subtotalCents: 1000,
        taxCents: 50,
        totalCents: 1050,
        quoteToken: 'tok-2',
        expiresAt: DateTime.utc(2030),
      ),
    );
    final changed = draft.createPayload()!;
    final third = draft.idempotencyKeyFor(changed);
    expect(third, isNot(first));
  });

  test('marks quote price changes when a fresh batch replaces the chosen ride', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final draft = container.read(bookingDraftProvider.notifier);
    draft.setPickup(const PlaceStop(address: 'A', lat: 1, lng: 2));
    draft.setDropoff(const PlaceStop(address: 'B', lat: 3, lng: 4));
    draft.applyQuotes(
      FareQuotes(
        distanceM: 1000,
        durationS: 120,
        source: 'ROUTES',
        zone: 'INSIDE_TOWN',
        options: [
          QuoteOption(
            vehicleTypeId: 'vt',
            name: 'Sedan',
            subtotalCents: 1000,
            taxCents: 50,
            totalCents: 1050,
            quoteToken: 'tok-1',
            expiresAt: DateTime.utc(2030),
            etaMinutes: 5,
          ),
        ],
      ),
    );
    draft.choose(container.read(bookingDraftProvider).quotes!.options.first);
    draft.applyQuotes(
      FareQuotes(
        distanceM: 1000,
        durationS: 120,
        source: 'ROUTES',
        zone: 'INSIDE_TOWN',
        options: [
          QuoteOption(
            vehicleTypeId: 'vt',
            name: 'Sedan',
            subtotalCents: 1200,
            taxCents: 60,
            totalCents: 1260,
            quoteToken: 'tok-2',
            expiresAt: DateTime.utc(2030),
          ),
        ],
      ),
      keepVehicleTypeId: 'vt',
    );
    final state = container.read(bookingDraftProvider);
    expect(state.quotes?.priceChanged, isTrue);
    expect(state.chosen?.totalCents, 1260);
    expect(state.chosen?.etaMinutes, isNull);
  });

  test('QUOTE_EXPIRED replacement keeps the ride and asks for re-confirmation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final draft = container.read(bookingDraftProvider.notifier);
    draft.setPickup(const PlaceStop(address: 'A', lat: 1, lng: 2));
    draft.setDropoff(const PlaceStop(address: 'B', lat: 3, lng: 4));
    draft.applyQuotes(
      FareQuotes(
        distanceM: 1000,
        durationS: 120,
        source: 'ROUTES',
        zone: 'INSIDE_TOWN',
        options: [
          QuoteOption(
            vehicleTypeId: 'vt',
            name: 'Sedan',
            subtotalCents: 1000,
            taxCents: 50,
            totalCents: 1050,
            quoteToken: 'tok-1',
            expiresAt: DateTime.utc(2030),
          ),
        ],
      ),
    );
    draft.choose(container.read(bookingDraftProvider).quotes!.options.first);
    final beforeKey = draft.idempotencyKeyFor(draft.createPayload()!);

    // Server returned a fresh batch (QUOTE_EXPIRED body.quote).
    draft.applyQuotes(
      FareQuotes.tryParse({
        'distanceM': 1000,
        'durationS': 120,
        'source': 'ROUTES',
        'zone': 'INSIDE_TOWN',
        'options': [
          {
            'vehicleTypeId': 'vt',
            'name': 'Sedan',
            'subtotalCents': 1300,
            'taxCents': 65,
            'totalCents': 1365,
            'quoteToken': 'tok-fresh',
            'expiresAt': '2030-01-01T00:00:00.000Z',
          },
        ],
      }, priceChanged: true)!,
      keepVehicleTypeId: 'vt',
    );

    final state = container.read(bookingDraftProvider);
    expect(state.quotes?.priceChanged, isTrue);
    expect(state.chosen?.quoteToken, 'tok-fresh');
    expect(state.chosen?.totalCents, 1365);
    final afterKey = draft.idempotencyKeyFor(draft.createPayload()!);
    expect(afterKey, isNot(beforeKey));
  });
}
