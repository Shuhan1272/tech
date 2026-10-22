import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../core/app_theme.dart';
import '../core/snackbar_helper.dart';
import '../widgets/primary_button.dart';

/// NEW SCREEN. "Address" on the profile menu had an empty onTap. Your
/// backend has a full Address ViewSet (list/create/update/delete) that
/// the app had no way to reach at all.
///
/// Address is a OneToOneField on the backend, so this is "your one
/// shipping address" — create it if absent, update it if present.
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _company = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _city = TextEditingController();
  final _postalCode = TextEditingController();
  final _region = TextEditingController();
  final _country = TextEditingController(text: 'Bangladesh');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<AddressProvider>();
    await provider.loadAddress();
    final address = provider.address;
    if (address != null && mounted) {
      _firstName.text = address['first_name']?.toString() ?? '';
      _lastName.text = address['last_name']?.toString() ?? '';
      _company.text = address['company']?.toString() ?? '';
      _address1.text = address['address1']?.toString() ?? '';
      _address2.text = address['address2']?.toString() ?? '';
      _city.text = address['city']?.toString() ?? '';
      _postalCode.text = address['postal_code']?.toString() ?? '';
      _region.text = address['region']?.toString() ?? '';
      _country.text = address['country']?.toString() ?? 'Bangladesh';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _company.dispose();
    _address1.dispose();
    _address2.dispose();
    _city.dispose();
    _postalCode.dispose();
    _region.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AddressProvider>();
    final success = await provider.saveAddress({
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      'company': _company.text.trim(),
      'address1': _address1.text.trim(),
      'address2': _address2.text.trim(),
      'city': _city.text.trim(),
      'postal_code': _postalCode.text.trim(),
      'country': _country.text.trim(),
      'region': _region.text.trim(),
    });
    if (!mounted) return;
    if (success) {
      AppSnackbar.showSuccess(context, 'Address saved');
    } else {
      AppSnackbar.showError(context, provider.errorMessage ?? 'Could not save address');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove address?'),
        content: const Text('Your saved shipping address will be deleted.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<AddressProvider>();
    final success = await provider.deleteAddress();
    if (!mounted) return;
    if (success) {
      _firstName.clear();
      _lastName.clear();
      _company.clear();
      _address1.clear();
      _address2.clear();
      _city.clear();
      _postalCode.clear();
      _region.clear();
      _country.text = 'Bangladesh';
      setState(() {});
      AppSnackbar.showSuccess(context, 'Address removed');
    } else {
      AppSnackbar.showError(context, provider.errorMessage ?? 'Could not remove address');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Address'),
        actions: [
          if (provider.hasAddress)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _confirmDelete),
        ],
      ),
      body: provider.isLoading && !provider.hasAddress
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'First Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Last Name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // company/address2 are blank=True on your model, so
                // they're correctly optional here.
                TextFormField(
                  controller: _company,
                  decoration: const InputDecoration(labelText: 'Company (optional)'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _address1,
                  decoration: const InputDecoration(
                    labelText: 'Address Line 1',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _address2,
                  decoration: const InputDecoration(labelText: 'Address Line 2 (optional)'),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _city,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _postalCode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Postal Code'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _region,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Region / District'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _country,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: provider.hasAddress ? 'Update Address' : 'Save Address',
                  isLoading: provider.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
