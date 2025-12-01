import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/presentation/controllers/user_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/empty_state.dart';
import 'package:sirapat_app/presentation/shared/widgets/pagination_controls.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';
import 'package:sirapat_app/presentation/features/master/widgets/user/user_card.dart';
import 'package:sirapat_app/presentation/features/master/pages/user/user_form_page.dart';
import 'package:sirapat_app/presentation/features/master/pages/user/user_detail_page.dart';

/// User management section untuk Master Dashboard
class UserManagementSection extends GetView<UserController> {
  const UserManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.searchUsers,
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  return controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchUsers('');
                          },
                        )
                      : const SizedBox.shrink();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoadingObs.value) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: 6,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: const ListItemSkeleton(),
                  ),
                );
              }

              if (controller.users.isEmpty &&
                  controller.searchQuery.value.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: 'Belum ada pengguna',
                  message: 'Tap tombol + untuk menambah pengguna',
                  buttonText: 'Tambah Pengguna',
                  onButtonPressed: () => _showCreateDialog(context),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchUsers,
                child: Column(
                  children: [
                    Expanded(
                      child: controller.users.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Pengguna tidak ditemukan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Coba kata kunci lain',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: controller.users.length,
                              itemBuilder: (context, index) {
                                final user = controller.users[index];
                                return UserCard(
                                  user: user,
                                  onTap: () => _showDetailDialog(context, user),
                                  onEdit: () => _showEditDialog(context, user),
                                  onDelete: () =>
                                      controller.deleteUser(user.id!),
                                );
                              },
                            ),
                    ),

                    // Pagination controls at the bottom (always show)
                    if (controller.paginationMeta.value != null)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: PaginationControls(
                          meta: controller.paginationMeta.value!,
                          onPrevious: controller.previousPage,
                          onNext: controller.nextPage,
                          onPageSelect: controller.goToPage,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        // Only show FAB when not in initial loading and has data or searching
        if (controller.isLoadingObs.value) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: FloatingActionButton(
            onPressed: () => _showCreateDialog(context),
            tooltip: 'Tambah Pengguna',
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }

  void _showCreateDialog(BuildContext context) {
    controller.clearForm();
    Get.to(() => const UserFormPage(isEdit: false));
  }

  void _showEditDialog(BuildContext context, User user) {
    controller.prepareEdit(user);
    Get.to(() => const UserFormPage(isEdit: true));
  }

  void _showDetailDialog(BuildContext context, User user) {
    Get.to(() => UserDetailPage(user: user));
  }
}
