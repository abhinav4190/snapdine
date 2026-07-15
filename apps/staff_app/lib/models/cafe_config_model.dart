class CafeConfigModel {
  final String name;
  final double gstPercent;
  final double serviceChargePercent;

  CafeConfigModel({
    required this.name,
    required this.gstPercent,
    required this.serviceChargePercent,
  });

  factory CafeConfigModel.fromMap(Map<String, dynamic> data) {
    final config = data['config'] as Map<String, dynamic>? ?? {};
    return CafeConfigModel(
      name: data['name'] as String? ?? '',
      gstPercent: (config['gstPercent'] as num?)?.toDouble() ?? 0,
      serviceChargePercent:
          (config['serviceChargePercent'] as num?)?.toDouble() ?? 0,
    );
  }
}
