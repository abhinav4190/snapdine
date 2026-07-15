import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:staff_app/models/bill_item_model.dart';
import 'package:staff_app/models/cafe_config_model.dart';
import 'package:staff_app/providers/billing_providers.dart';
import 'package:staff_app/providers/table_providers.dart';
import 'package:staff_app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BillingScreen extends ConsumerStatefulWidget {
  final String cafeId;
  final String tablleId;
  const BillingScreen({
    super.key,
    required this.cafeId,
    required this.tablleId,
  });

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final _discountController = TextEditingController(text: '0');
  final _phoneController = TextEditingController();
  bool _finalizing = false;

  @override
  void dispose() {
    _discountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _discount => double.tryParse(_discountController.text.trim()) ?? 0;

  Future<void> _sendOnWhatsapp(
    CafeConfigModel config,
    BillingSnapshot snapshot,
    double subtotal,
    double gst,
    double serviceCharge,
    double total,
  ) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln(
      '*${config.name}* — ${widget.tablleId.replaceAll('table-', 'Table ')}',
    );
    buffer.writeln('—————————————');
    for (final item in snapshot.grouped) {
      buffer.writeln(
        '${item.name} x${item.qty}   ₹${(item.price * item.qty).toStringAsFixed(0)}',
      );
    }
    buffer.writeln('—————————————');
    buffer.writeln('Subtotal   ₹${subtotal.toStringAsFixed(2)}');
    buffer.writeln(
      'GST (${config.gstPercent.toStringAsFixed(0)}%)   ₹${gst.toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Service (${config.serviceChargePercent.toStringAsFixed(0)}%)   ₹${serviceCharge.toStringAsFixed(2)}',
    );
    if (_discount > 0)
      buffer.writeln('Discount   -₹${_discount.toStringAsFixed(2)}');
    buffer.writeln('—————————————');
    buffer.writeln('*Total   ₹${total.toStringAsFixed(2)}*');
    buffer.writeln();
    buffer.writeln('Thank you for visiting!');

    final normalizedPhone = phone.length == 10 ? '91$phone' : phone;
    final uri = Uri.parse(
      'https://wa.me/$normalizedPhone?text=${Uri.encodeComponent(buffer.toString())}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _finalizeBill(BillingSnapshot snapshot) async {
    setState(() => _finalizing = true);
    await ref
        .read(billingServiceProvider)
        .markOrdersPaid(widget.cafeId, snapshot.orderIds);
    await ref
        .read(tableServiceProvider)
        .resetTable(widget.cafeId, widget.tablleId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(cafeConfigProvider(widget.cafeId));
    final billingAsync = ref.watch(
      billingStramProvider(
        BillingArgs(cafeId: widget.cafeId, tableId: widget.tablleId),
      ),
    );

    return GestureDetector(
         onTap: ()=>  FocusScope.of(context).unfocus(),

      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tablleId.replaceAll('table-', 'Table ')),
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        body: configAsync.when(
          data: (config) {
            return billingAsync.when(
              data: (snapshot) {
                if (snapshot.items.isEmpty) {
                  return Center(
                    child: Text(
                      'No unpaid orders for this table',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
      
                final subtotal = snapshot.subtotal;
                final gst = subtotal * config.gstPercent / 100;
                final serviceCharge =
                    subtotal * config.serviceChargePercent / 100;
                final total = subtotal + gst + serviceCharge - _discount;
      
                return ListView(
                  padding: EdgeInsets.all(18),
                  children: [
                    Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...snapshot.grouped.map(
                            (item) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.qty} × ${item.name}',
                                      style: TextStyle(color: AppColors.crema),
                                    ),
                                  ),
                                  Text(
                                    '₹${(item.price * item.qty).toStringAsFixed(0)}',
                                    style: TextStyle(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(color: AppColors.surfaceHigh, height: 24),
                          _SummaryRow(label: 'Subtotal', value: subtotal),
                          _SummaryRow(
                            label:
                                'GST (${config.gstPercent.toStringAsFixed(0)}%)',
                            value: gst,
                          ),
                          _SummaryRow(
                            label:
                                'Service (${config.serviceChargePercent.toStringAsFixed(0)}%)',
                            value: serviceCharge,
                          ),
                       Row(
        children: [
      Text(
        'Discount',
        style: TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w500,
        ),
      ),
      const Spacer(),
      SizedBox(
        width: 100,
        child: TextField(
          controller: _discountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.crema,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.muted),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
        ],
      ),
                          Divider(color: AppColors.surfaceHigh, height: 24),
                          Row(
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  color: AppColors.crema,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: AppColors.crema),
                      decoration: InputDecoration(
                        hintText: 'Customer phone (10 digits)',
                      ),
                    ),
                    SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _sendOnWhatsapp(
                        config,
                        snapshot,
                        subtotal,
                        gst,
                        serviceCharge,
                        total,
                      ),
                      label: Text('Send on Whatsapp'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.fromHeight(52),
                        side: BorderSide.none,
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.sage,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(14),
                        ),
                      ),
                      icon: Icon(PhosphorIconsThin.whatsappLogo, size: 20),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _finalizing
                          ? null
                          : () => _finalizeBill(snapshot),
                      child: _finalizing
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.ink,
                              ),
                            )
                          : Text('Mark as paid & reset table'),
                    ),
                  ],
                );
              },
              error: (error, _) => Center(child: Text('Could not load bill')),
              loading: () => CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            );
          },
          error: (error, _) => Center(child: Text('Could not load cafe config')),
          loading: () => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  const _SummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: AppColors.muted)),
          Spacer(),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
