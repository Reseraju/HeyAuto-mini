import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GMap extends StatefulWidget {
  const GMap({Key? key}) : super(key: key);

  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  final Map<String, Marker> _markers = {};
  late GoogleMapController _mapController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content:
              const Text('Please enable location services to use this app.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Denied'),
            content:
                const Text('Please grant location permission to use this app.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
              'Please enable location permission in the device settings to use this app.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
    _setInitialPosition(position);
  }

  void _setInitialPosition(Position position) {
    final userLatLng = LatLng(position.latitude, position.longitude);
    final cameraPosition = CameraPosition(target: userLatLng, zoom: 15.0);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers.clear();

      if (_currentPosition != null) {
        final userPosition = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        _addMarker(
          userPosition,
          'Your Location',
          'You are here',
        );
      }

      _addMarker(
        const LatLng(9.708380, 76.684914),
        'Pala',
        'Pala',
      );

      _addMarker(
        const LatLng(9.7436839, 76.7062226),
        'Pravithanam',
        'Junction',
      );

      _addMarker(
        const LatLng(9.69945,76.724994),
        'Bharananganam',
        'Church',
      );

      _addMarker(
        const LatLng(9.7267,  76.7250),
        'Choondachery',
        'SJCET College',
      );
    });

    _mapController = controller;
  }

  void _addMarker(LatLng position, String title, String snippet) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );
    _markers[position.toString()] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('HeyAuto',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          onPressed: () {},
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target:  LatLng(9.7267, 76.7250),
          zoom: 15.0,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }
}
