import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/crypto_data.dart';
import '../models/crypto.dart';
import '../utils/format_utils.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  // "from" can be a Crypto or the USD sentinel
  static const String _usdId = '__usd__';

  String _fromId = 'bitcoin';
  String _toId = _usdId;
  final TextEditingController _amountController =
      TextEditingController(text: '1');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Crypto? _cryptoById(String id) {
    try {
      return mockCryptos.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  double get _fromPrice {
    if (_fromId == _usdId) return 1.0;
    return _cryptoById(_fromId)?.price ?? 1.0;
  }

  double get _toPrice {
    if (_toId == _usdId) return 1.0;
    return _cryptoById(_toId)?.price ?? 1.0;
  }

  double get _result {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_toPrice == 0) return 0;
    return (amount * _fromPrice) / _toPrice;
  }

  String _label(String id) {
    if (id == _usdId) return 'USD';
    return _cryptoById(id)?.symbol ?? id;
  }

  String _fullName(String id) {
    if (id == _usdId) return 'US Dollar (USD)';
    final c = _cryptoById(id);
    return c != null ? '${c.name} (${c.symbol})' : id;
  }

  String _formatResult(double value) {
    if (_toId == _usdId) return formatPrice(value);
    if (value >= 1000) {
      return value.toStringAsFixed(2);
    } else if (value >= 1) {
      return value.toStringAsFixed(4);
    }
    return value.toStringAsFixed(8);
  }

  void _swap() {
    setState(() {
      final tmp = _fromId;
      _fromId = _toId;
      _toId = tmp;
    });
  }

  Future<void> _pickCurrency(
      {required bool isFrom}) async {
    final options = [
      _usdId,
      ...mockCryptos.map((c) => c.id),
    ];
    final current = isFrom ? _fromId : _toId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ...options.map((id) {
                final selected = id == current;
                return ListTile(
                  title: Text(_fullName(id)),
                  trailing: selected
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      if (isFrom) {
                        _fromId = id;
                      } else {
                        _toId = id;
                      }
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resultText = _formatResult(_result);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // From card
            _CurrencyCard(
              label: 'From',
              currencyLabel: _label(_fromId),
              fullName: _fullName(_fromId),
              isInput: true,
              controller: _amountController,
              onCurrencyTap: () => _pickCurrency(isFrom: true),
              onChanged: (_) => setState(() {}),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Swap button
            Center(
              child: FilledButton.tonal(
                onPressed: _swap,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                ),
                child: const Icon(Icons.swap_vert),
              ),
            ),
            const SizedBox(height: 12),

            // To card
            _CurrencyCard(
              label: 'To',
              currencyLabel: _label(_toId),
              fullName: _fullName(_toId),
              isInput: false,
              resultText: resultText,
              onCurrencyTap: () => _pickCurrency(isFrom: false),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 28),

            // Rate info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exchange Rate',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1 ${_label(_fromId)} = ${_formatResult(_toPrice == 0 ? 0 : _fromPrice / _toPrice)} ${_label(_toId)}',
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final String label;
  final String currencyLabel;
  final String fullName;
  final bool isInput;
  final TextEditingController? controller;
  final String? resultText;
  final VoidCallback onCurrencyTap;
  final ValueChanged<String>? onChanged;
  final ColorScheme colorScheme;

  const _CurrencyCard({
    required this.label,
    required this.currencyLabel,
    required this.fullName,
    required this.isInput,
    required this.onCurrencyTap,
    required this.colorScheme,
    this.controller,
    this.resultText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: isInput
                      ? TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          onChanged: onChanged,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                        )
                      : Text(
                          resultText ?? '0',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onCurrencyTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currencyLabel,
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.expand_more,
                            color: colorScheme.onPrimaryContainer, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              fullName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
