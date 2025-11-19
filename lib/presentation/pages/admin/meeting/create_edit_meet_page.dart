import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
// import '../controllers/meeting_controller.dart';

class CreateEditMeetingPage extends StatelessWidget {
  const CreateEditMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final c = Get.find<MeetingController>();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.titleDark,
        elevation: 0,
        title: const Text('Buat Meeting'),
        leading: TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal', style: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            // onPressed: c.saveMeeting,
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        // if (c.isLoading.value) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              TextFormField(
                // controller: c.titleC,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tambahkan Judul',
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 16),

              // date
              const Text(
                'Hari',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    // initialDate: c.selectedDate.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  // if (picked != null) c.updateDate(picked);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // dateFormat.format(c.selectedDate.value),
                      dateFormat.format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // time
              Row(
                children: [
                  Expanded(
                    child: _buildTimeColumn(
                      context,
                      'Mulai',
                      // c.startTime.value,
                      TimeOfDay.now(),
                      () async {
                        final picked = await showTimePicker(
                          context: context,
                          // initialTime: c.startTime.value,
                          initialTime: TimeOfDay.now(),
                        );
                        // if (picked != null) c.updateStartTime(picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTimeColumn(
                      context,
                      'Selesai',
                      // c.endTime.value,
                      TimeOfDay.now(),
                      () async {
                        final picked = await showTimePicker(
                          context: context,
                          // initialTime: c.endTime.value,
                          initialTime: TimeOfDay.now(),
                        );
                        // if (picked != null) c.updateEndTime(picked);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // agenda
              const Text(
                'Agenda',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                // controller: c.agendaC,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Tambahkan agenda',
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 32),

              // guests
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tamu Undangan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // simple demo add guest dialog
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Tambah Tamu'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: TextEditingController(),
                                decoration: const InputDecoration(
                                  hintText: 'Nama',
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: TextEditingController(),
                                decoration: const InputDecoration(
                                  hintText: 'Peran',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                // For demo: add a static guest
                                // c.addGuest(ParticipantModel(name: 'New Guest', role: 'Peserta'));
                                Get.back();
                              },
                              child: const Text('Tambah'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Undang'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // guest list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // itemCount: c.invitedGuests.length,
                itemCount: 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  // final g = c.invitedGuests[index];
                  return Row(
                    children: [
                      CircleAvatar(child: const Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(g.name),
                          Text(
                            // g.role,
                            'Peserta',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        // onPressed: () => c.removeGuestAt(index),
                        onPressed: () => {},
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimeColumn(
    BuildContext context,
    String label,
    TimeOfDay t,
    VoidCallback onTap,
  ) {
    final format = MaterialLocalizations.of(context).formatTimeOfDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Text(
            format(t),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
