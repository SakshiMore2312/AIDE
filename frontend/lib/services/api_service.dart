import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/college.dart';
import '../models/hospital.dart';
import '../models/pg.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // --- Education Module ---
  Future<List<College>> getColleges() async {
    final response = await http.get(Uri.parse('$baseUrl/education/colleges'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => College.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load colleges');
    }
  }

  // --- Medical Module ---
  Future<List<Hospital>> getHospitals() async {
    final response = await http.get(Uri.parse('$baseUrl/medical/hospitals'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => Hospital.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hospitals');
    }
  }

  // --- Stay Module ---
  Future<List<PG>> getPGs() async {
    final response = await http.get(Uri.parse('$baseUrl/stay/pg'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => PG.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load PGs');
    }
  }

  // --- Auth Module (Simple Login) ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
