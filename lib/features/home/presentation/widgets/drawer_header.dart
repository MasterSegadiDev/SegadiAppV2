import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../user_profile/presentation/providers/user_profile_provider.dart';

class DrawerHeaderWidget extends ConsumerWidget {
  const DrawerHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider);

    final photo = profile.profile?.foto ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        50,
        20,
        30,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2C522A),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 42,
                      color: Color(0xFF2C522A),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            authUser?.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authUser?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(.80),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          if (photo.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                profile.profile!.tipoRol,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
