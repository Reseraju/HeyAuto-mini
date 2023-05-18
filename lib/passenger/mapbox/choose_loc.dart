import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/constants.dart';

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({Key? key}) : super(key: key);

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();
  String pickupLocation = '';
  String dropOffLocation = '';
  List<String> locationSuggestions = [];
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark currentPlacemark = placemarks.first;
      String address = '';

      if (currentPlacemark.subThoroughfare != null) {
        address += '${currentPlacemark.subThoroughfare!}, ';
      }
      if (currentPlacemark.thoroughfare != null) {
        address += '${currentPlacemark.thoroughfare!}, ';
      }
      if (currentPlacemark.subLocality != null) {
        address += '${currentPlacemark.subLocality!}, ';
      }
      if (currentPlacemark.locality != null) {
        address += '${currentPlacemark.locality!}, ';
      }
      if (currentPlacemark.subAdministrativeArea != null) {
        address += '${currentPlacemark.subAdministrativeArea!}, ';
      }
      if (currentPlacemark.administrativeArea != null) {
        address += '${currentPlacemark.administrativeArea!}, ';
      }
      if (currentPlacemark.country != null) {
        address += currentPlacemark.country!;
      }

      setState(() {
        pickupLocation = address;
        pickUpController.text = pickupLocation;
      });
    } catch (e) {
      // Handle location retrieval error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
        backgroundColor: const Color.fromARGB(252, 113, 154, 143),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: pickUpController,
              decoration: const InputDecoration(
                labelText: 'Pickup Location',
              ),
              onChanged: (value) {
                setState(() {
                  pickupLocation = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: dropOffController,
              decoration: const InputDecoration(
                labelText: 'Drop-off Location',
              ),
              onChanged: (value) {
                setState(() {
                  dropOffLocation = value;
                  routeCoordinates = [];
                });
                if (value.isNotEmpty) {
                  fetchLocationSuggestions(value).then((suggestions) {
                    setState(() {
                      locationSuggestions = suggestions;
                    });
                  }).catchError((error) {
                    // Handle error if the API request fails
                    print(error);
                  });
                } else {
                  setState(() {
                    locationSuggestions = [];
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            if (locationSuggestions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: locationSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = locationSuggestions[index];
                    return ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        setState(() {
                          dropOffController.text = suggestion;
                          dropOffLocation = suggestion;
                          locationSuggestions = [];
                          routeCoordinates = [];
                        });
                        fetchRouteCoordinates(pickupLocation, dropOffLocation)
                            .then((coordinates) {
                          setState(() {
                            routeCoordinates = coordinates;
                          });
                        }).catchError((error) {
                          // Handle error if the API request fails
                          print(error);
                        });
                      },
                    );
                  },
                ),
              ),
            if (routeCoordinates.isNotEmpty)
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(
                      routeCoordinates.first.latitude,
                      routeCoordinates.first.longitude,
                    ),
                    zoom: 13.0,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    PolylineLayerOptions(
                      polylines: [
                        Polyline(
                          points: routeCoordinates,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> fetchLocationSuggestions(String input) async {
    const apiKey =
        AppConstants.mapBoxAccessToken; 

    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$input.json'
      '?access_token=$apiKey'
      '&country=IN' // Filter by country: India
      '&region=KL' // Filter by region: Kerala
      '&place_type=place' // Filter by place type: place
      '&bbox=76.4043,9.3816,76.7537,9.6645' // Bounding box for Kottayam district
      '&limit=5',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;

      return features.map((feature) {
        final placeName = feature['place_name'] as String;
        final shortenedPlaceName = placeName.split(',')[0]; // Extract the first part of the place name
        return shortenedPlaceName.trim();
      }).toList();
    } else {
      throw Exception('Failed to fetch location suggestions');
    }
  }

  Future<List<LatLng>> fetchRouteCoordinates(
      String pickupLocation, String dropOffLocation) async {
    const apiKey =
        AppConstants.mapBoxAccessToken; // Replace with your Mapbox API access token

    final pickupQuery = Uri.encodeQueryComponent(pickupLocation);
    final dropOffQuery = Uri.encodeQueryComponent(dropOffLocation);

    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/driving/$pickupQuery;'
      '$dropOffQuery.json?access_token=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>;

      if (routes.isNotEmpty) {
        final route = routes.first;
        final geometry = route['geometry'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List<dynamic>;

        return coordinates
            .map((coordinate) =>
                LatLng(coordinate[1] as double, coordinate[0] as double))
            .toList();
      }
    }

    throw Exception('Failed to fetch route coordinates');
  }
}
