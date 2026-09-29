import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const _url = 'https://open.er-api.com/v6/latest/USD';

  Future<String> fetchKursHariIni() async {
    try {
      // HTTP REQUEST dikirim di sini
      final response = await http.get(Uri.parse(_url));

      // HTTP RESPONSE diterima & diproses di sini
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final idrRate = rates['IDR'];
        if (idrRate != null) {
          return '1 USD \u2248 Rp${(idrRate as num).toStringAsFixed(0)}';
        }
        return 'Data kurs tidak tersedia';
      }
      return 'Gagal memuat kurs (server error)';
    } catch (e) {
      return 'Gagal memuat kurs (tidak ada internet)';
    }
  }
}