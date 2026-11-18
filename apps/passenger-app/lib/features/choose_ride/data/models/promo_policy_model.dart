import 'package:equatable/equatable.dart';

class PromoPolicyModel extends Equatable {
  final String code;
  final String title;
  final String subtitle;
  final String minimumFare;
  final String validUntil;
  final String appliesTo;
  final String accountUsage;
  final String serverPolicy;
  final String municipalNotice;

  const PromoPolicyModel({
    this.code = 'WELCOME5',
    this.title = '\$3 off your first ride',
    this.subtitle =
        'Applied to standard single passenger transit across the City of Lethbridge.',
    this.minimumFare = '\$12.00 CAD',
    this.validUntil = '31 Oct 2026, 11:59 PM MST',
    this.appliesTo = 'All standard rides in Lethbridge',
    this.accountUsage = 'Single-use for new registered accounts',
    this.serverPolicy = 'Cannot be stacked with promotions',
    this.municipalNotice =
        'Verified Bridge City mobility code. Fair transit rate guaranteed under Lethbridge municipal taxi regulations.',
  });

  @override
  List<Object?> get props => [
        code,
        title,
        subtitle,
        minimumFare,
        validUntil,
        appliesTo,
        accountUsage,
        serverPolicy,
        municipalNotice,
      ];
}
