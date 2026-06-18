import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mygate_coepd/services/api_service.dart';

/// Repository for all Household Management API calls:
/// - Family Members
/// - Vehicles
/// - Pets
class HouseholdRepository {
  final ApiService _apiService = ApiService();

  // ─────────────────────────────────────────────────────
  //  FAMILY MEMBERS
  // ─────────────────────────────────────────────────────

  /// GET /api/family — fetch all family members for current resident
  Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    try {
      final response = await _apiService.dio.get('/family');
      log('getFamilyMembers: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      }
      throw Exception(response.data?['message'] ?? 'Failed to fetch family members');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// POST /api/family — add a new family member
  Future<void> addFamilyMember({
    required String name,
    required String relation,
    String? memberType,
    String? phone,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'relation': relation,
      };
      if (memberType != null && memberType.isNotEmpty) data['member_type'] = memberType;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (imageUrl != null && imageUrl.isNotEmpty) data['image_url'] = imageUrl;

      final response = await _apiService.dio.post('/family', data: data);
      log('addFamilyMember: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to add family member');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// DELETE /api/family/{id} — soft-delete a family member
  Future<void> deleteFamilyMember(String id) async {
    try {
      final response = await _apiService.dio.delete('/family/$id');
      log('deleteFamilyMember($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to delete family member');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// PUT /api/family/{id} — update a family member
  Future<void> updateFamilyMember({
    required String id,
    String? name,
    String? relation,
    String? memberType,
    String? phone,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (relation != null && relation.isNotEmpty) data['relation'] = relation;
      if (memberType != null && memberType.isNotEmpty) data['member_type'] = memberType;
      if (phone != null) data['phone'] = phone;
      if (imageUrl != null) data['image_url'] = imageUrl;

      if (data.isEmpty) {
        throw Exception('No fields to update');
      }

      final response = await _apiService.dio.put('/family/$id', data: data);
      log('updateFamilyMember($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to update family member');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  // ─────────────────────────────────────────────────────
  //  VEHICLE TYPES
  // ─────────────────────────────────────────────────────

  /// GET /api/vehicles/types — fetch available vehicle types
  Future<List<Map<String, dynamic>>> getVehicleTypes() async {
    try {
      final response = await _apiService.dio.get('/vehicles/types');
      log('getVehicleTypes: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      }
      throw Exception(response.data?['message'] ?? 'Failed to fetch vehicle types');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  // ─────────────────────────────────────────────────────
  //  VEHICLES
  // ─────────────────────────────────────────────────────

  /// GET /api/vehicles — fetch all vehicles for current resident
  Future<List<Map<String, dynamic>>> getVehicles() async {
    try {
      final response = await _apiService.dio.get('/vehicles');
      log('getVehicles: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      }
      throw Exception(response.data?['message'] ?? 'Failed to fetch vehicles');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// POST /api/vehicles — add a new vehicle
  /// [vehicleTypeId] is required (use getVehicleTypes() to fetch IDs).
  /// [registrationNumber] must be 5-15 alphanumeric characters (backend validates).
  Future<void> addVehicle({
    required String registrationNumber,
    required int vehicleTypeId,
    String? make,
    String? model,
    String? color,
    String? parkingSpot,
    int? isElectric,
    int? isParked,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'registration_number': registrationNumber.toUpperCase(),
        'vehicle_type_id': vehicleTypeId,
      };
      if (make != null && make.isNotEmpty) data['make'] = make;
      if (model != null && model.isNotEmpty) data['model'] = model;
      if (color != null && color.isNotEmpty) data['color'] = color;
      if (parkingSpot != null && parkingSpot.isNotEmpty) {
        data['parking_spot'] = parkingSpot;
      }
      if (isElectric != null) data['is_electric'] = isElectric;
      if (isParked != null) data['is_parked'] = isParked;
      if (imageUrl != null) data['image_url'] = imageUrl;

      final response = await _apiService.dio.post('/vehicles', data: data);
      log('addVehicle: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to add vehicle');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// DELETE /api/vehicles/{id}
  Future<void> deleteVehicle(String id) async {
    try {
      final response = await _apiService.dio.delete('/vehicles/$id');
      log('deleteVehicle($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to delete vehicle');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// PUT /api/vehicles/{id} — update a vehicle
  Future<void> updateVehicle({
    required String id,
    int? vehicleTypeId,
    String? make,
    String? model,
    String? color,
    String? parkingSpot,
    int? isElectric,
    int? isParked,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (vehicleTypeId != null) data['vehicle_type_id'] = vehicleTypeId;
      if (make != null) data['make'] = make;
      if (model != null) data['model'] = model;
      if (color != null) data['color'] = color;
      if (parkingSpot != null) data['parking_spot'] = parkingSpot;
      if (isElectric != null) data['is_electric'] = isElectric;
      if (isParked != null) data['is_parked'] = isParked;
      if (imageUrl != null) data['image_url'] = imageUrl;

      if (data.isEmpty) {
        throw Exception('No fields to update');
      }

      final response = await _apiService.dio.put('/vehicles/$id', data: data);
      log('updateVehicle($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to update vehicle');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  // ─────────────────────────────────────────────────────
  //  PET TYPES
  // ─────────────────────────────────────────────────────

  /// GET /api/pets/types — fetch available pet types
  Future<List<Map<String, dynamic>>> getPetTypes() async {
    try {
      final response = await _apiService.dio.get('/pets/types');
      log('getPetTypes: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      }
      throw Exception(response.data?['message'] ?? 'Failed to fetch pet types');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  // ─────────────────────────────────────────────────────
  //  PETS
  // ─────────────────────────────────────────────────────

  /// GET /api/pets — fetch all pets for current resident
  Future<List<Map<String, dynamic>>> getPets() async {
    try {
      final response = await _apiService.dio.get('/pets');
      log('getPets: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        if (data != null && data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      }
      throw Exception(response.data?['message'] ?? 'Failed to fetch pets');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// POST /api/pets — add a new pet
  /// [petTypeId] is required (use getPetTypes() to fetch IDs).
  Future<void> addPet({
    required String name,
    required int petTypeId,
    String? breed,
    int? age,
    double? weight,
    String? vaccinationStatus,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'pet_type_id': petTypeId,
      };
      if (breed != null && breed.isNotEmpty) data['breed'] = breed;
      if (age != null) data['age'] = age;
      if (weight != null) data['weight'] = weight;
      if (vaccinationStatus != null && vaccinationStatus.isNotEmpty) {
        data['vaccination_status'] = vaccinationStatus;
      }
      if (notes != null && notes.isNotEmpty) data['notes'] = notes;
      if (imageUrl != null && imageUrl.isNotEmpty) data['image_url'] = imageUrl;

      final response = await _apiService.dio.post('/pets', data: data);
      log('addPet: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to add pet');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// DELETE /api/pets/{id}
  Future<void> deletePet(String id) async {
    try {
      final response = await _apiService.dio.delete('/pets/$id');
      log('deletePet($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to delete pet');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// PUT /api/pets/{id} — update a pet (uses form-data approach)
  Future<void> updatePet({
    required String id,
    int? petTypeId,
    String? name,
    String? breed,
    int? age,
    double? weight,
    String? vaccinationStatus,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (petTypeId != null) data['pet_type_id'] = petTypeId;
      if (breed != null) data['breed'] = breed;
      if (age != null) data['age'] = age;
      if (weight != null) data['weight'] = weight;
      if (vaccinationStatus != null) data['vaccination_status'] = vaccinationStatus;
      if (notes != null) data['notes'] = notes;
      if (imageUrl != null) data['image_url'] = imageUrl;

      if (data.isEmpty) {
        throw Exception('No fields to update');
      }

      // Backend does not have a dedicated PUT for pets, so we use addPet-like approach
      // or attempt a direct PUT (may need backend adjustment)
      final response = await _apiService.dio.put('/pets/$id', data: data);
      log('updatePet($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to update pet');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  // ─────────────────────────────────────────────────────
  //  DAILY HELP (via Visitors table)
  // ─────────────────────────────────────────────────────

  /// POST /api/visitors — register a daily helper as a recurring visitor
  /// Uses visitorType = 'service' to distinguish from guests.
  Future<void> addDailyHelper({
    required String name,
    required String phone,
    required String serviceType,
    String? daysOfWeek,
    String? visitTime,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'phone': phone,
        'purpose': serviceType,
        'visitor_type': 'service',
      };
      if (visitTime != null && visitTime.isNotEmpty) {
        data['visit_time'] = visitTime;
      }
      if (imageUrl != null) data['image_url'] = imageUrl;

      final response = await _apiService.dio.post('/visitors', data: data);
      log('addDailyHelper: ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to add daily helper');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// GET /api/visitors?visitor_type=service — fetch all recurring daily helpers
  Future<List<Map<String, dynamic>>> getDailyHelpers() async {
    try {
      final response = await _apiService.dio.get(
        '/visitors',
        queryParameters: {'visitor_type': 'service', 'limit': 50},
      );
      log('getDailyHelpers: ${response.data}');
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'];
        // Visitor list is nested under data.data (paginated)
        if (data != null && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      }
      throw Exception(response.data?['message'] ?? 'Failed to fetch daily helpers');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// DELETE /api/visitors/{id}
  Future<void> deleteDailyHelper(int id) async {
    try {
      final response = await _apiService.dio.delete('/visitors/$id');
      log('deleteDailyHelper($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to delete daily helper');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }

  /// PUT /api/visitors/{id} — update a daily helper's info
  Future<void> updateDailyHelper({
    required int id,
    String? name,
    String? phone,
    String? purpose,
    String? visitTime,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      if (purpose != null) data['purpose'] = purpose;
      if (visitTime != null) data['visit_time'] = visitTime;
      if (imageUrl != null) data['image_url'] = imageUrl;

      if (data.isEmpty) {
        throw Exception('No fields to update');
      }

      // Use PATCH or PUT to update visitor fields
      final response = await _apiService.dio.put('/visitors/$id', data: data);
      log('updateDailyHelper($id): ${response.data}');
      if (response.data == null || response.data['status'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to update daily helper');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    }
  }
}
