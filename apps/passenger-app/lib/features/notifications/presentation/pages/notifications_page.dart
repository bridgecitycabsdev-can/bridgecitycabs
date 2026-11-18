import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../data/models/notification_item_model.dart';
import '../../data/models/notifications_config.dart';
import '../../data/repositories/notifications_repository.dart';
import '../widgets/notification_activity_header.dart';
import '../widgets/notification_card_tile.dart';
import '../widgets/notification_coulee_promo_card.dart';
import '../widgets/notification_empty_view.dart';
import '../widgets/notification_filter_chips.dart';
import '../widgets/notification_offline_view.dart';
import '../widgets/notification_skeleton_view.dart';
import '../widgets/notifications_app_bar.dart';
import '../widgets/push_permission_sheet.dart';

class NotificationsPage extends StatelessWidget {
  final List<NotificationItem>? initialItems;
  final NotificationsViewStatus? initialStatus;
  final bool simulateLoading;
  final NotificationsRepository? repository;
  final bool showPermissionOnOpen;

  const NotificationsPage({
    super.key,
    this.initialItems,
    this.initialStatus,
    this.simulateLoading = false,
    this.repository,
    this.showPermissionOnOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc(
        repository: repository ?? MockNotificationsRepository(),
      )..add(NotificationsStarted(
          initialItems: initialItems,
          initialStatus: initialStatus,
          simulateLoading: simulateLoading,
        )),
      child: _NotificationsView(showPermissionOnOpen: showPermissionOnOpen),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  final bool showPermissionOnOpen;

  const _NotificationsView({this.showPermissionOnOpen = false});

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  @override
  void initState() {
    super.initState();
    if (widget.showPermissionOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermissionBottomSheet(context);
      });
    }
  }

  void _showPermissionBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => PushPermissionSheet(
        onEnable: () {
          Navigator.of(sheetCtx).pop();
          context
              .read<NotificationsBloc>()
              .add(const NotificationsEnablePushTapped());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Push notifications enabled for Bridge City Cabs.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onDismiss: () => Navigator.of(sheetCtx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state.navigateBack) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }

        if (state.targetRoute != null) {
          context.go(state.targetRoute!);
        }

        if (state.showPermissionSheet) {
          _showPermissionBottomSheet(context);
        }
      },
      builder: (context, state) {
        final bloc = context.read<NotificationsBloc>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: NotificationsAppBar(
            onBack: () => bloc.add(const NotificationsBackTapped()),
            onMarkAllAsRead: () =>
                bloc.add(const NotificationsMarkAllAsReadTapped()),
            hasUnread: state.unreadCount > 0,
          ),
          body: _buildBody(context, state, bloc),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationsState state,
    NotificationsBloc bloc,
  ) {
    if (state.isLoading) {
      return const NotificationSkeletonView();
    }

    if (state.isOfflineError) {
      return NotificationOfflineView(
        cachedItems: state.cachedItems,
        onRetry: () => bloc.add(const NotificationsRetryTapped()),
      );
    }

    if (state.isEmpty) {
      return NotificationEmptyView(
        onCheckUpdates: () =>
            bloc.add(const NotificationsCheckForUpdatesTapped()),
      );
    }

    // Populated list view (Screen 1 & Screen 2)
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Activity / All caught up Banner
            NotificationActivityHeader(
              unreadCount: state.unreadCount,
              isAllCaughtUp: state.allCaughtUp,
            ),
            const SizedBox(height: 16),

            // Category Filter Chips
            NotificationFilterChips(
              selectedCategory: state.selectedCategory,
              totalCount: state.items.length,
              onCategoryChanged: (category) =>
                  bloc.add(NotificationsCategoryFilterChanged(category)),
            ),
            const SizedBox(height: 20),

            // TODAY Section
            if (state.todayItems.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (state.unreadTodayCount > 0)
                    Text(
                      '${state.unreadTodayCount} unread',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ...state.todayItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NotificationCardTile(
                    item: item,
                    onTap: () => bloc.add(NotificationsItemTapped(item)),
                  ),
                );
              }),
              const SizedBox(height: 14),
            ],

            // EARLIER Section
            if (state.earlierItems.isNotEmpty) ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EARLIER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'Archived',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...state.earlierItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NotificationCardTile(
                    item: item,
                    onTap: () => bloc.add(NotificationsItemTapped(item)),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Screen 1: Coulee Promo Card
            if (state.unreadCount > 0) ...[
              const NotificationCouleePromoCard(),
              const SizedBox(height: 16),
            ],

            // Screen 2: All caught up pill
            if (state.allCaughtUp) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: Color(0xFF64748B)),
                      SizedBox(width: 6),
                      Text(
                        'No action required',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Retention Notice
            const Center(
              child: Text(
                NotificationsConfig.retentionNotice,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
