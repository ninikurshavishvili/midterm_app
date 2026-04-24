import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../data/crypto_data.dart';
import '../widgets/crypto_list_tile.dart';
import 'crypto_detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int _selectedTab = 0;

  double get _totalPortfolioValue {
    double total = 0;
    for (final crypto in mockCryptos) {
      final holding = portfolioHoldings[crypto.id];
      if (holding != null) {
        total += holding * crypto.price;
      }
    }
    return total;
  }

  double get _totalPortfolioChange {
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

  List<Crypto> get _portfolioCryptos => mockCryptos
      .where((c) => portfolioHoldings.containsKey(c.id))
      .toList();

  String _formatLargeValue(double value) {
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '\$${(value / 1e3).toStringAsFixed(2)}K';
    return '\$${value.toStringAsFixed(2)}';
  }

  void _navigateToDetail(BuildContext context, Crypto crypto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CryptoDetailScreen(crypto: crypto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalChange = _totalPortfolioChange;
    final isPositivePortfolio = totalChange >= 0;

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
                'Crypto Portfolio',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Value',
                        style: TextStyle(
                          color: colorScheme.onPrimary.withAlpha(180),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatLargeValue(_totalPortfolioValue),
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
                            isPositivePortfolio
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: isPositivePortfolio
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositivePortfolio ? '+' : ''}${totalChange.toStringAsFixed(2)}% today',
                            style: TextStyle(
                              color: isPositivePortfolio
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
        body: Column(
          children: [
            // Tab selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('All Coins')),
                  ButtonSegment(value: 1, label: Text('My Portfolio')),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (Set<int> selection) {
                  setState(() => _selectedTab = selection.first);
                },
              ),
            ),
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: _selectedTab == 0
                    ? mockCryptos.length
                    : _portfolioCryptos.length,
                itemBuilder: (context, index) {
                  final crypto = _selectedTab == 0
                      ? mockCryptos[index]
                      : _portfolioCryptos[index];
                  return CryptoListTile(
                    crypto: crypto,
                    onTap: () => _navigateToDetail(context, crypto),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
