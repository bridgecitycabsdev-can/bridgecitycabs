import 'package:flutter/material.dart';
import '../trip_summary/trip_summary.dart';

class CollectPage extends StatelessWidget {
  const CollectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverTripSummaryPage(
      initialStatus: DriverTripSummaryStatus.cashDue,
    );
  }
}
