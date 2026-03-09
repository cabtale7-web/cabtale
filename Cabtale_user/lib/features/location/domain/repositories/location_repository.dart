import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/location/domain/repositories/location_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocationRepository implements LocationRepositoryInterface{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  LocationRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> getZone(String lat, String lng) async {
    return await apiClient.getData('${AppConstants.getZone}?lat=$lat&lng=$lng');
  }

  @override
  Future<Response> getAddressFromGeocode(LatLng? latLng) async {
    return await apiClient.getData('${AppConstants.geoCodeURI}?lat=${latLng!.latitude}&lng=${latLng.longitude}');
  }

  @override
  Future<Response> searchLocation(String text) async {
    final String query = text.trim();
    final Response response = await apiClient.getData(
      '${AppConstants.searchLocationUri}?search_text=${Uri.encodeQueryComponent(query)}',
    );

    if (_shouldUseSearchFallback(response, query)) {
      final Response? fallbackResponse = await _searchLocationFallback(query);
      if (fallbackResponse != null) {
        return fallbackResponse;
      }
    }

    return response;
  }

  @override
  Future<Response> getPlaceDetails(String placeID) async {
    return await apiClient.getData('${AppConstants.placeApiDetails}?placeid=$placeID');
  }

  @override
  Future<bool> saveUserAddress(Address? address) async {
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token) ?? '', address,
    );
    if(address == null) {
      if(sharedPreferences.containsKey(AppConstants.userAddress)) {
        return await sharedPreferences.remove(AppConstants.userAddress);
      }else {
        return true;
      }
    }else {
      return await sharedPreferences.setString(AppConstants.userAddress, jsonEncode(address.toJson()));
    }
  }

  @override
  String? getUserAddress() {
    return sharedPreferences.getString(AppConstants.userAddress);
  }

  bool _shouldUseSearchFallback(Response response, String query) {
    if (query.isEmpty) {
      return false;
    }

    if (response.statusCode != 200 || response.body is! Map) {
      return true;
    }

    final Map<String, dynamic> body = Map<String, dynamic>.from(response.body);
    final Map<String, dynamic> data = body['data'] is Map
        ? Map<String, dynamic>.from(body['data'])
        : <String, dynamic>{};
    final List<dynamic> predictions = data['predictions'] is List
        ? List<dynamic>.from(data['predictions'])
        : <dynamic>[];
    final String status = data['status']?.toString().toUpperCase() ?? '';
    final String errorMessage = data['error_message']?.toString() ?? '';

    return status == 'REQUEST_DENIED' ||
        errorMessage.isNotEmpty ||
        predictions.isEmpty;
  }

  Future<Response?> _searchLocationFallback(String query) async {
    try {
      final Uri uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'jsonv2',
        'limit': '6',
        'addressdetails': '1',
      });

      final http.Response response = await http.get(uri, headers: {
        'User-Agent': '${AppConstants.appName}/${AppConstants.appVersion}',
        'Accept': 'application/json',
      });

      if (response.statusCode != 200) {
        return null;
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return null;
      }

      final List<Map<String, dynamic>> predictions = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) =>
              item['display_name'] != null &&
              item['lat'] != null &&
              item['lon'] != null)
          .map((item) => <String, dynamic>{
                'description': item['display_name'].toString(),
                'id': item['place_id']?.toString(),
                'place_id': 'coords:${item['lat']},${item['lon']}',
                'reference': 'nominatim',
              })
          .toList(growable: false);

      return Response(statusCode: 200, body: {
        'response_code': 'default_200',
        'message': 'Successfully loaded',
        'data': {
          'predictions': predictions,
          'status': 'OK',
        },
        'errors': [],
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(value, {int? id}) {
    // TODO: implement update
    throw UnimplementedError();
  }

}
