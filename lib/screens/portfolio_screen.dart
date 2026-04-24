import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../data/crypto_data.dart';
import '../utils/format_utils.dart';
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

  String _formatLargeValue(double value) => formatLargeNumber(value);

  void _navigateToDetail(BuildContext context, Crypto crypto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CryptoDetailScreen(crypto: crypto),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, Crypto crypto) async {
    final controller = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Add ${crypto.name}'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                final amount = double.tryParse(controller.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter valid amount')),
                  );
                } else {
                  setState(() {
                    portfolioHoldings[crypto.id] =
                        (portfolioHoldings[crypto.id] ?? 0) + amount;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to portfolio')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _removeFromPortfolio(BuildContext context, Crypto crypto) {
    setState(() {
      portfolioHoldings.remove(crypto.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from portfolio')),
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

                  if (_selectedTab == 0) {
                    // All Coins: swipe right to add
                    return Dismissible(
                      key: ValueKey('all_${crypto.id}'),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) async {
                        await _showAddDialog(context, crypto);
                        return false;
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      child: CryptoListTile(
                        crypto: crypto,
                        onTap: () => _navigateToDetail(context, crypto),
                      ),
                    );
                  } else {
                    // My Portfolio: swipe left to remove
                    return Dismissible(
                      key: ValueKey('portfolio_${crypto.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeFromPortfolio(context, crypto),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: CryptoListTile(
                        crypto: crypto,
                        onTap: () => _navigateToDetail(context, crypto),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
