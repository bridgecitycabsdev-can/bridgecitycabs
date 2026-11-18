import 'package:flutter/material.dart';

class DriverMenuLogoutButton extends StatelessWidget {
  final bool isLocked;
  final bool isOutlined;
  final VoidCallback? onLogoutPressed;

  const DriverMenuLogoutButton({
    super.key,
    this.isLocked = false,
    this.isOutlined = false,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 16, color: Colors.black38),
            SizedBox(width: 8),
            Text(
              'Log out (Active Trip)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onLogoutPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Color(0xFFFFCDD2)),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 16, color: Color(0xFFC62828)),
              SizedBox(width: 8),
              Text(
                'Log out',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onLogoutPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFFF7F7F7),
          foregroundColor: const Color(0xFFB71C1C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 16, color: Color(0xFFC62828)),
            SizedBox(width: 8),
            Text(
              'Log out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB71C1C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
