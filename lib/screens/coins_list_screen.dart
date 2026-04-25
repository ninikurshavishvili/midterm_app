import 'package:flutter/material.dart';
import '../data/crypto_data.dart';
import '../models/crypto.dart';
import '../widgets/crypto_list_tile.dart';
import 'crypto_detail_screen.dart';

class CoinsListScreen extends StatefulWidget {
  const CoinsListScreen({super.key});

  @override
  State<CoinsListScreen> createState() => _CoinsListScreenState();
}

class _CoinsListScreenState extends State<CoinsListScreen> {
  String _query = '';

  List<Crypto> get _filtered {
    if (_query.isEmpty) return mockCryptos;
    final q = _query.toLowerCase();
    return mockCryptos
        .where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.symbol.toLowerCase().contains(q))
        .toList();
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
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Coins',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search coins…',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
        child: Text(
          'No coins found',
          style: TextStyle(color: colorScheme.outline),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final crypto = filtered[index];

          // Dismissible allows swipe to add to portfolio.
          return Dismissible(
            key: Key('coins_${crypto.id}'),
            direction: DismissDirection.startToEnd,
            background: Container(
              padding: const EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
              child: Row(
                children: const [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Add to Dashboard',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              // Optional: confirm or animate; we just proceed.
              return direction == DismissDirection.startToEnd;
            },
            onDismissed: (direction) {
              // Add default amount (1.0) — change as needed.
              addToPortfolio(crypto.id, amount: 1.0);

              // Show undo snackbar
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${crypto.name} added to Dashboard'),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      // Remove the amount we just added.
                      // If there were pre-existing holdings, this subtracts 1.0.
                      final prev = portfolioHoldings.value[crypto.id] ?? 0.0;
                      if (prev <= 1.0) {
                        removeFromPortfolio(crypto.id);
                      } else {
                        setPortfolioHolding(crypto.id, prev - 1.0);
                      }
                    },
                  ),
                ),
              );
            },
            child: CryptoListTile(
              crypto: crypto,
              onTap: () => _navigateToDetail(context, crypto),
            ),
          );
        },
      ),
    );
  }
}