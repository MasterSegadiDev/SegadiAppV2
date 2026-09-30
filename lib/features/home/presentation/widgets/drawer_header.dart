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
        26,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF101812),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF1E7A3C),
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
                      color: Color(0xFF1E7A3C),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            authUser?.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authUser?.email ?? '',
            style: const TextStyle(
              color: Color(0xFF8A938C),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          if (profile.profile?.tipoRol != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E7A3C).withOpacity(.25),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                profile.profile!.tipoRol,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
