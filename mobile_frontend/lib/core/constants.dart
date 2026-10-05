class ApiConstants {
  // Single source of truth for the API root. Every service builds its
  // endpoint paths off this instead of hardcoding its own host/prefix
  // (previously auth_service.dart and product_service.dart pointed at two
  // different hosts AND different version prefixes — that mismatch is
  // fixed by centralizing it here).
  //
  // ASSUMPTION: your root urls.py versions everything under /api/v1/
  // (matching what auth_service.dart already had for accounts). If your
  // products app isn't under /api/v1/products/, update the paths used in
  // product_service.dart.
  //
  // Android emulator -> maps to your PC's own localhost.
  static const String baseUrl = "http://10.0.2.2:8000/api/v1";

// Swap to one of these depending on how you're running the app:
// Chrome / Windows desktop app -> "http://127.0.0.1:8000/api/v1"
// Physical device over WiFi     -> "http://<YOUR_PC_LAN_IP>:8000/api/v1"
//   (find your IP with `ipconfig`, and run Django with:
//   python manage.py runserver 0.0.0.0:8000)
}
