import 'package:biddabari_software/routes/app_pages.dart';
import 'package:biddabari_software/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();



  final connectivityService = await Get.putAsync<ConnectivityService>(
        () => ConnectivityService().init(),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Biddabari Courses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E8E3E),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
