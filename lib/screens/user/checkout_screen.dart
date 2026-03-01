import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/powered_by_footer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/cart_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _promoController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isProcessing = false;
  String _cardNumber = '';
  String _cardHolder = '';
  String _cardExpiry = '';
  String _cardCvv = '';

  final List<String> _paymentMethods = [
    'Credit Card',
    'UPI',
    'Net Banking',
    'Wallet'
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final eventProv = context.watch<EventProvider>();
    final event = eventProv.getEventById(cart.eventId ?? '');

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: AppBackground(child: const Center(child: Text('No items in cart'))),
      );
    }

    return Scaffold(
      bottomNavigationBar: const PoweredByFooter(),
      appBar: AppBar(title: const Text('Checkout')),
      body: AppBackground(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Booking Summary ────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _summaryRow('Event', event.title),
                  _summaryRow('Date',
                      '${_monthName(event.date.month)} ${event.date.day}, ${event.date.year}'),
                  _summaryRow('Time', event.time),
                  _summaryRow('Venue', event.venueName),
                  _summaryRow('Tier', cart.tierName ?? ''),
                  _summaryRow('Seats', cart.selectedSeats.join(', ')),
                  _summaryRow('Quantity', '${cart.seatCount}'),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 16),

            // ─── Promo Code ─────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Promo Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: const InputDecoration(
                            hintText: 'Enter promo code',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final success =
                              cart.applyPromoCode(_promoController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? '10% discount applied!'
                                  : 'Invalid promo code. Try SAVE10'),
                              backgroundColor:
                                  success ? AppColors.success : AppColors.error,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  if (cart.promoCode.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Code "${cart.promoCode}" applied',
                            style: const TextStyle(
                                color: AppColors.success, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Price Breakdown ────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _priceRow('Subtotal (${cart.seatCount} × \$${cart.tierPrice.toStringAsFixed(2)})',
                      '\$${cart.subtotal.toStringAsFixed(2)}'),
                  _priceRow('Service Fee (10%)',
                      '\$${cart.serviceFee.toStringAsFixed(2)}'),
                  if (cart.discount > 0)
                    _priceRow('Discount', '-\$${cart.discount.toStringAsFixed(2)}',
                        color: AppColors.success),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '\$${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Payment Method ─────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map((method) {
                    final isSelected = cart.paymentMethod == method;
                    IconData icon;
                    switch (method) {
                      case 'Credit Card':
                        icon = Icons.credit_card;
                        break;
                      case 'UPI':
                        icon = Icons.account_balance;
                        break;
                      case 'Net Banking':
                        icon = Icons.language;
                        break;
                      default:
                        icon = Icons.account_balance_wallet;
                    }
                    return GestureDetector(
                      onTap: () => cart.setPaymentMethod(method),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(icon,
                                color: isSelected
                                    ? AppColors.primary
                                    : null),
                            const SizedBox(width: 12),
                            Text(method),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ─── Card Details (if Credit Card) ─────
            if (cart.paymentMethod == 'Credit Card') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isDark ? AppColors.cardGradient : AppColors.cardGradientLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card preview
                    Container(
                      width: double.infinity,
                      height: 180,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.credit_card,
                                  color: Colors.white, size: 32),
                              const Text('VISA',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Text(
                            _cardNumber.isEmpty
                                ? '•••• •••• •••• ••••'
                                : _cardNumber.padRight(16, '•').replaceAllMapped(
                                    RegExp(r'.{4}'),
                                    (m) => '${m.group(0)} '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CARD HOLDER',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 10)),
                                  Text(
                                    _cardHolder.isEmpty
                                        ? 'YOUR NAME'
                                        : _cardHolder.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('EXPIRES',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 10)),
                                  Text(
                                    _cardExpiry.isEmpty
                                        ? 'MM/YY'
                                        : _cardExpiry,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration:
                          const InputDecoration(hintText: 'Card Number'),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      onChanged: (v) => setState(() => _cardNumber = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration:
                          const InputDecoration(hintText: 'Card Holder Name'),
                      onChanged: (v) => setState(() => _cardHolder = v),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration:
                                const InputDecoration(hintText: 'MM/YY'),
                            onChanged: (v) =>
                                setState(() => _cardExpiry = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration:
                                const InputDecoration(hintText: 'CVV'),
                            obscureText: true,
                            maxLength: 3,
                            onChanged: (v) => setState(() => _cardCvv = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Terms
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (v) =>
                        setState(() => _agreeToTerms = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Service and Refund Policy',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'Confirm & Pay \$${cart.total.toStringAsFixed(2)}',
              onPressed: _agreeToTerms
                  ? () => _processPayment(context, cart, event)
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please agree to Terms of Service'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
              isLoading: _isProcessing,
            ),
            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _processPayment(
      BuildContext context, CartProvider cart, dynamic event) async {
    // Validate CVV if credit card selected
    if (cart.paymentMethod == 'Credit Card' && _cardCvv.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 3-digit CVV'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Capture providers synchronously before any async gap
    final auth = context.read<AuthProvider>();
    final bookingProv = context.read<BookingProvider>();

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    bookingProv.createBooking(
      userId: auth.currentUser?.id ?? 'u_new',
      userName: auth.currentUser?.fullName ?? 'Guest',
      userEmail: auth.currentUser?.email ?? 'guest@app.com',
      eventId: event.id,
      eventTitle: event.title,
      eventImageUrl: event.imageUrl,
      venue: event.venueName,
      eventDate: event.date,
      tierName: cart.tierName ?? '',
      seats: List.from(cart.selectedSeats),
      subtotal: cart.subtotal,
      serviceFee: cart.serviceFee,
      discount: cart.discount,
      total: cart.total,
      promoCode: cart.promoCode,
      paymentMethod: cart.paymentMethod,
    );

    cart.clearCart();
    setState(() => _isProcessing = false);
    if (!context.mounted) return;
    context.go('/booking-confirmation');
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }
}
