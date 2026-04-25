import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../data/crypto_data.dart';
import '../utils/format_utils.dart';
import '../widgets/crypto_list_tile.dart';
import 'crypto_detail_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  static double _computeTotalValue() {
    double total = 0;
    for (final crypto in mockCryptos) {
      final holding = portfolioHoldings.value[crypto.id];
      if (holding != null) {
        total += holding * crypto.price;
      }
    }
    return total;
  }

  static double _computeTotalChange() {
    double totalValue = 0;
    double totalPrevValue = 0;
    for (final crypto in mockCryptos) {
      final holding = portfolioHoldings.value[crypto.id];
      if (holding != null) {
        final currentValue = holding * crypto.price;
        final prevPrice = crypto.price / (1 + crypto.changePercent24h / 100);
        totalValue += currentValue;
        totalPrevValue += holding * prevPrice;
      }
    }
    if (totalPrevValue == 0) return 0;
    return ((totalValue - totalPrevValue) / totalPrevValue) * 100;
  }

  void _navigateToDetail(BuildContext context, Crypto crypto) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CryptoDetailScreen(crypto: crypto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: ValueListenableBuilder<Map<String, double>>(
        valueListenable: portfolioHoldings,
        builder: (context, holdings, _) {
          final totalChange = _computeTotalChange();
          final isPositive = totalChange >= 0;

          final portfolioCryptos = mockCryptos
              .where((c) => holdings.containsKey(c.id))
              .toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colorScheme.primary, colorScheme.tertiary],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Portfolio Value',
                            style: TextStyle(
                              color: colorScheme.onPrimary.withAlpha(180),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatLargeNumber(_computeTotalValue()),
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isPositive ? Icons.trending_up : Icons.trending_down,
                                color: isPositive
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${isPositive ? '+' : ''}${totalChange.toStringAsFixed(2)}% today',
                                style: TextStyle(
                                  color: isPositive
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            body: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: portfolioCryptos.length,
              itemBuilder: (context, index) {
                final crypto = portfolioCryptos[index];
                final holdingQty = holdings[crypto.id] ?? 0.0;

                // Dismissible allows swipe-to-delete from dashboard.
                return Dismissible(
                  key: Key('portfolio_${crypto.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.redAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return direction == DismissDirection.endToStart;
                  },
                  onDismissed: (direction) {
                    // Remove and show undo.
                    final removedAmount = removeFromPortfolio(crypto.id);

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${crypto.name} removed from Dashboard'),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () {
                            if (removedAmount != null) {
                              setPortfolioHolding(crypto.id, removedAmount);
                            }
                          },
                        ),
                      ),
                    );
                  },
                  child: CryptoListTile(
                    crypto: crypto,
                    onTap: () => _navigateToDetail(context, crypto),
                    // Optionally show holding quantity in tile — if CryptoListTile supports subtitle or trailing props you can adapt it.
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}