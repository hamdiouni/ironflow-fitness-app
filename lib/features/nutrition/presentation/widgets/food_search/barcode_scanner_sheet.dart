import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/presentation/services/app_haptics.dart';
import '../../../domain/entities/food_item.dart';
import '../../../domain/services/open_food_facts_service.dart';

/// Opens the Barcode Scanner & Open Food Facts (ODbL v1.0) lookup modal sheet.
Future<void> showBarcodeScannerSheet(
  BuildContext context, {
  required ValueChanged<FoodItem> onFoodFound,
  OpenFoodFactsService? service,
}) {
  final tokens = AppThemeTokens.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: tokens.canvas,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
    ),
    builder: (sheetCtx) => BarcodeScannerSheet(
      onFoodFound: (food) {
        Navigator.of(sheetCtx).pop();
        onFoodFound(food);
      },
      service: service ??
          OpenFoodFactsService(
            httpGetter: (uri, headers) async {
              final resp = await http
                  .get(uri, headers: headers)
                  .timeout(const Duration(seconds: 8));
              return (statusCode: resp.statusCode, body: resp.body);
            },
          ),
    ),
  );
}

class BarcodeScannerSheet extends StatefulWidget {
  const BarcodeScannerSheet({
    super.key,
    required this.onFoodFound,
    required this.service,
  });

  final ValueChanged<FoodItem> onFoodFound;
  final OpenFoodFactsService service;

  @override
  State<BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isLoading = false;
  OpenFoodFactsLookupResult? _result;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _runLookup(String rawBarcode) async {
    AppHaptics.shared.buttonPress();
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final lookup = await widget.service.lookupBarcode(rawBarcode);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _result = lookup;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: tokens.cyanAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BARCODE SCANNER',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      Text(
                        'OPEN FOOD FACTS (ODbL v1.0) & VERIFIED GYM CATALOG',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: tokens.cyanAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('barcode_sheet_close_button'),
                  icon: Icon(Icons.close_rounded, color: tokens.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Scanner reticle viewport
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.borderSubtle),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 40,
                    color: tokens.kineticAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter an 8–14 digit EAN-13 / UPC-A barcode or tap a quick-scan product below',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('barcode_input_field'),
                          controller: _barcodeController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 14,
                            color: tokens.textPrimary,
                          ),
                          onSubmitted: _runLookup,
                          decoration: InputDecoration(
                            hintText: 'e.g. 0748927024081',
                            hintStyle: TextStyle(
                              color: tokens.textMuted,
                              fontSize: 13,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: tokens.card,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.cyanAccent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        key: const Key('barcode_lookup_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.kineticAccent,
                          foregroundColor: tokens.onAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => _runLookup(_barcodeController.text),
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('LOOKUP'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'QUICK-SCAN VERIFIED BARCODES',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OpenFoodFactsService.offlineVerifiedBarcodes.map((entry) {
                return ActionChip(
                  key: Key('quick_barcode_${entry.barcode}'),
                  backgroundColor: tokens.panel,
                  side: BorderSide(color: tokens.borderSubtle),
                  label: Text(
                    '${entry.brand} (${entry.barcode})',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11,
                      color: tokens.textPrimary,
                    ),
                  ),
                  onPressed: () {
                    _barcodeController.text = entry.barcode;
                    _runLookup(entry.barcode);
                  },
                );
              }).toList(),
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(tokens, _result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    AppThemeTokens tokens,
    OpenFoodFactsLookupResult res,
  ) {
    if (!res.found || res.food == null) {
      return Container(
        key: const Key('barcode_error_card'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.warning),
        ),
        child: Text(
          res.message ?? 'Barcode not found.',
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 12,
            color: tokens.warning,
          ),
        ),
      );
    }

    final food = res.food!;
    return Container(
      key: const Key('barcode_result_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.cyanAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            food.name,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${food.caloriesPer100g.toStringAsFixed(0)} kcal / 100g · '
            'P ${food.proteinPer100g.toStringAsFixed(1)}g · '
            'C ${food.carbsPer100g.toStringAsFixed(1)}g · '
            'F ${food.fatPer100g.toStringAsFixed(1)}g',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 12,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Serving: ${food.servingDescription} · Source: ${food.source}',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 11,
              color: tokens.cyanAccent,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('barcode_select_food_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.kineticAccent,
                foregroundColor: tokens.onAccent,
              ),
              onPressed: () => widget.onFoodFound(food),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('SELECT & SET PORTION'),
            ),
          ),
        ],
      ),
    );
  }
}
