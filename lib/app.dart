import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/powered_by_footer.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/explore_screen.dart';
import 'screens/user/search_screen.dart';
import 'screens/user/event_detail_screen.dart';
import 'screens/user/seat_selection_screen.dart';
import 'screens/user/checkout_screen.dart';
import 'screens/user/booking_confirmation_screen.dart';
import 'screens/user/my_tickets_screen.dart';
import 'screens/user/ticket_detail_screen.dart';
import 'screens/user/favorites_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_events_screen.dart';
import 'screens/admin/admin_add_edit_event_screen.dart';
import 'screens/admin/admin_bookings_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_venues_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';

class EventBookingApp extends StatelessWidget {
  const EventBookingApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/register', builder: (_, __) => const RegisterScreen()),

      // ─── User Shell (Bottom Nav) ──────────────────
      ShellRoute(
        builder: (context, state, child) =>
            _UserShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/explore',
              builder: (_, __) => const ExploreScreen()),
          GoRoute(
              path: '/tickets',
              builder: (_, __) => const MyTicketsScreen()),
          GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ─── Standalone User Routes ───────────────────
      GoRoute(
          path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(
        path: '/event/:id',
        builder: (_, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/seats/:eventId',
        builder: (_, state) =>
            SeatSelectionScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
          path: '/checkout',
          builder: (_, __) => const CheckoutScreen()),
      GoRoute(
          path: '/booking-confirmation',
          builder: (_, __) => const BookingConfirmationScreen()),
      GoRoute(
        path: '/ticket/:id',
        builder: (_, state) =>
            TicketDetailScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: '/favorites',
          builder: (_, __) => const FavoritesScreen()),

      // ─── Admin Shell (Bottom Nav) ────────────────
      ShellRoute(
        builder: (context, state, child) => _AdminShell(child: child),
        routes: [
          GoRoute(
              path: '/admin/dashboard',
              builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(
              path: '/admin/events',
              builder: (_, __) => const AdminEventsScreen()),
          GoRoute(
              path: '/admin/bookings',
              builder: (_, __) => const AdminBookingsScreen()),
          GoRoute(
              path: '/admin/users',
              builder: (_, __) => const AdminUsersScreen()),
          GoRoute(
              path: '/admin/analytics',
              builder: (_, __) => const AdminAnalyticsScreen()),
        ],
      ),

      // ─── Admin standalone routes ─────────────────
      GoRoute(
          path: '/admin/venues',
          builder: (_, __) => const AdminVenuesScreen()),
      GoRoute(
        path: '/admin/events/add',
        builder: (_, __) => const AdminAddEditEventScreen(),
      ),
      GoRoute(
        path: '/admin/events/edit/:id',
        builder: (_, state) => AdminAddEditEventScreen(
            eventId: state.pathParameters['id']),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AuthProvider, ThemeMode>(
        (auth) => auth.themeMode);
    return MaterialApp.router(
      title: 'EventBooking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}

// ─── User Bottom Navigation Shell ────────────────────────────────────────────
class _UserShell extends StatelessWidget {
  final Widget child;
  const _UserShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex: _calculateIndex(GoRouterState.of(context).uri.toString()),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/explore');
                  break;
                case 2:
                  context.go('/tickets');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: 'Tickets',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          const PoweredByFooter(),
        ],
      ),
    );
  }

  int _calculateIndex(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/tickets')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}

// ─── Admin Bottom Navigation Shell ───────────────────────────────────────────
class _AdminShell extends StatelessWidget {
  final Widget child;
  const _AdminShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex:
                _calculateIndex(GoRouterState.of(context).uri.toString()),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/admin/dashboard');
                  break;
                case 1:
                  context.go('/admin/events');
                  break;
                case 2:
                  context.go('/admin/bookings');
                  break;
                case 3:
                  context.go('/admin/users');
                  break;
                case 4:
                  context.go('/admin/analytics');
                  break;
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event),
                label: 'Events',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_outlined),
                selectedIcon: Icon(Icons.receipt),
                label: 'Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
            ],
          ),
          const PoweredByFooter(),
        ],
      ),
    );
  }

  int _calculateIndex(String location) {
    if (location.startsWith('/admin/events')) return 1;
    if (location.startsWith('/admin/bookings')) return 2;
    if (location.startsWith('/admin/users')) return 3;
    if (location.startsWith('/admin/analytics')) return 4;
    return 0;
  }
}
