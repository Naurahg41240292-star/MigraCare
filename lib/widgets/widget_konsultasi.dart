import 'package:flutter/material.dart';

import '../models/dokter.dart';
import '../theme.dart';

/// =======================================================================
///  MIGRACARE — Komponen UI Khusus Konsultasi
///  File: lib/widgets/widget_konsultasi.dart
/// =======================================================================

class AvatarDokter extends StatelessWidget {
  final Dokter dokter;
  final double size;

  const AvatarDokter({
    super.key,
    required this.dokter,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dokter.warnaAvatar,
        shape: BoxShape.circle,
      ),
      child: dokter.foto != null
          ? Image.asset(
              dokter.foto!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        '🩺',
        style: TextStyle(fontSize: size * 0.45),
      ),
    );
  }
}

class BadgeOnline extends StatelessWidget {
  final String label;

  const BadgeOnline({super.key, this.label = 'Online'});

  @override
  Widget build(BuildContext context) {
    final bool isOnline = label.toLowerCase() == 'online';
    final Color warna = isOnline ? AppColors.online : AppColors.textSoft;
    final Color warnaBg = isOnline ? AppColors.onlineBg : AppColors.chipBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: warnaBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: warna,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }
}