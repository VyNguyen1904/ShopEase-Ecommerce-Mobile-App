import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/address_modal.dart';

class AddressScreen extends ConsumerStatefulWidget {
  final bool isSelecting;
  const AddressScreen({super.key, this.isSelecting = false});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Địa chỉcủa tôi',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: userState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Lỗi tải địa chỉ $err',
            style: const TextStyle(color: AppColors.alertRed),
          ),
        ),
        data: (user) {
          final addresses = user?.addresses ?? [];
          
          return Stack(
            children: [
              if (addresses.isEmpty)
                const Center(
                  child: Text(
                    'Bạn chưa có địa chỉnào',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 120,
                  ),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _AddressItemCard(
                      address: addresses[index],
                      isSelecting: widget.isSelecting,
                    );
                  },
                ),
              const _AddAddressButton(),
            ],
          );
        },
      ),
    );
  }
}

class _AddressItemCard extends ConsumerWidget {
  final dynamic address; // Should ideally be replaced with your Address model type
  final bool isSelecting;

  const _AddressItemCard({required this.address, this.isSelecting = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: isSelecting ? () => context.pop(address) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Mặc định',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  address.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.address1,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                if (address.address2 != null && address.address2!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    address.address2!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textDark,
                  size: 20,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddressModal(address: address),
                  );
                },
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.alertRed,
                  size: 20,
                ),
                onPressed: () async {
                  try {
                    final authService = ref.read(authServiceProvider);
                    await authService.deleteAddress(address.id);
                    ref.invalidate(userProfileProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa địa chỉthành công')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

class _AddAddressButton extends StatelessWidget {
  const _AddAddressButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddressModal(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text(
                  'Thêm địa chỉmới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
