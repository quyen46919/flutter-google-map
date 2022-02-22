// import 'package:dio/dio.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:my_google_map/direction.model.dart';
// import 'package:my_google_map/.env.dart';
//
// class DirectionRepository {
//   static const String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?';
//
//   final Dio dio;
//
//   DirectionRepository({ required this.dio });
//   // DirectionRepository({ required Dio dio }) : _dio = dio ?? Dio();
//
//   Future<Directions?> getDirection({
//     required LatLng origin,
//     required LatLng destination,
//   }) async {
//     final response = await dio.get(
//       baseUrl,
//       queryParameters: {
//         'origin': '${origin.latitude},${origin.longitude}',
//         'destination': '${destination.latitude},${destination.longitude}',
//         'key': googleAPIKey
//       }
//     );
//
//     if (response.statusCode == 200) {
//       return Directions.fromMap(response.data);
//     }
//     return null;
//   }
// }