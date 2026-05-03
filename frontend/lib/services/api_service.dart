import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/college.dart';
import '../models/hospital.dart';
import '../models/pg.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // Helper to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Education Module ---
  Future<Map<String, dynamic>> getCollege(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/education/colleges/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load college details');
    }
  }

  Future<List<College>> getColleges({String? query, double? lat, double? lon, double? radius, String? type, String? sortBy, String? order, String? minRating}) async {
    final headers = await _getHeaders();
    String queryStr = '?';
    if (query != null) queryStr += 'query=$query&';
    if (lat != null) queryStr += 'lat=$lat&';
    if (lon != null) queryStr += 'lon=$lon&';
    if (radius != null) queryStr += 'radius=$radius&';
    if (type != null) queryStr += 'type=$type&';
    if (sortBy != null) queryStr += 'sort_by=$sortBy&';
    if (order != null) queryStr += 'order=$order&';

    final response = await http.get(
      Uri.parse('$baseUrl/education/colleges/$queryStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => College.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load colleges');
    }
  }

  Future<List<dynamic>> getCollegeReviews(int collegeId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/education/colleges/$collegeId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> postCollegeReview(int collegeId, double rating, String content) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/education/colleges/$collegeId/reviews'),
      headers: headers,
      body: json.encode({
        'rating': rating,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post review');
    }
  }

  Future<List<College>> getSchools({String? query, double? lat, double? lon, double? radius, String? sortBy, String? order}) async {
    final headers = await _getHeaders();
    String queryStr = '?';
    if (query != null) queryStr += 'query=$query&';
    if (lat != null) queryStr += 'lat=$lat&';
    if (lon != null) queryStr += 'lon=$lon&';
    if (radius != null) queryStr += 'radius=$radius&';
    if (sortBy != null) queryStr += 'sort_by=$sortBy&';
    if (order != null) queryStr += 'order=$order&';

    final response = await http.get(
      Uri.parse('$baseUrl/education/schools/$queryStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => College.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load schools');
    }
  }

  Future<List<College>> getMess({String? query, double? lat, double? lon, double? radius, String? sortBy, String? order}) async {
    final headers = await _getHeaders();
    String queryStr = '?';
    if (query != null) queryStr += 'query=$query&';
    if (lat != null) queryStr += 'lat=$lat&';
    if (lon != null) queryStr += 'lon=$lon&';
    if (radius != null) queryStr += 'radius=$radius&';
    if (sortBy != null) queryStr += 'sort_by=$sortBy&';
    if (order != null) queryStr += 'order=$order&';

    final response = await http.get(
      Uri.parse('$baseUrl/education/mess/$queryStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => College.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load mess');
    }
  }

  Future<List<College>> getCoaching({String? query, double? lat, double? lon, double? radius, String? sortBy, String? order}) async {
    final headers = await _getHeaders();
    String queryStr = '?';
    if (query != null) queryStr += 'query=$query&';
    if (lat != null) queryStr += 'lat=$lat&';
    if (lon != null) queryStr += 'lon=$lon&';
    if (radius != null) queryStr += 'radius=$radius&';
    if (sortBy != null) queryStr += 'sort_by=$sortBy&';
    if (order != null) queryStr += 'order=$order&';

    final response = await http.get(
      Uri.parse('$baseUrl/education/coaching/$queryStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => College.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load coaching');
    }
  }

  // --- Medical Module ---
  Future<Map<String, dynamic>> getHospital(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/medical/hospitals/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load hospital details');
    }
  }

  Future<List<Hospital>> getHospitals({String? query, double? lat, double? lon, double? radius, bool? bloodBank, bool? ambulance, String? sortBy, String? order, String? minRating}) async {
    final headers = await _getHeaders();
    String queryStr = '?';
    if (query != null) queryStr += 'query=$query&';
    if (lat != null) queryStr += 'lat=$lat&';
    if (lon != null) queryStr += 'lon=$lon&';
    if (radius != null) queryStr += 'radius=$radius&';
    if (bloodBank != null && bloodBank) queryStr += 'blood_bank_available=true&';
    if (ambulance != null && ambulance) queryStr += 'ambulance_available=true&';
    if (sortBy != null) queryStr += 'sort_by=$sortBy&';
    if (order != null) queryStr += 'order=$order&';

    final response = await http.get(
      Uri.parse('$baseUrl/medical/hospitals/$queryStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => Hospital.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hospitals');
    }
  }

  Future<List<dynamic>> getHospitalReviews(int hospitalId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/medical/hospitals/$hospitalId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> postHospitalReview(int hospitalId, double rating, String content) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/medical/hospitals/$hospitalId/reviews'),
      headers: headers,
      body: json.encode({
        'rating': rating,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post review');
    }
  }

  // --- Stay Module ---
  Future<Map<String, dynamic>> getPG(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/stay/pgs/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load PG details');
    }
  }

  Future<List<PG>> getPGs({String? query, double? lat, double? lon, double? radius, String? gender, String? sortBy, String? order, String? minRating}) async {
    final headers = await _getHeaders();
    String queryStr = '?';
    if (query != null) queryStr += 'query=$query&';
    if (lat != null) queryStr += 'lat=$lat&';
    if (lon != null) queryStr += 'lon=$lon&';
    if (radius != null) queryStr += 'radius=$radius&';
    if (gender != null) queryStr += 'gender=$gender&';
    if (sortBy != null) queryStr += 'sort_by=$sortBy&';
    if (order != null) queryStr += 'order=$order&';

    final response = await http.get(
      Uri.parse('$baseUrl/stay/pgs/$queryStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => PG.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load PGs');
    }
  }

  Future<List<PG>> getHostels({String? query, double? lat, double? lon, double? radius, String? gender, String? sortBy, String? order, String? minRating}) async {
    final headers = await _getHeaders();
    String queryStr = '?';
    if (query != null) queryStr += 'query=$query&';
    if (lat != null) queryStr += 'lat=$lat&';
    if (lon != null) queryStr += 'lon=$lon&';
    if (radius != null) queryStr += 'radius=$radius&';
    if (gender != null) queryStr += 'gender=$gender&';
    if (sortBy != null) queryStr += 'sort_by=$sortBy&';
    if (order != null) queryStr += 'order=$order&';

    final response = await http.get(
      Uri.parse('$baseUrl/stay/hostels/$queryStr'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      // Hostels use the same PG model for now as they are structurally similar
      return body.map((item) => PG.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Hostels');
    }
  }

  Future<Map<String, dynamic>> getHostelDetails(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/stay/hostels/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Hostel details');
    }
  }

  Future<List<dynamic>> getPGReviews(int pgId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/stay/pgs/$pgId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> postPGReview(int pgId, double rating, String content) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/stay/pgs/$pgId/reviews'),
      headers: headers,
      body: json.encode({
        'rating': rating,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post review');
    }
  }

  Future<List<dynamic>> getHostelReviews(int hostelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/stay/hostels/$hostelId/reviews'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load hostel reviews');
    }
  }

  Future<void> postHostelReview(int hostelId, double rating, String content) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/stay/hostels/$hostelId/reviews'),
      headers: headers,
      body: json.encode({
        'rating': rating,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post hostel review');
    }
  }



  // --- Auth Module ---
  Future<void> register(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'full_name': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
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
      Uri.parse('$baseUrl/profile/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> requestChangePasswordOtp() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/request-change-password-otp'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to request OTP');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, String otpCode) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: headers,
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'otp_code': otpCode,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to change password');
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to send reset code');
    }
  }

  Future<void> resetPassword(String email, String otpCode, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'token': otpCode, // Backend uses 'token' field for the OTP code
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to reset password');
    }
  }
}
