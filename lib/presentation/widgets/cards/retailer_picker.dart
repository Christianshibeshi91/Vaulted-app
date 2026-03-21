import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/retailers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Searchable grid of retailers for the add-card flow.
class RetailerPicker extends StatefulWidget {
  final ValueChanged<Retailer> onSelected;

  const RetailerPicker({super.key, required this.onSelected});

  @override
  State<RetailerPicker> createState() => _RetailerPickerState();
}

class _RetailerPickerState extends State<RetailerPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  List<Retailer> get _filtered {
    if (_query.isEmpty) return Retailers.all;
    return Retailers.all
        .where((r) => r.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Retailer', style: VaultedTypography.headlineMedium),
        VaultedSpacing.gapMd,

        // Search field
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          style: VaultedTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search retailers...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
        ),
        VaultedSpacing.gapLg,

        // Grid
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Text(
                    'No retailers found',
                    style: VaultedTypography.secondary(
                        VaultedTypography.bodyMedium),
                  ),
                )
              : GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: VaultedSpacing.md,
                    crossAxisSpacing: VaultedSpacing.md,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final retailer = _filtered[index];
                    return _RetailerTile(
                      retailer: retailer,
                      index: index,
                      onTap: () {
                        Haptics.lightTap();
                        widget.onSelected(retailer);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RetailerTile extends StatelessWidget {
  final Retailer retailer;
  final int index;
  final VoidCallback onTap;

  const _RetailerTile({
    required this.retailer,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brCard,
          border: Border.all(color: VaultedColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: retailer.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  retailer.name[0].toUpperCase(),
                  style: VaultedTypography.headlineMedium.copyWith(
                    color: retailer.color,
                  ),
                ),
              ),
            ),
            VaultedSpacing.gapSm,
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xs),
              child: Text(
                retailer.name,
                style: VaultedTypography.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 200.ms,
          delay: (30 * (index % 9)).ms,
          curve: Curves.easeOut,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 200.ms,
          delay: (30 * (index % 9)).ms,
          curve: Curves.easeOut,
        );
  }
}
