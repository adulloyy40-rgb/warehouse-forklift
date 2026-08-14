// ============================================================
// FILE:
// lib/presentation/pages/dashboard/dashboard_page.dart
// ============================================================
//
// FUNGSI:
// Dashboard utama aplikasi Warehouse Forklift.
//
// CATATAN:
// Tahap ini masih UI shell.
// Belum terhubung ke database atau repository.
//
// Dashboard akan menjadi pusat navigasi operator gudang.
// ============================================================

import 'package:flutter/material.dart';


// ============================================================
// DASHBOARD PAGE
// ============================================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warehouse Forklift',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Warehouse Operations',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(
              right: 16,
            ),
            child: CircleAvatar(
              radius: 18,
              child: Icon(
                Icons.person_outline_rounded,
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // GREETING
              // ------------------------------------------------

              const SizedBox(height: 12),

              Text(
                'Selamat datang, Operator 👋',
                style:
                    theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Kelola aktivitas gudang dengan cepat dan aman.',
                style:
                    theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // QUICK ACTION
              // ------------------------------------------------

              Text(
                'Operasional',
                style:
                    theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _MenuCard(
                    icon: Icons.inventory_2_rounded,
                    title: 'Master Barang',
                    subtitle: 'Data produk',
                    onTap: () {},
                  ),

                  _MenuCard(
                    icon: Icons.location_on_rounded,
                    title: 'Storage',
                    subtitle: 'Lokasi rak',
                    onTap: () {},
                  ),

                  _MenuCard(
                    icon: Icons.precision_manufacturing_rounded,
                    title: 'Putaway',
                    subtitle: 'Simpan pallet',
                    onTap: () {},
                  ),

                  _MenuCard(
                    icon: Icons.local_shipping_rounded,
                    title: 'Picking',
                    subtitle: 'Ambil barang',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // STOCK OVERVIEW
              // ------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock Overview',
                    style:
                        theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Semua',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // STOCK CARD
              // ------------------------------------------------

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _StockRow(
                        icon: Icons.inventory_2_outlined,
                        title: 'Total Pallet',
                        value: '108',
                      ),

                      const Divider(
                        height: 24,
                      ),

                      _StockRow(
                        icon: Icons.warehouse_outlined,
                        title: 'Storage Terisi',
                        value: '76',
                      ),

                      const Divider(
                        height: 24,
                      ),

                      _StockRow(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Location Available',
                        value: '32',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // SYSTEM STATUS
              // ------------------------------------------------

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.green
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_done_rounded,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Ready',
                              style: theme
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Warehouse system siap digunakan.',
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.inventory_2_outlined,
            ),
            selectedIcon: Icon(
              Icons.inventory_2_rounded,
            ),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.local_shipping_outlined,
            ),
            selectedIcon: Icon(
              Icons.local_shipping_rounded,
            ),
            label: 'Operation',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings_rounded,
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }
}


// ============================================================
// MENU CARD
// ============================================================

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color:
                    theme.colorScheme.primary,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// STOCK ROW
// ============================================================

class _StockRow extends StatelessWidget {
  const _StockRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: theme
                .textTheme
                .bodyLarge
                ?.copyWith(
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,
          style: theme
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
