import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/models/bill_item_model.dart';
import 'package:staff_app/models/cafe_config_model.dart';
import 'package:staff_app/services/billing_service.dart';
import 'package:staff_app/services/cafe_service.dart';

final billingServiceProvider = Provider<BillingService>(
  (ref) => BillingService(),
);
final cafeServiceProvider = Provider<CafeService>((ref) => CafeService());

final cafeConfigProvider = FutureProvider.family<CafeConfigModel, String>((
  ref,
  cafeId,
) {
  return ref.watch(cafeServiceProvider).fetchConfig(cafeId);
});

class BillingArgs {
  final String cafeId;
  final String tableId;

  BillingArgs({required this.cafeId, required this.tableId});

  @override
  bool operator ==(Object other) =>
      other is BillingArgs &&
      other.cafeId == cafeId &&
      other.tableId == tableId;

  @override
  int get hashCode => Object.hash(cafeId, tableId);
}

final billingStramProvider =
    StreamProvider.family<BillingSnapshot, BillingArgs>((ref, args) {
      return ref
          .watch(billingServiceProvider)
          .streamBilling(args.cafeId, args.tableId);
    });

final onboardingStatusProvider =
    FutureProvider.family<Map<String, bool>, String>((ref, cafeId) {
      return ref.watch(cafeServiceProvider).fetchOnboardingStatus(cafeId);
    });
