import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger_app/features/splash/splash.dart';

class FakeSplashRepository implements SplashRepository {
  @override
  Future<ConnectionStatus> checkFleetDispatchConnectivity() async {
    // Keep in loading state for UI testing
    await Future<void>.delayed(const Duration(seconds: 10));
    return const ConnectionStatus(
      quality: NetworkQuality.normal,
      isFleetDispatchReachable: true,
    );
  }

  @override
  Future<bool> callUrgentCabHotline() async => true;

  @override
  Future<bool> hasStoredSession() async => false;
}

void main() {
  testWidgets('Screen 1 renders branding, trust badge, and Lethbridge region', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashPage(repository: FakeSplashRepository()),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify Screen 1 elements
    expect(find.text(SplashConfig.appName), findsOneWidget);
    expect(find.text(SplashConfig.appTagline), findsOneWidget);
    expect(find.text(SplashConfig.trustedBadgeText), findsOneWidget);
    expect(find.textContaining(SplashConfig.cityRegion), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(BridgeSilhouette), findsOneWidget);
  });

  testWidgets('Screen 2 renders low signal badge and reconnecting message', (tester) async {
    final repository = FakeSplashRepository();
    final bloc = SplashBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SplashBloc>.value(
          value: bloc,
          child: const SplashPage(),
        ),
      ),
    );

    bloc.emit(const SplashSlowConnection());
    await tester.pumpAndSettle();

    // Verify Screen 2 elements
    expect(find.text(SplashConfig.lowSignalPill), findsOneWidget);
    expect(find.text(SplashConfig.stillConnectingPill), findsOneWidget);
    expect(find.text(SplashConfig.reconnectingDispatchNotice), findsOneWidget);
    expect(find.text(SplashConfig.cityRegion), findsOneWidget);

    bloc.close();
  });

  testWidgets('Screen 3 renders connection interrupted card, retry, and urgent hotline', (tester) async {
    final repository = FakeSplashRepository();
    final bloc = SplashBloc(repository: repository);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SplashBloc>.value(
          value: bloc,
          child: const SplashPage(),
        ),
      ),
    );

    bloc.emit(const SplashConnectionInterrupted());
    await tester.pumpAndSettle();

    // Verify Screen 3 elements
    expect(find.text(SplashConfig.offlinePill), findsOneWidget);
    expect(find.text(SplashConfig.searchingSignalPill), findsOneWidget);
    expect(find.text(SplashConfig.errorTitle), findsOneWidget);
    expect(find.text(SplashConfig.errorSubtitle), findsOneWidget);
    expect(find.text(SplashConfig.tryAgainButton), findsOneWidget);
    expect(find.text(SplashConfig.urgentCabHeader), findsOneWidget);
    expect(find.text(SplashConfig.urgentCabPhoneDisplay), findsOneWidget);

    bloc.close();
  });
}
