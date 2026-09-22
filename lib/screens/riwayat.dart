import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/riwayat_service.dart';
import 'detail_riwayat.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key, this.onBukaSkrining});

  final VoidCallback? onBukaSkrining;

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<RiwayatItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    RiwayatService.instance.addListener(_onServiceUpdate);
    _muat();
  }

  @override
  void dispose() {
    RiwayatService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) {
      _muat();
    }
  }

  Future<void> _muat() async {
    final items = await RiwayatService.instance.ambilSemua();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  String _formatWaktu(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final jam = d.hour.toString().padLeft(2, '0');
    final menit = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${bulan[d.month - 1]} ${d.year}, $jam.$menit';
  }

  Color _badgeColor(String intensitas) {
    switch (intensitas) {
      case 'Berat':
        return Colors.red.shade400;
      case 'Sedang':
        return const Color(0xFFDD9438);
      case 'Ringan':
        return Colors.green.shade500;
      default:
        return Colors.grey;
    }
  }

  void _bukaDetail(RiwayatItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailRiwayatPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textDark,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    'Riwayat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Text(
                '"Lihat kembali aktivitas riwayat migrain Anda untuk memahami gejala, pola, frekuensi, dan intensitas dari waktu ke waktu."',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGrey, height: 1.4),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC9822E).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.history_toggle_off_rounded,
                                    size: 38,
                                    color: Color(0xFFC9822E),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Belum ada riwayat skrining',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Lakukan skrining migrain untuk memantau kondisi dan melihat analisis di sini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _muat,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: _items.length,
                            itemBuilder: (context, i) {
                              final item = _items[i];
                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text(
                                        'Hapus Riwayat?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      content: const Text(
                                        'Data riwayat ini akan dihapus permanen.',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textGrey),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Batal',
                                              style: TextStyle(
                                                  color: AppColors.textGrey)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade400,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) {
                                  RiwayatService.instance.hapus(item.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          const Text('Riwayat berhasil dihapus'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.darkBrown,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.outline),
                                    boxShadow: AppShadows.card,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => _bukaDetail(item),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _formatWaktu(item.waktu),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors.textGrey,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    item.hasil,
                                                    style: const TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: const [
                                                      Text(
                                                        'Lihat detail →',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFFC9822E),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _badgeColor(item.intensitas)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item.intensitas,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      _badgeColor(item.intensitas),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}