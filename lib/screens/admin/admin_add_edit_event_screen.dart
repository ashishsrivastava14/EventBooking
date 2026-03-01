import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/powered_by_footer.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../providers/admin_provider.dart';
import '../../models/event_model.dart';
import '../../models/ticket_model.dart';

class AdminAddEditEventScreen extends StatefulWidget {
  final String? eventId;
  const AdminAddEditEventScreen({super.key, this.eventId});

  @override
  State<AdminAddEditEventScreen> createState() =>
      _AdminAddEditEventScreenState();
}

class _AdminAddEditEventScreenState extends State<AdminAddEditEventScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final PageController _pageCtrl;
  late final AnimationController _animCtrl;
  int _currentStep = 0;

  // Step 1: Basic info
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  String _category = 'Concerts';
  DateTime _date = DateTime.now().add(const Duration(days: 30));
  final _timeCtrl = TextEditingController(text: '7:00 PM');

  // Step 2: Venue
  final _venueNameCtrl = TextEditingController();
  final _venueIdCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Step 3: Ticket tiers
  final List<Map<String, dynamic>> _tiers = [
    {'name': 'General', 'price': 50.0, 'qty': 100},
  ];

  bool _isEdit = false;
  EventModel? _existing;

  static const _categories = [
    ('Concerts', Icons.music_note_rounded),
    ('Sports', Icons.sports_soccer_rounded),
    ('Theatre', Icons.theater_comedy_rounded),
    ('Comedy', Icons.sentiment_very_satisfied_rounded),
    ('Festivals', Icons.celebration_rounded),
    ('Family', Icons.family_restroom_rounded),
  ];

  static const _tierColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    if (widget.eventId != null) {
      _isEdit = true;
      final admin = context.read<AdminProvider>();
      _existing = admin.events
          .where((e) => e.id == widget.eventId)
          .firstOrNull;
      if (_existing != null) {
        _titleCtrl.text = _existing!.title;
        _descCtrl.text = _existing!.description;
        _imageUrlCtrl.text = _existing!.imageUrl;
        _category = _existing!.category;
        _date = _existing!.date;
        _timeCtrl.text = _existing!.time;
        _venueNameCtrl.text = _existing!.venueName;
        _venueIdCtrl.text = _existing!.venueId;
        _cityCtrl.text = _existing!.city;
        _addressCtrl.text = '';
        _tiers.clear();
        for (var t in _existing!.ticketTiers) {
          _tiers.add({
            'name': t.name,
            'price': t.price,
            'qty': t.totalQuantity,
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    _timeCtrl.dispose();
    _venueNameCtrl.dispose();
    _venueIdCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _next() {
    if (_currentStep < 2) {
      if (_formKey.currentState!.validate()) _goToStep(_currentStep + 1);
    } else {
      _saveEvent();
    }
  }

  void _back() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: const PoweredByFooter(),
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(context, isDark),
              _buildStepIndicator(isDark),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(isDark, size),
                    _buildStep2(isDark, size),
                    _buildStep3(isDark, size),
                  ],
                ),
              ),
              _buildActionBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF026CDF), Color(0xFF0148A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEdit ? 'Edit Event' : 'Create New Event',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      _isEdit
                          ? 'Update event details'
                          : 'Fill in the details to publish',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step ${_currentStep + 1}/3',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Step Indicator ────────────────────────────────────────────────────────

  Widget _buildStepIndicator(bool isDark) {
    const steps = [
      ('Basic Info', Icons.info_outline_rounded),
      ('Venue', Icons.location_on_outlined),
      ('Tickets', Icons.confirmation_number_outlined),
    ];
    return Container(
      color: isDark ? AppColors.surface : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final filled = _currentStep > i ~/ 2;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                decoration: BoxDecoration(
                  gradient: filled ? AppColors.primaryGradient : null,
                  color: filled
                      ? null
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final idx = i ~/ 2;
          final (label, icon) = steps[idx];
          final isActive = _currentStep == idx;
          final isDone = _currentStep > idx;
          return GestureDetector(
            onTap: () { if (idx < _currentStep) _goToStep(idx); },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive || isDone ? AppColors.primaryGradient : null,
                    color: isActive || isDone
                        ? null
                        : (isDark ? AppColors.card : Colors.grey.shade100),
                    boxShadow: isActive
                        ? [BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12, offset: const Offset(0, 4))]
                        : null,
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : icon,
                    size: 18,
                    color: isActive || isDone
                        ? Colors.white
                        : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade500),
                )),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Step 1: Basic Info ────────────────────────────────────────────────────

  Widget _buildStep1(bool isDark, Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          _buildImagePreview(isDark),
          const SizedBox(height: 16),
          _sectionCard(isDark,
              icon: Icons.edit_note_rounded,
              title: 'Event Details',
              accent: AppColors.primary,
              child: Column(children: [
                _fancyField(
                  controller: _titleCtrl, label: 'Event Title',
                  hint: 'e.g. Taylor Swift Eras Tour',
                  icon: Icons.star_outline_rounded, isDark: isDark,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),
                _fancyField(
                  controller: _descCtrl, label: 'Description',
                  hint: 'Tell people what to expect...',
                  icon: Icons.notes_rounded, isDark: isDark, maxLines: 4,
                ),
                const SizedBox(height: 14),
                _fancyField(
                  controller: _imageUrlCtrl, label: 'Banner Image URL',
                  hint: 'https://...',
                  icon: Icons.image_outlined, isDark: isDark,
                  onChanged: (_) => setState(() {}),
                ),
              ])),
          const SizedBox(height: 16),
          _sectionCard(isDark,
              icon: Icons.category_rounded,
              title: 'Category',
              accent: AppColors.secondary,
              child: _buildCategoryGrid(isDark)),
          const SizedBox(height: 16),
          _sectionCard(isDark,
              icon: Icons.event_rounded,
              title: 'Date & Time',
              accent: AppColors.success,
              child: Row(children: [
                Expanded(child: _buildDatePicker(isDark)),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker(isDark)),
              ])),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Step 2: Venue ─────────────────────────────────────────────────────────

  Widget _buildStep2(bool isDark, Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity, height: 120,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [AppColors.secondary.withValues(alpha: 0.85), AppColors.primary.withValues(alpha: 0.85)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Stack(children: [
              Positioned(
                right: -20, bottom: -20,
                child: Opacity(opacity: 0.15,
                    child: Icon(Icons.stadium_rounded, size: 140, color: Colors.white)),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Venue Details', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Where will the magic happen?', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ]),
          ),
          _sectionCard(isDark,
              icon: Icons.business_rounded,
              title: 'Venue Info',
              accent: AppColors.secondary,
              child: Column(children: [
                _fancyField(controller: _venueNameCtrl, label: 'Venue Name',
                    hint: 'e.g. Madison Square Garden',
                    icon: Icons.stadium_outlined, isDark: isDark),
                const SizedBox(height: 14),
                _fancyField(controller: _cityCtrl, label: 'City',
                    hint: 'New York', icon: Icons.location_city_rounded, isDark: isDark),
                const SizedBox(height: 14),
                _fancyField(controller: _addressCtrl, label: 'Full Address',
                    hint: '4 Pennsylvania Plaza, NY 10001',
                    icon: Icons.place_outlined, isDark: isDark, maxLines: 2),
              ])),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Step 3: Tickets ───────────────────────────────────────────────────────

  Widget _buildStep3(bool isDark, Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          ..._tiers.asMap().entries.map((entry) {
            final i = entry.key;
            final color = _tierColors[i % _tierColors.length];
            return _buildTierCard(i, entry.value, color, isDark);
          }),
          GestureDetector(
            onTap: () => setState(() => _tiers.add({'name': '', 'price': 0.0, 'qty': 0})),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.45), width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Add Ticket Tier', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          _buildLivePreview(isDark),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Tier Card ─────────────────────────────────────────────────────────────

  Widget _buildTierCard(int i, Map<String, dynamic> tier, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Column(children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(Icons.confirmation_number_rounded, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: tier['name'],
                style: TextStyle(fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight),
                decoration: InputDecoration(
                  hintText: 'Tier name (e.g. VIP)',
                  hintStyle: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade400,
                      fontWeight: FontWeight.w400),
                  filled: false, border: InputBorder.none, enabledBorder: InputBorder.none,
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
                onChanged: (v) => _tiers[i]['name'] = v,
              ),
            ),
            if (_tiers.length > 1)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppColors.error.withValues(alpha: 0.8), size: 20),
                onPressed: () => setState(() => _tiers.removeAt(i)),
                tooltip: 'Remove tier',
              ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _miniNumericField(
              label: 'Price (\$)', value: tier['price'].toString(),
              icon: Icons.attach_money_rounded, color: color, isDark: isDark,
              onChanged: (v) => _tiers[i]['price'] = double.tryParse(v) ?? 0,
            )),
            const SizedBox(width: 12),
            Expanded(child: _miniNumericField(
              label: 'Quantity', value: tier['qty'].toString(),
              icon: Icons.people_outline_rounded, color: color, isDark: isDark,
              onChanged: (v) => _tiers[i]['qty'] = int.tryParse(v) ?? 0,
            )),
          ]),
        ]),
      ),
    );
  }

  // ─── Live Preview ──────────────────────────────────────────────────────────

  Widget _buildLivePreview(bool isDark) {
    final hasImage = _imageUrlCtrl.text.trim().isNotEmpty;
    final totalCap = _tiers.fold<int>(0, (s, t) => s + (t['qty'] as int));
    final minPrice = _tiers.isEmpty
        ? 0.0
        : _tiers.map((t) => (t['price'] as num).toDouble()).reduce((a, b) => a < b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 3, height: 18,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          const Text('Live Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        ]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.card : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140, width: double.infinity,
                color: isDark ? AppColors.surface : Colors.grey.shade100,
                child: hasImage
                    ? Image.network(_imageUrlCtrl.text.trim(), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _previewPlaceholder())
                    : _previewPlaceholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(_category.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                color: AppColors.primary, letterSpacing: 0.8)),
                      ),
                      const Spacer(),
                      Text('From \$${minPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      _titleCtrl.text.trim().isEmpty ? 'Your Event Title' : _titleCtrl.text.trim(),
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.textSecondaryDark),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          _cityCtrl.text.isEmpty ? 'City · Venue'
                              : '${_cityCtrl.text} · ${_venueNameCtrl.text.isEmpty ? 'TBD' : _venueNameCtrl.text}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.textSecondaryDark),
                      const SizedBox(width: 3),
                      Text('$totalCap seats', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                    ]),
                    if (_tiers.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 6,
                        children: _tiers.asMap().entries.map((e) {
                          final c = _tierColors[e.key % _tierColors.length];
                          final t = e.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: c.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '${t['name'].toString().isEmpty ? 'Tier' : t['name']}  \$${(t['price'] as num).toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.07),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.image_outlined, size: 36, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 6),
          Text('Event Image Preview',
              style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    final hasImage = _imageUrlCtrl.text.trim().isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: hasImage ? 180 : 90,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppColors.surface : Colors.grey.shade100,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(_imageUrlCtrl.text.trim(), fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _previewPlaceholder())
          : _previewPlaceholder(),
    );
  }

  Widget _buildCategoryGrid(bool isDark) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: _categories.map((cat) {
        final (label, icon) = cat;
        final selected = _category == label;
        return GestureDetector(
          onTap: () => setState(() => _category = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.primaryGradient : null,
              color: selected ? null : (isDark ? AppColors.card : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : null,
              border: selected ? null : Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16,
                  color: selected ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade600)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade700),
              )),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context, initialDate: _date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx)
                .copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.card)),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date', style: TextStyle(fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade500)),
              Text('${_date.day} ${_monthName(_date.month)} ${_date.year}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight)),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildTimePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context, initialTime: _parseTime(_timeCtrl.text),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx)
                .copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.card)),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            final h = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
            final m = picked.minute.toString().padLeft(2, '0');
            final p = picked.period == DayPeriod.am ? 'AM' : 'PM';
            _timeCtrl.text = '$h:$m $p';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(children: [
          const Icon(Icons.access_time_rounded, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time', style: TextStyle(fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade500)),
              Text(_timeCtrl.text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight)),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          if (_currentStep > 0) ...[
            GestureDetector(
              onTap: _back,
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: GestureDetector(
              onTap: _next,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == 2
                          ? (_isEdit ? 'Update Event' : 'Publish Event')
                          : 'Continue',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15,
                          fontWeight: FontWeight.w700, letterSpacing: 0.3),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentStep == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sectionCard(bool isDark, {required IconData icon, required String title, required Color accent, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimaryLight)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _fancyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimaryLight),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        labelStyle: TextStyle(fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade500),
        hintStyle: TextStyle(fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.5) : Colors.grey.shade400),
        filled: true,
        fillColor: isDark ? AppColors.surface.withValues(alpha: 0.6) : Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
      ),
    );
  }

  Widget _miniNumericField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimaryLight),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 15, color: color),
        labelStyle: TextStyle(fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade500),
        filled: true,
        fillColor: color.withValues(alpha: 0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color.withValues(alpha: 0.2))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }

  String _monthName(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  TimeOfDay _parseTime(String raw) {
    try {
      final parts = raw.split(RegExp(r'[: ]'));
      int h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final isPm = raw.toUpperCase().contains('PM');
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return const TimeOfDay(hour: 19, minute: 0);
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;
    final admin = context.read<AdminProvider>();
    final tiers = _tiers.asMap().entries.map((entry) {
      final i = entry.key;
      final t = entry.value;
      final existingSold = (_isEdit && _existing != null && i < _existing!.ticketTiers.length)
          ? _existing!.ticketTiers[i].soldQuantity
          : 0;
      return TicketTier(
        name: t['name'].toString().isEmpty ? 'General' : t['name'],
        price: (t['price'] as num).toDouble(),
        totalQuantity: t['qty'] as int,
        soldQuantity: existingSold,
      );
    }).toList();

    final event = EventModel(
      id: _isEdit ? _existing!.id : 'evt_new_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text,
      imageUrl: _imageUrlCtrl.text.trim().isEmpty
          ? 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/400'
          : _imageUrlCtrl.text.trim(),
      category: _category,
      date: _date,
      time: _timeCtrl.text,
      venueId: _venueIdCtrl.text.isEmpty ? 'v1' : _venueIdCtrl.text,
      venueName: _venueNameCtrl.text.isEmpty ? 'TBD' : _venueNameCtrl.text,
      city: _cityCtrl.text.isEmpty ? 'TBD' : _cityCtrl.text,
      ticketTiers: tiers,
      artists: _isEdit ? (_existing?.artists ?? []) : [],
      status: _isEdit ? (_existing?.status ?? 'Active') : 'Active',
      rating: _isEdit ? (_existing?.rating ?? 0.0) : 0.0,
      reviewCount: _isEdit ? (_existing?.reviewCount ?? 0) : 0,
      isFeatured: _isEdit ? (_existing?.isFeatured ?? false) : false,
      isTrending: _isEdit ? (_existing?.isTrending ?? false) : false,
    );

    if (_isEdit) {
      admin.updateEvent(_existing!.id, event);
    } else {
      admin.addEvent(event);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(_isEdit ? 'Event updated successfully!' : 'Event published!'),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    context.pop();
  }
}
