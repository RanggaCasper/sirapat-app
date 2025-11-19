import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/widgets/profile_info_card.dart';
import 'package:sirapat_app/presentation/widgets/logout_button.dart';
import 'package:sirapat_app/presentation/widgets/custom_bottom_nav_bar.dart';

class ProfilePage extends GetView<AuthController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Get.toNamed('/edit-profile');
                            },
                            icon: const Icon(Icons.edit_outlined),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Obx(
                      () => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 56,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage:
                                          controller
                                                  .currentUser
                                                  ?.profilePhoto !=
                                              null
                                          ? NetworkImage(
                                              controller
                                                  .currentUser!
                                                  .profilePhoto!,
                                            )
                                          : null,
                                      child:
                                          controller
                                                  .currentUser
                                                  ?.profilePhoto ==
                                              null
                                          ? Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey.shade400,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              controller.currentUser?.fullName ?? 'John Doe',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              controller.currentUser?.role ??
                                  'Programmer Backend',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(
                        () => Column(
                          children: [
                            ProfileInfoCard(
                              icon: Icons.badge_outlined,
                              label: 'Nomor Induk Pegawai',
                              value:
                                  controller.currentUser?.nip ?? '221535403111',
                              iconColor: Colors.blue,
                            ),

                            const SizedBox(height: 12),

                            ProfileInfoCard(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value:
                                  controller.currentUser?.email ??
                                  'johndoe@example.com',
                              iconColor: Colors.orange,
                            ),

                            const SizedBox(height: 12),

                            ProfileInfoCard(
                              icon: Icons.phone_outlined,
                              label: 'No. Telepon',
                              value:
                                  controller.currentUser?.phone ??
                                  '(+62) 81234122311',
                              iconColor: Colors.green,
                            ),

                            const SizedBox(height: 12),

                            ProfileInfoCard(
                              icon: Icons.lock_outlined,
                              label: 'Password',
                              value: '••••••••••••',
                              iconColor: Colors.purple,
                              obscureValue: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(
                        () => LogoutButton(isLoading: controller.isLoading),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // bottomNavigationBar: CustomBottomNavBar(
      //   currentIndex: 3,
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         Get.offAllNamed('/home');
      //         break;
      //       case 1:
      //         Get.toNamed('/home');
      //         break;
      //       case 2:
      //         Get.toNamed('/home');
      //         break;
      //       case 3:
      //         Get.toNamed('/profile');
      //         break;
      //     }
      //   },
      // ),
    );
  }
}
