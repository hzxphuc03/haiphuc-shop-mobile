import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimization: Only read the router once. 
    // Since we optimized routerProvider to be stable, this is safe and prevents 
    // the entire MaterialApp from being even considered for rebuilds by Riverpod 
    // unless the routerProvider itself (the instance) changes.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HAIPHUC SHOP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFD2FF1F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD2FF1F),
          secondary: Color(0xFFFF0000),
        ),
        // Optimization: Use standard typography to avoid font-loading jank on startup
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
