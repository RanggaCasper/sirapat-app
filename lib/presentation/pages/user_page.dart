import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/user_controller.dart';
import 'package:sirapat_app/domain/entities/user.dart';

class UserPage extends GetView<UserController> {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingObs.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada user',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap tombol + untuk menambah user',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah User'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUsers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return _buildUserCard(user);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
        tooltip: 'Tambah User',
      ),
    );
  }

  Widget _buildUserCard(User user) {
    Color roleColor = _getRoleColor(user.role ?? "employee");

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: roleColor.withBlue(122),
                child: user.profilePhoto != null
                    ? ClipOval(
                        child: Image.network(
                          user.profilePhoto!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 30,
                              color: roleColor,
                            );
                          },
                        ),
                      )
                    : Icon(Icons.person, size: 30, color: roleColor),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName ?? "nama user",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.roleDisplay ?? "employee",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? "email user",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIP: ${user.nip}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'detail':
                      _showDetailDialog(user);
                      break;
                    case 'edit':
                      _showEditDialog(user);
                      break;
                    case 'role':
                      _showChangeRoleDialog(user);
                      break;
                    case 'password':
                      _showChangePasswordDialog(user);
                      break;
                    case 'delete':
                      controller.deleteUser(user.id ?? 0);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 20),
                        SizedBox(width: 8),
                        Text('Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 20,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text('Ubah Role'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset, size: 20, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Ganti Password'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'master':
        return Colors.red;
      case 'admin':
        return Colors.blue;
      case 'employee':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDetailDialog(User user) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getRoleColor(
                user.role ?? "employee",
              ).withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: _getRoleColor(user.role ?? "employee"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? "nama user",
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user.roleDisplay ?? "employee",
                    style: TextStyle(
                      fontSize: 14,
                      color: _getRoleColor(user.role ?? "employee"),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('NIP', user.nip ?? "nip user"),
              const SizedBox(height: 12),
              _buildDetailRow('Username', user.username ?? "username user"),
              const SizedBox(height: 12),
              _buildDetailRow('Email', user.email ?? "email user"),
              const SizedBox(height: 12),
              _buildDetailRow('Telepon', user.phone ?? "telepon user"),
              if (user.createdAt != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Dibuat', (user.createdAt ?? "-")),
              ],
              if (user.updatedAt != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Diperbarui', (user.updatedAt ?? "-")),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _showEditDialog(user);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showCreateDialog() {
    controller.clearForm();
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Tambah User Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildUserForm(isEdit: false),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isLoadingActionObs.value
                            ? null
                            : controller.createUser,
                        icon: controller.isLoadingActionObs.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save, size: 18),
                        label: const Text('Simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
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

  void _showEditDialog(User user) {
    controller.prepareEdit(user);
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildUserForm(isEdit: true),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isLoadingActionObs.value
                            ? null
                            : controller.updateUser,
                        icon: controller.isLoadingActionObs.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save, size: 18),
                        label: const Text('Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
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

  Widget _buildUserForm({required bool isEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NIP
        Obx(
          () => TextField(
            controller: controller.nipController,
            decoration: InputDecoration(
              labelText: 'NIP *',
              hintText: 'Masukkan NIP',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.badge),
              errorText: controller.getFieldError('nip'),
            ),
            onChanged: (value) => controller.clearFieldError('nip'),
          ),
        ),
        const SizedBox(height: 16),

        // Username
        Obx(
          () => TextField(
            controller: controller.usernameController,
            decoration: InputDecoration(
              labelText: 'Username *',
              hintText: 'Masukkan username',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
              errorText: controller.getFieldError('username'),
            ),
            onChanged: (value) => controller.clearFieldError('username'),
          ),
        ),
        const SizedBox(height: 16),

        // Full Name
        Obx(
          () => TextField(
            controller: controller.fullNameController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap *',
              hintText: 'Masukkan nama lengkap',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              errorText: controller.getFieldError('full_name'),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => controller.clearFieldError('full_name'),
          ),
        ),
        const SizedBox(height: 16),

        // Email
        Obx(
          () => TextField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: 'Email *',
              hintText: 'nama@email.com',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
              errorText: controller.getFieldError('email'),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => controller.clearFieldError('email'),
          ),
        ),
        const SizedBox(height: 16),

        // Phone
        Obx(
          () => TextField(
            controller: controller.phoneController,
            decoration: InputDecoration(
              labelText: 'Nomor Telepon *',
              hintText: '08xxxxxxxxxx',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone),
              errorText: controller.getFieldError('phone'),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => controller.clearFieldError('phone'),
          ),
        ),
        const SizedBox(height: 16),

        // Role Dropdown
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedRole.value,
            decoration: const InputDecoration(
              labelText: 'Role *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.admin_panel_settings),
            ),
            items: controller.roleOptions.map((role) {
              return DropdownMenuItem(
                value: role['value'],
                child: Text(role['label']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedRole.value = value;
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        // Profile Photo (optional)
        Obx(
          () => TextField(
            controller: controller.profilePhotoController,
            decoration: InputDecoration(
              labelText: 'URL Foto Profil (Opsional)',
              hintText: 'https://...',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.image),
              errorText: controller.getFieldError('profile_photo'),
            ),
            onChanged: (value) => controller.clearFieldError('profile_photo'),
          ),
        ),

        // Password fields (only for create)
        if (!isEdit) ...[
          const SizedBox(height: 16),
          Obx(
            () => TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'Minimal 8 karakter',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                errorText: controller.getFieldError('password'),
              ),
              obscureText: controller.obscurePassword.value,
              onChanged: (value) => controller.clearFieldError('password'),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextField(
              controller: controller.passwordConfirmationController,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password *',
                hintText: 'Ulangi password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscurePasswordConfirmation.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.togglePasswordConfirmationVisibility,
                ),
                errorText: controller.getFieldError('password_confirmation'),
              ),
              obscureText: controller.obscurePasswordConfirmation.value,
              onChanged: (value) =>
                  controller.clearFieldError('password_confirmation'),
            ),
          ),
        ],

        const SizedBox(height: 16),
        Text(
          '* Wajib diisi',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showChangeRoleDialog(User user) {
    final selectedRole = user.role.obs;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Ubah Role User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${user.fullName}'),
            Text(
              'Role saat ini: ${user.roleDisplay}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            const Text('Pilih role baru:'),
            const SizedBox(height: 12),

            Obx(
              () => Column(
                children: controller.roleOptions
                    .where((role) => role['value'] != 'master')
                    .map((role) {
                      return RadioListTile<String>(
                        title: Text(role['label']!),
                        value: role['value']!,
                        groupValue: selectedRole.value,
                        onChanged: (value) {
                          if (value != null) {
                            selectedRole.value = value;
                          }
                        },
                      );
                    })
                    .toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (selectedRole.value != user.role) {
                controller.updateUserRole(user.id!, selectedRole.value!);
              } else {
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ubah Role'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(User user) {
    // controller._clearPasswordForm();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: Colors.purple.shade700),
            const SizedBox(width: 8),
            const Text('Ganti Password'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User: ${user.fullName}'),
              const SizedBox(height: 20),

              // Current Password
              Obx(
                () => TextField(
                  controller: controller.currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password Saat Ini *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: controller.getFieldError('current_password'),
                  ),
                  obscureText: true,
                  onChanged: (value) =>
                      controller.clearFieldError('current_password'),
                ),
              ),
              const SizedBox(height: 16),

              // New Password
              Obx(
                () => TextField(
                  controller: controller.newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password Baru *',
                    hintText: 'Minimal 8 karakter',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: controller.getFieldError('new_password'),
                  ),
                  obscureText: true,
                  onChanged: (value) =>
                      controller.clearFieldError('new_password'),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm New Password
              Obx(
                () => TextField(
                  controller: controller.newPasswordConfirmationController,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: controller.getFieldError(
                      'new_password_confirmation',
                    ),
                  ),
                  obscureText: true,
                  onChanged: (value) =>
                      controller.clearFieldError('new_password_confirmation'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isLoadingActionObs.value
                  ? null
                  : () => controller.changePassword(user.id!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: controller.isLoadingActionObs.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Ganti Password'),
            ),
          ),
        ],
      ),
    );
  }
}
