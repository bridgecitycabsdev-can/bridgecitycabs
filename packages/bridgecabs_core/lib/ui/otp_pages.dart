import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session.dart';
import 'code_entry.dart';
import 'phone_entry.dart';

class OtpPhonePage extends ConsumerWidget {
  const OtpPhonePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PhoneEntry(
      onSubmit: (raw) async {
        final phone = await ref.read(sessionProvider.notifier).requestOtp(raw);
        if (!context.mounted) return;
        context.go('/code?phone=${Uri.encodeQueryComponent(phone)}');
      },
    );
  }
}

class OtpCodePage extends ConsumerWidget {
  const OtpCodePage({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (phone.isEmpty) {
      return const Scaffold(body: Center(child: Text('Request a code first.')));
    }
    return CodeEntry(
      phone: phone,
      onSubmit: (code) =>
          ref.read(sessionProvider.notifier).verifyOtp(phone, code),
      onResend: () => ref.read(sessionProvider.notifier).requestOtp(phone),
    );
  }
}
