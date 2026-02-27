import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
      Permission.phone,
      Permission.systemAlertWindow,
      Permission.notification,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    
    // Accessibility Service and Background Service typically require manual enablement
    // but we can check if they are needed or guide the user.
    
    return allGranted;
  }

  static Future<bool> checkPermission(Permission permission) async {
    return await permission.isGranted;
  }
}
