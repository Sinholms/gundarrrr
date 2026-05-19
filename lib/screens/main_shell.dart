import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'forecast_screen.dart';
import 'menu_crud_screen.dart';
import 'products_screen.dart';
import 'stock_screen.dart';
import 'restock_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onOpenRestock: () => setState(() => _currentIndex = 5)),
      PosScreen(onTransactionCompleted: () => setState(() {})),
      const ForecastScreen(),
      const ProductsScreen(),
      const StockScreen(),
      const RestockScreen(),
      const MenuCrudScreen(),
    ];
  }

  // Only show 5 in bottom nav, use "Lainnya" for overflow
  static const _navItems = [
    _NavDef(Icons.dashboard_rounded, 'Dashboard'),
    _NavDef(Icons.point_of_sale_rounded, 'POS'),
    _NavDef(Icons.auto_graph_rounded, 'Forecast'),
    _NavDef(Icons.menu_book_rounded, 'Resep'),
    _NavDef(Icons.more_horiz_rounded, 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: WessLessTheme.surfaceCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final nav = _navItems[i];
                final isMore = i == 4;
                final isSelected = isMore
                    ? _currentIndex >= 4
                    : _currentIndex == i;

                return GestureDetector(
                  onTap: () {
                    if (isMore) {
                      _showMoreMenu(context);
                    } else {
                      setState(() => _currentIndex = i);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 14 : 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? WessLessTheme.primary.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          nav.icon,
                          size: 22,
                          color: isSelected
                              ? WessLessTheme.primary
                              : WessLessTheme.textHint,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nav.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? WessLessTheme.primary
                                : WessLessTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _MoreTile(
                icon: Icons.inventory_2_rounded,
                label: 'Stok Bahan Baku',
                sub: 'Pantau ketersediaan bahan',
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _currentIndex = 4);
                },
              ),
              _MoreTile(
                icon: Icons.shopping_cart_rounded,
                label: 'Smart Restock',
                sub: 'Rekomendasi belanja + WhatsApp',
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _currentIndex = 5);
                },
              ),
              _MoreTile(
                icon: Icons.edit_note_rounded,
                label: 'Kelola Menu',
                sub: 'Atur daftar menu jualan',
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _currentIndex = 6);
                },
              ),
              _MoreTile(
                icon: Icons.settings_rounded,
                label: 'Pengaturan',
                sub: 'Profil warung, supplier, akun',
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  final IconData icon;
  final String label;
  const _NavDef(this.icon, this.label);
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: WessLessTheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: WessLessTheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  Text(sub, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: WessLessTheme.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
