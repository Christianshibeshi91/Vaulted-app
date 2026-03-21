import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/retailers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/encryption.dart';
import '../../../core/utils/secure_storage.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import 'retailer_picker.dart';

/// Bottom sheet for adding a new gift card to the vault.
class AddCardSheet extends StatefulWidget {
  const AddCardSheet({super.key});

  /// Show the sheet and return `true` if a card was added.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultedColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(VaultedRadii.bottomSheet),
        ),
      ),
      builder: (_) => const AddCardSheet(),
    );
  }

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _pinController = TextEditingController();
  final _balanceController = TextEditingController();
  final _notesController = TextEditingController();

  Retailer? _selectedRetailer;
  DateTime? _expirationDate;
  bool _isLoading = false;
  bool _showForm = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _pinController.dispose();
    _balanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: VaultedColors.accentGold,
              onPrimary: VaultedColors.bgPrimary,
              surface: VaultedColors.bgSecondary,
              onSurface: VaultedColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRetailer == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final balance =
          double.tryParse(_balanceController.text.trim()) ?? 0.0;
      final now = DateTime.now();
      final id = const Uuid().v4();

      final cardData = <String, dynamic>{
        'id': id,
        'retailer': _selectedRetailer!.name,
        'retailerColor':
            '#${_selectedRetailer!.color.toARGB32().toRadixString(16).substring(2)}',
        'balance': balance,
        'originalBalance': balance,
        'currency': 'USD',
        'status': 'active',
        'addedVia': 'manual',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final encryptionService = EncryptionService(SecureStorageService.instance);
      await encryptionService.initialise();

      final cardNumber = _cardNumberController.text.trim();
      if (cardNumber.isNotEmpty) {
        cardData['cardNumberEncrypted'] = encryptionService.encrypt(cardNumber);
      }

      final pin = _pinController.text.trim();
      if (pin.isNotEmpty) {
        cardData['pinEncrypted'] = encryptionService.encrypt(pin);
      }

      final notes = _notesController.text.trim();
      if (notes.isNotEmpty) {
        cardData['notes'] = notes;
      }

      if (_expirationDate != null) {
        cardData['expirationDate'] = Timestamp.fromDate(_expirationDate!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cards')
          .doc(id)
          .set(cardData);

      await Haptics.success();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Card added to your vault',
              style: VaultedTypography.bodyMedium.copyWith(
                color: VaultedColors.textPrimary,
              ),
            ),
            backgroundColor: VaultedColors.bgCard,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      await Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add card',
              style: VaultedTypography.bodyMedium.copyWith(
                color: VaultedColors.danger,
              ),
            ),
            backgroundColor: VaultedColors.bgCard,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: VaultedSpacing.xl,
            right: VaultedSpacing.xl,
            top: VaultedSpacing.md,
            bottom: bottomPadding + VaultedSpacing.xxxl,
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: VaultedColors.textMuted,
                  borderRadius: VaultedRadii.brPill,
                ),
              ),
              VaultedSpacing.gapLg,

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _showForm ? 'Card Details' : 'Add Card',
                    style: VaultedTypography.headlineLarge,
                  ),
                  if (_showForm)
                    TextButton(
                      onPressed: () =>
                          setState(() => _showForm = false),
                      child: const Text('Back'),
                    ),
                ],
              ),
              VaultedSpacing.gapLg,

              // Content
              Expanded(
                child: _showForm ? _buildForm() : _buildPicker(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPicker() {
    return RetailerPicker(
      onSelected: (retailer) {
        setState(() {
          _selectedRetailer = retailer;
          _showForm = true;
        });
      },
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          // Selected retailer display
          if (_selectedRetailer != null)
            Container(
              padding: VaultedSpacing.cardInner,
              decoration: BoxDecoration(
                color: VaultedColors.bgCard,
                borderRadius: VaultedRadii.brCard,
                border: Border.all(color: VaultedColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedRetailer!.color
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _selectedRetailer!.name[0].toUpperCase(),
                        style:
                            VaultedTypography.headlineMedium.copyWith(
                          color: _selectedRetailer!.color,
                        ),
                      ),
                    ),
                  ),
                  VaultedSpacing.gapHMd,
                  Text(
                    _selectedRetailer!.name,
                    style: VaultedTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms, curve: Curves.easeOut),
          VaultedSpacing.gapLg,

          // Card Number
          TextFormField(
            controller: _cardNumberController,
            style: VaultedTypography.monoMedium,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: 'Enter card number',
              prefixIcon: Icon(Icons.credit_card, size: 20),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
            ],
          ),
          VaultedSpacing.gapLg,

          // PIN
          TextFormField(
            controller: _pinController,
            style: VaultedTypography.monoMedium,
            decoration: const InputDecoration(
              labelText: 'PIN',
              hintText: 'Enter PIN (if applicable)',
              prefixIcon: Icon(Icons.lock_outline, size: 20),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
          ),
          VaultedSpacing.gapLg,

          // Balance
          TextFormField(
            controller: _balanceController,
            style: VaultedTypography.gold(VaultedTypography.monoLarge),
            decoration: const InputDecoration(
              labelText: 'Balance *',
              hintText: '0.00',
              prefixIcon: Icon(Icons.attach_money, size: 20),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Balance is required';
              }
              final parsed = double.tryParse(value.trim());
              if (parsed == null || parsed < 0) {
                return 'Enter a valid amount';
              }
              return null;
            },
          ),
          VaultedSpacing.gapLg,

          // Expiration Date
          GestureDetector(
            onTap: _pickExpirationDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Expiration Date',
                prefixIcon: Icon(Icons.calendar_today, size: 20),
              ),
              child: Text(
                _expirationDate != null
                    ? '${_expirationDate!.month}/${_expirationDate!.year}'
                    : 'No expiration',
                style: _expirationDate != null
                    ? VaultedTypography.bodyLarge
                    : VaultedTypography.muted(
                        VaultedTypography.bodyLarge),
              ),
            ),
          ),
          VaultedSpacing.gapLg,

          // Notes
          TextFormField(
            controller: _notesController,
            style: VaultedTypography.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional notes...',
              prefixIcon: Icon(Icons.notes, size: 20),
            ),
            maxLines: 2,
            maxLength: 250,
          ),
          VaultedSpacing.gapXxl,

          // Submit button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: VaultedColors.bgPrimary,
                      ),
                    )
                  : Text(
                      'Add to Vault',
                      style: VaultedTypography.buttonLabel(),
                    ),
            ),
          ),
          VaultedSpacing.gapXxl,
        ],
      ),
    );
  }
}
