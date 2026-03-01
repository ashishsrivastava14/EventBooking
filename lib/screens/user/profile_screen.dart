import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_image.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/event_provider.dart';

// ── Mock payment card model ──────────────────────────────────────────────────
class _PaymentCard {
  final String brand;
  final String last4;
  final String expiry;
  final IconData icon;
  bool isDefault;
  _PaymentCard({
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.icon,
    this.isDefault = false,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock payment cards — in a real app these come from a backend.
  final List<_PaymentCard> _cards = [
    _PaymentCard(
        brand: 'Visa',
        last4: '4242',
        expiry: '12/26',
        icon: Icons.credit_card,
        isDefault: true),
    _PaymentCard(
        brand: 'Mastercard',
        last4: '5555',
        expiry: '08/25',
        icon: Icons.credit_card),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final bookingProv = context.watch<BookingProvider>();
    final upcomingCount = bookingProv.upcomingBookings.length;
    final pastCount = bookingProv.pastBookings.length;
    final wishlistCount =
        context.watch<EventProvider>().favoriteIds.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Avatar + info with gradient header card ─────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF1A2B4E), Color(0xFF0D1432)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : AppColors.cardGradientLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF026CDF).withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF026CDF).withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      // Avatar with gradient border ring
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: user != null
                              ? appImageProvider(user.avatarUrl)
                              : null,
                          child: user == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Guest',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'guest@app.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem('$upcomingCount', 'Upcoming'),
                        _statItem('$pastCount', 'Attended'),
                        _statItem('$wishlistCount', 'Wishlist'),
                      ],
                    ),
                  ],
                ),
              ),
              ),

              const SizedBox(height: 24),

              // ── Edit profile ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showEditProfile(context, auth),
                  child: const Text('Edit Profile'),
                ),
              ),

              const SizedBox(height: 24),

              // ── Menu items ─────────────────────────────────────────────
              _menuItem(context, Icons.confirmation_number_outlined,
                  'My Bookings', () => context.push('/tickets')),
              _menuItem(context, Icons.credit_card, 'Payment Methods',
                  () => _showPaymentMethods(context)),
              _menuItem(context, Icons.favorite_border, 'Favorites',
                  () => context.push('/favorites')),

              const SizedBox(height: 16),

              // ── Notification settings ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient:
                      isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Settings',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SwitchListTile(
                      title: const Text('Push Notifications',
                          style: TextStyle(fontSize: 14)),
                      value: auth.pushNotifications,
                      onChanged: (v) => auth.updateNotificationSettings(
                        push: v,
                        email: auth.emailNotifications,
                      ),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Email Notifications',
                          style: TextStyle(fontSize: 14)),
                      value: auth.emailNotifications,
                      onChanged: (v) => auth.updateNotificationSettings(
                        push: auth.pushNotifications,
                        email: v,
                      ),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _menuItem(context, Icons.help_outline, 'Help & Support',
                  () => _showHelpSupport(context)),

              // ── Dark Mode toggle ───────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient:
                      isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  value: auth.themeMode == ThemeMode.dark,
                  onChanged: (_) => auth.toggleTheme(),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 16),

              // ── Logout ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout'),
                        content:
                            const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await auth.logout();
                      if (!context.mounted) return;
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
          blendMode: BlendMode.srcIn,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _menuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
              blendMode: BlendMode.srcIn,
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Text(title, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Edit Profile sheet ─────────────────────────────────────────────────────

  void _showEditProfile(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final nameCtrl =
        TextEditingController(text: user?.fullName ?? '');
    final phoneCtrl =
        TextEditingController(text: user?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await auth.updateProfile(
                        nameCtrl.text.trim(), phoneCtrl.text.trim());
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Payment Methods sheet ──────────────────────────────────────────────────

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final isDark =
              Theme.of(ctx).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Payment Methods',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add New'),
                      onPressed: () =>
                          _showAddCardDialog(ctx, setSheet),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No payment methods added.',
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight)),
                    ),
                  )
                else
                  ...List.generate(_cards.length, (i) {
                    final card = _cards[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.card
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: card.isDefault
                            ? Border.all(
                                color: AppColors.primary, width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(card.icon,
                              color: AppColors.primary, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${card.brand} •••• ${card.last4}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text('Expires ${card.expiry}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors
                                                .textSecondaryLight)),
                              ],
                            ),
                          ),
                          if (card.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: const Text('Default',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            )
                          else
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  size: 20),
                              onSelected: (v) {
                                if (v == 'default') {
                                  setSheet(() {
                                    for (final c in _cards) {
                                      c.isDefault = false;
                                    }
                                    card.isDefault = true;
                                  });
                                } else if (v == 'remove') {
                                  setSheet(
                                      () => _cards.removeAt(i));
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'default',
                                    child: Text('Set as Default')),
                                PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remove')),
                              ],
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddCardDialog(
      BuildContext context, StateSetter setSheet) {
    final numberCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark =
            Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.card : AppColors.cardLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Card',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Cardholder Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: numberCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    decoration: const InputDecoration(
                        labelText: 'Card Number',
                        counterText: ''),
                    validator: (v) =>
                        (v == null || v.length < 13) ? 'Invalid' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: expiryCtrl,
                        decoration: const InputDecoration(
                            labelText: 'MM/YY'),
                        validator: (v) =>
                            (v == null || v.length < 5)
                                ? 'Invalid'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: cvvCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'CVV', counterText: ''),
                        validator: (v) =>
                            (v == null || v.length < 3)
                                ? 'Invalid'
                                : null,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final last4 = numberCtrl.text.length >= 4
                    ? numberCtrl.text
                        .substring(numberCtrl.text.length - 4)
                    : numberCtrl.text;
                setSheet(() {
                  _cards.add(_PaymentCard(
                    brand: 'Card',
                    last4: last4,
                    expiry: expiryCtrl.text,
                    icon: Icons.credit_card,
                    isDefault: _cards.isEmpty,
                  ));
                });
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card added!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Add Card'),
            ),
          ],
        );
      },
    );
  }

  // ── Help & Support sheet ───────────────────────────────────────────────────

  void _showHelpSupport(BuildContext context) {
    const faqs = [
      (
        q: 'How do I cancel a booking?',
        a:
            'Go to My Tickets, open the ticket, and tap "Cancel Booking". Cancellations are allowed up to 24 hours before the event.'
      ),
      (
        q: 'How do I transfer a ticket?',
        a:
            'Open the ticket from My Tickets, tap "Transfer Ticket", and enter the recipient\'s email address.'
      ),
      (
        q: 'When will I receive my refund?',
        a:
            'Refunds are processed within 5–7 business days back to the original payment method.'
      ),
      (
        q: 'Can I change my seat after booking?',
        a:
            'Seat changes are not currently supported. Please cancel and rebook if needed.'
      ),
      (
        q: 'How do I contact support?',
        a: 'Email us at support@eventbooking.app or use the chat below.'
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          builder: (_, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const Text('Help & Support',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 16),
              ...faqs.map((faq) => _FaqTile(
                    question: faq.q,
                    answer: faq.a,
                    isDark: isDark,
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email Support',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text('support@eventbooking.app',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy,
                          size: 18, color: AppColors.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Email copied!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── FAQ expandable tile ────────────────────────────────────────────────────────
class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDark;
  const _FaqTile(
      {required this.question,
      required this.answer,
      required this.isDark});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.card : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(widget.question,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          trailing: Icon(
              _expanded ? Icons.remove : Icons.add,
              size: 20),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.answer,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: widget.isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)),
            ),
          ],
        ),
      ),
    );
  }
}
