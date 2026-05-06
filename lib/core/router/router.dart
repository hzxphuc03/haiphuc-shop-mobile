import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth/auth_provider.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/product_detail_screen.dart';
import '../../presentation/screens/cart_screen.dart';
import '../../presentation/screens/checkout_screen.dart';
import '../../presentation/screens/order_history_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/order_success_screen.dart';
import '../../presentation/widgets/main_layout.dart';
import '../../data/models/product_model.dart';

// Optimization: Use a dedicated Listenable that only triggers on LOGIN/LOGOUT
// This prevents the Router (and thus the whole App) from rebuilding when 'isLoading' or 'error' changes.
class AuthRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool? _isLoggedIn;

  AuthRouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final isLoggedIn = next.user != null;
      if (_isLoggedIn != isLoggedIn) {
        _isLoggedIn = isLoggedIn;
        notifyListeners(); // Only notify when authentication status actually flips
      }
    });
  }
}

final authRouterNotifierProvider = Provider((ref) => AuthRouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(authRouterNotifierProvider);
  
  // Use a reference to the notifier but DO NOT watch the full authProvider here.
  // We only want to rebuild the router structure if the notifier tells us to.
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      // Use ref.read instead of ref.watch to avoid subscription inside redirect logic
      final auth = ref.read(authProvider);
      final isLoggingIn = state.matchedLocation == '/login';
      final isLoggedIn = auth.user != null;

      if (!auth.isInitialized) return null;
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainLayout(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/orders', builder: (context, state) => const OrderHistoryScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/cart', builder: (context, state) => const CartScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        pageBuilder: (context, state) {
          final product = state.extra as ProductModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(product: product),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(path: '/order-success', builder: (context, state) => const OrderSuccessScreen()),
    ],
  );
});
