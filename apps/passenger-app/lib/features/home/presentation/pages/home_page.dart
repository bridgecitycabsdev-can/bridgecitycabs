import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../data/models/home_mode.dart';
import '../../data/models/ride_tier_estimate.dart';
import '../../data/models/waypoint.dart';
import '../../data/repositories/home_repository.dart';
import '../widgets/book_ride_panel.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_map_view.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/plan_ride_panel.dart';
import '../widgets/ready_to_ride_sheet.dart';
import '../widgets/where_to_sheet.dart';

/// Entry page for the passenger Home Screen flow.
///
/// Handles all 4 primary interactive modes and the side navigation drawer:
/// - Screen 1: Where to? (Initial Search State)
/// - Screen 5: Ready to ride (Destination Selected & Distance Computed)
/// - Screen 2: Book a Ride (Single Destination with GPS Disabled Warning & Vehicle Preview)
/// - Screen 3: Plan Ride (Multi-Stop Trip Itinerary & Waypoints)
/// - Screen 4: Navigation Drawer (Profile, Menu, Logout, Socials)
class HomePage extends StatelessWidget {
  final HomeRepository? repository;
  final HomeBloc? bloc;
  final HomeMode initialMode;
  final Future<void> Function()? onSignedOut;

  const HomePage({
    super.key,
    this.repository,
    this.bloc,
    this.initialMode = HomeMode.whereTo,
    this.onSignedOut,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: _HomeView(onSignedOut: onSignedOut),
      );
    }

    return BlocProvider(
      create: (context) => HomeBloc(
        repository: repository ?? HomeRepositoryImpl(),
      )..add(HomeStarted(initialMode: initialMode)),
      child: _HomeView(onSignedOut: onSignedOut),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({this.onSignedOut});

  final Future<void> Function()? onSignedOut;

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.targetRoute != null) {
          context.go(state.targetRoute!);
        }
      },
      builder: (context, state) {
        final mode = state.mode;
        final waypoints = state.waypoints;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: mode == HomeMode.bookRide || mode == HomeMode.planRide
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: HomeDrawer(
              profile: state.profile,
              onClose: () => Navigator.of(context).pop(),
              onMenuItemTapped: (item) {
                Navigator.of(context).pop();
                const routes = {
                  'profile': '/profile',
                  'trips': '/trips',
                  'payment': '/payment-methods',
                  'notifications': '/notifications',
                  'support': '/support',
                  'safety': '/sos-alert',
                  'settings': '/settings',
                };
                final path = routes[item];
                if (path != null) context.push(path);
              },
              onLogout: () {
                Navigator.of(context).pop();
                final signedOut = widget.onSignedOut;
                if (signedOut != null) {
                  signedOut();
                  return;
                }
                context.read<HomeBloc>().add(const HomeLogoutTapped());
              },
            ),
            body: Stack(
              children: [
                // Layer 1: Background Vector Map Canvas
                Positioned.fill(
                  child: HomeMapView(
                    mode: mode,
                    waypoints: waypoints,
                    onRecenterTapped: () => context
                        .read<HomeBloc>()
                        .add(const HomeRecenterMapTapped()),
                  ),
                ),

                // Layer 2: Top Floating Navigation / App Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: HomeTopBar(
                    mode: mode,
                    onMenuTapped: () => _scaffoldKey.currentState?.openDrawer(),
                    onNotificationsTapped: () {},
                    onBackTapped: () {
                      if (mode == HomeMode.bookRide || mode == HomeMode.planRide) {
                        context.read<HomeBloc>().add(const HomeModeChanged(HomeMode.whereTo));
                      }
                    },
                  ),
                ),

                // Layer 3: Dynamic Bottom Panel based on current mode
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildBottomPanel(context, state),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel(BuildContext context, HomeState state) {
    switch (state.mode) {
      case HomeMode.whereTo:
        return WhereToSheet(
          onPickupTapped: () {},
          onWhereToTapped: () => context.push('/search'),
          onAddStopTapped: () => context
              .read<HomeBloc>()
              .add(const HomeModeChanged(HomeMode.planRide)),
          selectedCategory: state.selectedCategory,
          onCategorySelected: (cat) =>
              context.read<HomeBloc>().add(HomeCategorySelected(cat)),
          onContinueTapped: null,
        );

      case HomeMode.readyToRide:
        return ReadyToRideSheet(
          pickupAddress: state.pickup?.title ?? 'Downtown (515 5th Ave S)',
          dropoffAddress:
              state.dropoff?.title ?? 'Park Place Mall (Main Entrance)',
          distanceText: state.distanceText,
          onEditPickup: () {},
          onClearDropoff: () => context
              .read<HomeBloc>()
              .add(const HomeModeChanged(HomeMode.whereTo)),
          onAddStopTapped: () => context
              .read<HomeBloc>()
              .add(const HomeModeChanged(HomeMode.planRide)),
          selectedCategory: state.selectedCategory,
          onCategorySelected: (cat) =>
              context.read<HomeBloc>().add(HomeCategorySelected(cat)),
          onContinueTapped: () =>
              context.read<HomeBloc>().add(const HomeContinueTapped()),
        );

      case HomeMode.bookRide:
        final estimate = state.selectedEstimate ??
            const RideTierEstimate(
              id: 'city_red_cruiser',
              name: 'City Red Cruiser',
              badge: 'Fast',
              etaMinutes: 3,
              vehicleDetails: '4 seats',
              priceCad: 14.20,
              originalPriceCad: 17.50,
            );

        return BookRidePanel(
          pickupText: state.pickup?.title ?? 'Enter pickup',
          dropoffText: state.dropoff?.title ?? '440 University Dr, Lethbridge',
          isLocationOff: !state.isLocationServiceEnabled,
          onEnableLocation: () =>
              context.read<HomeBloc>().add(const HomeGpsEnableTapped()),
          estimate: estimate,
          onContinueTapped: () =>
              context.read<HomeBloc>().add(const HomeContinueTapped()),
        );

      case HomeMode.planRide:
        final estimate = state.selectedEstimate ??
            const RideTierEstimate(
              id: 'crimson_standard',
              name: 'Crimson Standard',
              badge: 'Fastest',
              etaMinutes: 3,
              vehicleDetails: 'Toyota RAV4',
              priceCad: 21.40,
              originalPriceCad: 24.00,
            );

        return PlanRidePanel(
          waypoints: state.waypoints,
          onAddAnotherStop: () {
            context.read<HomeBloc>().add(const HomeStopAdded(
                  Waypoint(
                    id: 'wp_stop_extra',
                    type: WaypointType.stop,
                    title: 'Lethbridge Mall',
                    subtitle: 'Scenic Dr S, Lethbridge',
                    lat: 49.6920,
                    lng: -112.8350,
                    tag: '+3 min wait',
                  ),
                ));
          },
          onRemoveStop: (id) =>
              context.read<HomeBloc>().add(HomeStopRemoved(id)),
          onReorderStops: () {},
          selectedCategory: state.selectedCategory,
          onCategorySelected: (cat) =>
              context.read<HomeBloc>().add(HomeCategorySelected(cat)),
          estimate: estimate,
          paymentMethod: state.profile.defaultPayment,
          onChangePayment: () {},
          onContinueToOptions: () =>
              context.read<HomeBloc>().add(const HomeContinueTapped()),
        );
    }
  }
}
