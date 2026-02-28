import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/custom_button.dart';
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

class _AdminAddEditEventScreenState extends State<AdminAddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
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

  final _categories = [
    'Concerts',
    'Sports',
    'Theatre',
    'Comedy',
    'Festivals',
    'Family'
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Event' : 'Add Event'),
      ),
      body: AppBackground(
        child: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _saveEvent();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (ctx, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _currentStep == 2 ? 'Publish' : 'Next',
                      onPressed: details.onStepContinue!,
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        onPressed: details.onStepCancel!,
                        isOutlined: true,
                      ),
                    ),
                  ],
                  if (_currentStep == 2) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Save Draft',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Draft saved! (Mock)'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        isOutlined: true,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Basic Info
            Step(
              title: const Text('Basic Info'),
              isActive: _currentStep >= 0,
              state:
                  _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Event Title'),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Image URL'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration:
                        const InputDecoration(labelText: 'Category'),
                    items: _categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Event Date'),
                    subtitle: Text(
                        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _date = picked);
                      }
                    },
                  ),
                  TextFormField(
                    controller: _timeCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Event Time'),
                  ),
                ],
              ),
            ),

            // Step 2: Venue
            Step(
              title: const Text('Venue'),
              isActive: _currentStep >= 1,
              state:
                  _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _venueNameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Venue Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cityCtrl,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
            ),

            // Step 3: Tickets
            Step(
              title: const Text('Ticket Tiers'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  ..._tiers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final tier = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surface
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: tier['name'],
                                  decoration: const InputDecoration(
                                      labelText: 'Tier Name'),
                                  onChanged: (v) =>
                                      _tiers[i]['name'] = v,
                                ),
                              ),
                              if (_tiers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: AppColors.error, size: 20),
                                  onPressed: () => setState(
                                      () => _tiers.removeAt(i)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      tier['price'].toString(),
                                  decoration: const InputDecoration(
                                      labelText: 'Price (\$)'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => _tiers[i]['price'] =
                                      double.tryParse(v) ?? 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      tier['qty'].toString(),
                                  decoration: const InputDecoration(
                                      labelText: 'Quantity'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => _tiers[i]['qty'] =
                                      int.tryParse(v) ?? 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: () => setState(() => _tiers.add(
                        {'name': '', 'price': 0.0, 'qty': 0})),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Tier'),
                  ),

                  // Preview
                  const Divider(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Preview',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_titleCtrl.text.isEmpty
                            ? 'Event Title'
                            : _titleCtrl.text,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('$_category • ${_cityCtrl.text}'),
                        const SizedBox(height: 8),
                        ..._tiers.map((t) => Text(
                            '${t['name']}: \$${t['price']} × ${t['qty']}')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _saveEvent() {
    final admin = context.read<AdminProvider>();
    final tiers = _tiers.map((t) => TicketTier(
      name: t['name'] ?? 'General',
      price: (t['price'] as num).toDouble(),
      totalQuantity: t['qty'] as int,
      soldQuantity: 0,
    )).toList();

    final event = EventModel(
      id: _isEdit ? _existing!.id : 'evt_new_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text,
      description: _descCtrl.text,
      imageUrl: _imageUrlCtrl.text.isEmpty
          ? 'https://picsum.photos/800/400'
          : _imageUrlCtrl.text,
      category: _category,
      date: _date,
      time: _timeCtrl.text,
      venueId: _venueIdCtrl.text.isEmpty ? 'v1' : _venueIdCtrl.text,
      venueName: _venueNameCtrl.text.isEmpty ? 'TBD' : _venueNameCtrl.text,
      city: _cityCtrl.text.isEmpty ? 'TBD' : _cityCtrl.text,
      ticketTiers: tiers,
      artists: [],
      status: 'active',
      rating: 0.0,
      reviewCount: 0,
      isFeatured: false,
    );

    if (_isEdit) {
      admin.updateEvent(_existing!.id, event);
    } else {
      admin.addEvent(event);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Event updated!' : 'Event published!'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }
}
