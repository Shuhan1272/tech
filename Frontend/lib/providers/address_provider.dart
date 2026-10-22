import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// NEW. The "Address" row on the Profile screen had an empty onTap —
/// tapping it did nothing at all. This backs the new AddressScreen and
/// correctly distinguishes create vs. update: the backend's Address is
/// one-per-user, so saving must POST the first time and PUT every time
/// after. The old (unused) saveAddress() only ever POSTed, so any edit
/// would have been rejected.
class AddressProvider extends ChangeNotifier {
  Map<String, dynamic>? address;
  bool isLoading = false;
  String? errorMessage;

  bool get hasAddress => address != null && address!['id'] != null;

  Future<void> loadAddress() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      address = await AuthService.getAddress();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveAddress(Map<String, dynamic> input) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (hasAddress) {
        address = await AuthService.updateAddress(address!['id'], input);
      } else {
        address = await AuthService.createAddress(input);
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress() async {
    if (!hasAddress) return false;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await AuthService.deleteAddress(address!['id']);
      address = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
