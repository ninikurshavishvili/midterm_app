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
      final holding = portfolioHoldings[crypto.id];
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
      final holding = portfolioHoldings[crypto.id];
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

  static List<Crypto> _portfolioCryptos() =>
      mockCryptos.where((c) => portfolioHoldings.containsKey(c.id)).toList();

  void _navigateToDetail(BuildContext context, Crypto crypto) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CryptoDetailScreen(crypto: crypto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalChange = _computeTotalChange();
    final isPositive = totalChange >= 0;
    final portfolioCryptos = _portfolioCryptos();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: NestedScrollView(
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
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
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
            return CryptoListTile(
              crypto: crypto,
              onTap: () => _navigateToDetail(context, crypto),
            );
          },
        ),
      ),
    );
  }
}
