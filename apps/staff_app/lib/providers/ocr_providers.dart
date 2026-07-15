import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/services/ocr_services.dart';

final ocrServiceProvider = Provider<OcrServices>((ref) => OcrServices());