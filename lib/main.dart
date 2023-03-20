import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:groen/ui/list_page.dart';
import 'package:groen/ui/settings_page.dart';
import 'package:groen/ui/two_state_future_builder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'groeN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: Permission.manageExternalStorage.isGranted,
        builder: (context, grantedSnapshot) {
          if (!grantedSnapshot.hasData) {
            return Text('loading');
          }
          if (grantedSnapshot.data ?? false) {
            return buildApp();
          } else {
            return TwoStateFutureBuilder<PermissionStatus>(
              future: Permission.manageExternalStorage.request(),
              builder: (context, status) {
                if (status.isDenied || status.isPermanentlyDenied) {
                  return const Text('bi siktir git');
                }
                return buildApp();
              },
            );
          }
        },
      ),
    );
  }

  FutureBuilder<SharedPreferences> buildApp() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, prefsSnapshot) {
        if (!prefsSnapshot.hasData || prefsSnapshot.data == null) {
          return const CircularProgressIndicator();
        }
        final prefs = prefsSnapshot.data!;
        if (prefs.getString('root_directory') == null) {
          return const SettingsPage();
        }
        return const ListPage();
      },
    );
  }
}
