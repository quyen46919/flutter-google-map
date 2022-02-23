import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_google_map/.env.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(16.0323, 108.2211),
    zoom: 13
  );

  late GoogleMapController _googleMapController;

  late final Marker _origin = Marker(
    markerId: const MarkerId('DONG_A_University'),
    infoWindow: InfoWindow(
        title: 'Dong A University',
        onTap: () {
          setState(() {
            _markerList.remove(_markerList.firstWhere(
                    (Marker marker) => marker.markerId.value == _origin.markerId.value)
            );
          });
        }
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    position: const LatLng(16.0323, 108.2211),
  );
  late final Set<Marker> _markerList = {_origin};

  late Marker _destination;

  // Object for PolylinePoints
  late PolylinePoints polylinePoints;

  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];

  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  // Create the polylines for showing the route between two places
  Future<Polyline> _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    print('Call api to get polylines information');

    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );
    print(result.errorMessage);
    print(result.status);
    print(result.points);

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    // Defining an ID
    PolylineId id = const PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    // Adding the polyline to the map
    polylines[id] = polyline;

    return polyline;
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition)
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) => _googleMapController = controller,
        markers: _markerList,
        polylines: Set<Polyline>.of(polylines.values),
        onTap: (LatLng latLng) {
          if (_markerList.length != 2) {
            final lat = latLng.latitude;
            final long = latLng.longitude;
            _destination = Marker(
              markerId: MarkerId(latLng.toString()),
              infoWindow: InfoWindow(
                  title: 'Click here to delete checkpoint',
                  onTap: () {
                    print('lat: $lat, long: $long');
                    setState(() {
                      _markerList.remove(_markerList.firstWhere(
                              (Marker marker) => marker.markerId.value == latLng.toString())
                      );
                    });
                  }
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              position: LatLng(lat, long),
            );
            setState(() {
              if (_markerList.length < 2) {
                _markerList.add(_destination);
              }
              if (_markerList.length == 2) {
                _createPolylines(
                    _markerList.elementAt(0).position.latitude,
                    _markerList.elementAt(0).position.longitude,
                    latLng.latitude,
                    latLng.longitude
                );
              }
            });
          };
        },
      ),
    );
  }
}
