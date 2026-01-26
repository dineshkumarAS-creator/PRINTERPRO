import 'dart:convert';
// import 'dart:io'; // NOT SUPPORTED ON WEB
import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart'; // MIGHT CAUSE ISSUES OR JUST UNUSED

class ApiService {
  // Android Emulator: 'http://10.0.2.2:5000'
  // Desktop/Web/iOS Simulator: 'http://127.0.0.1:5000'
  static const String _baseUrl = 'http://127.0.0.1:5000'; 

  // Stubbing this for Web compatibility since dart:io File isn't supported
  // Future<File?> askName() async { ... }
  Future<dynamic> askName() async {
    print("askName not supported on web currently");
    return null;
  }

  // Stubbing this for Web compatibility
  // Future<Map<String, dynamic>> recognizeName(String audioPath) async { ... }
  Future<Map<String, dynamic>> recognizeName(String audioPath) async {
     print("recognizeName not supported on web currently");
     return {'success': false, 'error': 'Web not supported for file upload yet'};
  }
}
