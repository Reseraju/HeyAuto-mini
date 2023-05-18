import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:newheyauto/passenger/mapbox/choose_loc.dart';
import '../constants/constants.dart';

class PassHome extends StatefulWidget {
  const PassHome({Key? key}) : super(key: key);

  @override
  _PassHomeState createState() => _PassHomeState();
}

class _PassHomeState extends State<PassHome> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  LatLng? currentLocation;
  String? mapboxAccessToken;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    loadMapboxAccessToken();
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void loadMapboxAccessToken() async {
  await dotenv.load();
  setState(() {
    mapboxAccessToken = dotenv.env['MAPBOX_API_TOKEN'];
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(252, 113, 154, 143),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        // backgroundColor: const Color.fromARGB(255, 33, 32, 32),
        title: const Text('HeyAuto', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              minZoom: 5,
              maxZoom: 18,
              zoom: 13,
              center: currentLocation ?? AppConstants.myLocation,
              interactiveFlags: InteractiveFlag.all &
                  ~InteractiveFlag.rotate, // Disable rotation
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/reeseraju/clhs1s59b01zm01pnba5fcfmw/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmVlc2VyYWp1IiwiYSI6ImNsaHMwY3NtZDB3NjUzZW52em84OWYzMDEifQ.Azly3_V4W5MuSaN--vnzog",
                additionalOptions: {
                  'mapStyleId': AppConstants.mapBoxStyleId,
                  'accessToken': AppConstants.mapBoxAccessToken,
                },
              ),
              MarkerLayerOptions(
                markers: [
                  if (currentLocation != null)
                    Marker(
                      height: 40,
                      width: 40,
                      point: currentLocation!,
                      builder: (context) => const Icon(
                        Icons.location_on,
                        color: Colors.red, // Customize the color if needed
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 40,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChooseLocation()),
                  );
                }, 
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Where to?',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
