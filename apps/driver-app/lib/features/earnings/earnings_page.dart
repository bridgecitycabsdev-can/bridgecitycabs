import 'package:bridgecabs_core/bridgecabs_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EarningsPage extends ConsumerStatefulWidget {
  const EarningsPage({super.key});

  @override
  ConsumerState<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends ConsumerState<EarningsPage> {
  _EarningsBundle? _data;
  String? _error;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now().toUtc();
      final startOfToday = DateTime.utc(now.year, now.month, now.day);
      final startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
      final dio = ref.read(apiClientProvider).dio;
      final today = await _fetch(dio, startOfToday, now);
      final week = await _fetch(dio, startOfWeek, now);
      if (!mounted) return;
      setState(() {
        _data = _EarningsBundle(today: today, week: week);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(error);
        _loading = false;
      });
    }
  }

  Future<_Period> _fetch(Dio dio, DateTime from, DateTime to) async {
    final response = await dio.get<dynamic>(
      '/driver/earnings',
      queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );
    final json = jsonMap(response.data);
    if (json == null) throw StateError('Earnings response incomplete');
    final trips = json['trips'];
    final net = json['netEarningsCents'];
    final balance = json['balanceCents'];
    if (net is! int || balance is! int || trips is! List) {
      throw StateError('Earnings response incomplete');
    }
    return _Period(tripCount: trips.length, netCents: net, balanceCents: balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _PeriodBlock(title: 'Today', period: _data!.today),
                      const SizedBox(height: 24),
                      _PeriodBlock(title: 'This week', period: _data!.week),
                      const SizedBox(height: 32),
                      Text(
                        _balanceLabel(_data!.week.balanceCents),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(_data!.week.balanceCents.abs()),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _PeriodBlock extends StatelessWidget {
  const _PeriodBlock({required this.title, required this.period});

  final String title;
  final _Period period;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('${period.tripCount} trips'),
        Text('Net earnings ${_money(period.netCents)}'),
      ],
    );
  }
}

class _EarningsBundle {
  const _EarningsBundle({required this.today, required this.week});
  final _Period today;
  final _Period week;
}

class _Period {
  const _Period({
    required this.tripCount,
    required this.netCents,
    required this.balanceCents,
  });
  final int tripCount;
  final int netCents;
  final int balanceCents;
}

String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

String _balanceLabel(int balanceCents) {
  if (balanceCents > 0) return 'Company owes you';
  if (balanceCents < 0) return 'You owe the company';
  return 'Settled with the company';
}
