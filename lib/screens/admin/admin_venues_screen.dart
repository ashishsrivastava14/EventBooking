import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/admin_provider.dart';
import '../../models/venue_model.dart';

class AdminVenuesScreen extends StatelessWidget {
  const AdminVenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = context.watch<AdminProvider>();
    final venues = admin.venues;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Venues')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVenueForm(context, admin, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Venue'),
      ),
      body: AppBackground(
        child: venues.isEmpty
          ? const Center(child: Text('No venues'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                return _venueCard(venue, isDark, context, admin);
              },
            ),
      ),
    );
  }

  Widget _venueCard(
      VenueModel venue, bool isDark, BuildContext context, AdminProvider admin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: AppImage(
              imageUrl: venue.imageUrl,
              height: 140,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${venue.city} • ${venue.address}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people,
                        size: 14, color: AppColors.textSecondaryDark),
                    const SizedBox(width: 4),
                    Text('Capacity: ${venue.capacity}',
                        style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    Text('${venue.rows} rows × ${venue.seatsPerRow} seats',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showVenueForm(context, admin, venue),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Seat map editor placeholder (UI only)')),
                          );
                        },
                        icon: const Icon(Icons.grid_view, size: 16),
                        label: const Text('Seat Map'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVenueForm(
      BuildContext context, AdminProvider admin, VenueModel? venue) {
    final nameCtrl =
        TextEditingController(text: venue?.name ?? '');
    final cityCtrl =
        TextEditingController(text: venue?.city ?? '');
    final addressCtrl =
        TextEditingController(text: venue?.address ?? '');
    final capacityCtrl =
        TextEditingController(text: venue?.capacity.toString() ?? '1000');
    final rowsCtrl =
        TextEditingController(text: venue?.rows.toString() ?? '10');
    final seatsCtrl =
        TextEditingController(text: venue?.seatsPerRow.toString() ?? '20');
    final imageCtrl =
        TextEditingController(text: venue?.imageUrl ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venue != null ? 'Edit Venue' : 'Add Venue',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: capacityCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Capacity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: rowsCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Rows'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: seatsCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Seats/Row'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageCtrl,
                decoration:
                    const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: venue != null ? 'Update' : 'Add',
                onPressed: () {
                  final v = VenueModel(
                    id: venue?.id ??
                        'v_new_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text,
                    city: cityCtrl.text,
                    address: addressCtrl.text,
                    capacity: int.tryParse(capacityCtrl.text) ?? 1000,
                    imageUrl: imageCtrl.text.isEmpty
                        ? 'https://picsum.photos/800/400'
                        : imageCtrl.text,
                    rows: int.tryParse(rowsCtrl.text) ?? 10,
                    seatsPerRow: int.tryParse(seatsCtrl.text) ?? 20,
                  );
                  if (venue != null) {
                    admin.updateVenue(v.id, v);
                  } else {
                    admin.addVenue(v);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(venue != null
                          ? 'Venue updated!'
                          : 'Venue added!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
