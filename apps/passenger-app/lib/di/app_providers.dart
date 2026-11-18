import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/booking_remote_datasource.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../data/datasources/payment_remote_datasource.dart';
import '../data/datasources/places_remote_datasource.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../data/datasources/rating_remote_datasource.dart';
import '../data/datasources/sos_remote_datasource.dart';
import '../data/datasources/support_remote_datasource.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/places_repository.dart';
import '../features/delete_account/delete_account.dart';
import '../features/notifications/notifications.dart';
import '../features/profile/profile.dart';
import '../features/rate_driver/rate_driver.dart';
import '../features/sos_alert/sos_alert.dart';
import '../features/support/support.dart';
import '../features/trip_history/trip_history.dart';

/// Shared authenticated client. Screens depend on repositories, not this.
final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);

final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>(
  (ref) => BookingRemoteDataSource(ref.watch(dioProvider)),
);

final placesRemoteDataSourceProvider = Provider<PlacesRemoteDataSource>(
  (ref) => PlacesRemoteDataSource(ref.watch(dioProvider)),
);

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>(
  (ref) => PaymentRemoteDataSource(ref.watch(dioProvider)),
);

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
  (ref) => NotificationRemoteDataSource(ref.watch(dioProvider)),
);

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>(
  (ref) => SupportRemoteDataSource(ref.watch(dioProvider)),
);

final sosRemoteDataSourceProvider = Provider<SosRemoteDataSource>(
  (ref) => SosRemoteDataSource(ref.watch(dioProvider)),
);

final ratingRemoteDataSourceProvider = Provider<RatingRemoteDataSource>(
  (ref) => RatingRemoteDataSource(ref.watch(dioProvider)),
);

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.watch(dioProvider)),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(ref.watch(bookingRemoteDataSourceProvider)),
);

final placesRepositoryProvider = Provider<PlacesRepository>(
  (ref) => PlacesRepository(ref.watch(placesRemoteDataSourceProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(paymentRemoteDataSourceProvider)),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => ApiNotificationsRepository(
    ref.watch(notificationRemoteDataSourceProvider),
  ),
);

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => ApiSupportRepository(ref.watch(supportRemoteDataSourceProvider)),
);

final ratingRepositoryProvider = Provider<RateDriverRepository>(
  (ref) => ApiRateDriverRepository(
    ref.watch(ratingRemoteDataSourceProvider),
    ref.watch(supportRemoteDataSourceProvider),
  ),
);

/// [bookingId] is the live trip, when the passenger already has one.
final sosRepositoryProvider = Provider.family<SosAlertRepository, String?>(
  (ref, bookingId) => ApiSosAlertRepository(
    ref.watch(sosRemoteDataSourceProvider),
    bookingId: bookingId,
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(
    ref.watch(profileRemoteDataSourceProvider),
    onLogout: () => ref.read(sessionProvider.notifier).signOutWithPushCleanup(
      () => ref.read(pushControllerProvider.notifier).unregisterAndDeleteToken(),
    ),
  ),
);

final tripHistoryRepositoryProvider = Provider<TripHistoryRepository>(
  (ref) => ApiTripHistoryRepository(ref.watch(bookingRemoteDataSourceProvider)),
);

final deleteAccountRepositoryProvider = Provider<DeleteAccountRepository>(
  (ref) => ApiDeleteAccountRepository(ref.watch(profileRemoteDataSourceProvider)),
);
