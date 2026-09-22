import 'package:flutter/material.dart';
import '../theme.dart';

class NavBawah extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const NavBawah({super.key, required this.index, required this.onTap});

  static const List<(String, IconData)> _items = [
    ('Beranda', Icons.home_outlined),
    ('Skrining', Icons.fact_check_outlined),
    ('Konsultasi', Icons.chat_rounded),
    ('Riwayat', Icons.history_rounded),
    ('Profil', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Row(
        children: List.generate(_items.length, (i) {
          final (label, icon) = _items[i];
          final aktif = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 21,
                        color: aktif ? AppColors.primary : const Color(0xFFB7B0A3)),
                    const SizedBox(height: 4),
                    Text(label, style: TextStyle(
                      fontSize: 11,
                      fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                      color: aktif ? AppColors.primary : const Color(0xFFB7B0A3),
                    )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}