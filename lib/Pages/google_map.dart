import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import  'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:map_tracker/constants.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final locationController = Location();
//  LatLng(6.8751658, 7.4122716)

  static const googlePlex =  LatLng(8.8501400, 9.43316); 
  static const mountainView = LatLng(8.7667200, 9.4242738); 
 
 LatLng?currentPosition;
 Map<PolylineId, Polyline> polylines = {};

@override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async {
    await  intializeMap();
    });
  }

  Future<void>intializeMap()async{
    await fetchLocationUpdate();
    final coordinates = await fetchPolylinePoints();
    generatePolylineFromPoints(coordinates);
  }

  @override
  Widget build(BuildContext context) {
    return currentPosition == null 
    ? const Center(child: CircularProgressIndicator(
      color: Colors.white,
    ),)
    :
     GoogleMap(
      // fortyFiveDegreeImageryEnabled: true,
      mapType: MapType.hybrid,
     
      myLocationEnabled: true,
      trafficEnabled: true,
      
      
        initialCameraPosition:
         const CameraPosition(
          target: googlePlex, zoom: 14.0 ),
        markers:  {
           Marker(
            markerId: const MarkerId('currentLocation'),
            icon:BitmapDescriptor.defaultMarker,
            position: currentPosition!,
             ),
        const Marker(
            markerId: MarkerId('SourceLocation'),
            icon:BitmapDescriptor.defaultMarker,
            position: googlePlex
             ),
             const Marker(
            markerId: MarkerId('DestinationLocation'),
            icon:BitmapDescriptor.defaultMarker,
            position: mountainView

             )
        },
        polylines: Set<Polyline>.of(polylines.values),
      ); 
  
  }
  Future<void>fetchLocationUpdate()async{
  bool serviceEnabled;
  PermissionStatus permissonGranted;

  serviceEnabled = await locationController.serviceEnabled();
  if(serviceEnabled){
    serviceEnabled = await locationController.requestService();
   }else{
      return;
    }

    permissonGranted = await locationController.hasPermission();
    if(permissonGranted == PermissionStatus.denied){
      permissonGranted = await locationController.requestPermission();
      if(permissonGranted != permissonGranted){
        return;
      }
    }

    locationController.onLocationChanged.listen(( currentLocation){
      if(currentLocation.latitude != null &&
      currentLocation.longitude !=null){
        setState(() {
           currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!, );
        });
      }
    });
  }
   

Future<List<LatLng>> fetchPolylinePoints() async {
  final polylinePoints = PolylinePoints();

  final request = PolylineRequest(
    origin: PointLatLng(googlePlex.latitude, googlePlex.longitude),
    destination: PointLatLng(mountainView.latitude, mountainView.longitude),
    mode: TravelMode.driving,

  );

  final result = await polylinePoints.getRouteBetweenCoordinates( 
    googleApiKey: GoogleMapsApiKey,
    request: request,  // Pass the request object here
  );
  
  if (result.points.isNotEmpty) {
    return result.points.map((point) => LatLng(
      point.latitude, point.longitude)).toList(); 
  } else {
    debugPrint(result.errorMessage);
    return [];
  }                          
}


Future<void>generatePolylineFromPoints(
  List<LatLng>polylineCoordinates)async{
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() {
    polylines[id] = polyline;
    });
  }

}


