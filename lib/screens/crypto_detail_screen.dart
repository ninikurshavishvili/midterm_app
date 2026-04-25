import 'package:flutter/material.dart';
import '../models/crypto.dart';
import '../data/crypto_data.dart';
import '../utils/format_utils.dart';

class CryptoDetailScreen extends StatelessWidget {
  final Crypto crypto;

  const CryptoDetailScreen({super.key, required this.crypto});

  String _formatLargeNumber(double value) => formatLargeNumber(value);

  String _formatPrice(double price) => formatPrice(price);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cryptoAccent = cryptoColor(crypto);
    final holding = portfolioHoldings.value[crypto.id];
    final holdingValue = holding != null ? holding * crypto.price : null;

    final changeColor =
        crypto.isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final changeBackground =
        crypto.isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                crypto.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cryptoAccent.withAlpha(200),
                      cryptoAccent.withAlpha(100),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withAlpha(50),
                        child: Text(
                          crypto.symbol.length > 3
                              ? crypto.symbol.substring(0, 3)
                              : crypto.symbol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Price',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatPrice(crypto.price),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: changeBackground,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  crypto.isPositive
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: changeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${crypto.changePercent24h.abs().toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: changeColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Market stats
                  Text(
                    'Market Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          _StatRow(
                            label: 'Market Cap',
                            value: _formatLargeNumber(crypto.marketCap),
                          ),
                          const Divider(indent: 16, endIndent: 16, height: 1),
                          _StatRow(
                            label: '24h Volume',
                            value: _formatLargeNumber(crypto.volume24h),
                          ),
                          const Divider(indent: 16, endIndent: 16, height: 1),
                          _StatRow(
                            label: '24h Change',
                            value:
                                '${crypto.isPositive ? '+' : ''}${crypto.changePercent24h.toStringAsFixed(2)}%',
                            valueColor: changeColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Portfolio holding (if owned)
                  if (holdingValue != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'My Holding',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            _StatRow(
                              label: 'Amount',
                              value:
                                  '${holding!.toStringAsFixed(holding < 1 ? 4 : 2)} ${crypto.symbol}',
                            ),
                            const Divider(
                                indent: 16, endIndent: 16, height: 1),
                            _StatRow(
                              label: 'Value',
                              value: _formatPrice(holdingValue),
                              valueColor: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}
