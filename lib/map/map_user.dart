// ignore_for_file: avoid_print
import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'components_map.dart';

//ignore: must_be_immutable
class MapUserWasteManagementSystem extends StatefulWidget {
  const MapUserWasteManagementSystem({Key? key}) : super(key: key);

  @override
  State<MapUserWasteManagementSystem> createState() =>
      _MapUserWasteManagementSystem();
}

class _MapUserWasteManagementSystem
    extends State<MapUserWasteManagementSystem> {
  @override
  void initState() {
    getPermission();
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      changeMaker(position.latitude, position.longitude);
      getLatAndLongUser();
      getMarkerData();
      getAddressFromLatAndLonUser(position);
      getPolyline(position.latitude, position.longitude);
    });

    super.initState();
  }

  final Completer<GoogleMapController> _controllerMap = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                retSensor(),
                kGooglePlex == null
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 550.0,
                        width: 400.0,
                        child: GoogleMap(
                          markers: Set<Marker>.of(markers.values),
                          polylines: Set<Polyline>.of(polylines.values),
                          myLocationEnabled: true,
                          tiltGesturesEnabled: true,
                          compassEnabled: true,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          mapType: MapType.normal,
                          initialCameraPosition: kGooglePlex!,
                          onMapCreated: (GoogleMapController controller) {
                            _controllerMap.complete(controller);
                          },
                        ),
                      ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: const [
                  ImageIcon(
                    AssetImage("assets/images/Empty.png"),
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Basket -> EMPTY "),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: const [
                  ImageIcon(
                    AssetImage("assets/images/Full.png"),
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Basket -> FULL "),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: const [
                  ImageIcon(
                    AssetImage("assets/images/middle.png"),
                    color: Colors.yellow,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Basket -> MIDDLE(NOT FULL) "),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future getPermission() async {
    bool? services;
    LocationPermission per;
    services = await Geolocator.isLocationServiceEnabled();
    if (services == false) {
      AwesomeDialog(
          context: context,
          title: "Services",
          body: const Text(
            'Services Not Enabled',
          )).show();
    }
    per = await Geolocator.checkPermission();
    if (per == LocationPermission.denied) {
      per = await Geolocator.requestPermission();
    }
    print("=============================");
    print(per);
    print("=============================");
    return per;
  }

  Future<void> getLatAndLongUser() async {
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl!.latitude;
    long = cl!.longitude;
    kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 9.4746,
    );
    if (mounted) setState(() {});
  }

  Future<void> getAddressFromLatAndLonUser(Position position) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    print(placemark);
    Placemark place = placemark[0];

    if (mounted) {
      setState(() {
        street = '${place.street}';
        locality = '${place.locality}';
        postalCode = '${place.postalCode}';
        country = '${place.country}';
      });
    }
    print(street);
    print(locality);
    print(postalCode);
    print(country);
  }

  changeMaker(var newLat, var newLong) async {
    const markerId = MarkerId("worker");
    final marker = Marker(
      markerId: markerId,
      position: LatLng(newLat, newLong),
      onTap: () {
        bottomSheetUser();
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    // await changeBasketIconState();
    gmc?.animateCamera(CameraUpdate.newLatLng(LatLng(newLat, newLong)));
    if (mounted) {
      setState(() {
        markers[markerId] = marker;
      });
    }
  }

  Future<dynamic> bottomSheetUser() {
    return showModalBottomSheet(
        constraints: const BoxConstraints(maxHeight: 200),
        backgroundColor: Colors.black45,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        context: context,
        builder: (builder) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: const [
                      Spacer(),
                      Text(
                        'ID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'user 1',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'Country',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      country.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    // const Spacer(),
                    const Text(
                      'Address:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // const Spacer(),
                    Expanded(
                      child: Text(
                        locality.toString(),
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    // const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    // const Spacer(),
                    const Text(
                      'Street:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // const Spacer(),
                    Expanded(
                      child: Text(
                        street.toString(),
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    // const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        });
  }

  void getMarkerData() {
    if (mounted) {
      setState(() {
        FirebaseFirestore.instance.collection('baskets').get().then((value) {
          if (value.docs.isNotEmpty) {
            new_id = 1;
            for (int i = 0; i < value.docs.length; i++) {
              if (value.docs[i]['isWorking'] == true) {
                if (((value.docs[i]['status'] == 0 ||
                            value.docs[i]['status'] == 1) &&
                        value.docs[i]['Id'] != 1) ||
                    (value.docs[i]['Id'] == 1 && (de == 0 || de == 1))) {
                  initMarker(value.docs[i].data(), value.docs[i].id.toString());
                  print("idddddddd: ${value.docs[i]['Id']}");
                } else {
                  markers.clear();
                }
              }
              new_id++;
            }
            // markers.clear();
          }
        });
      });
    }
  }

  void initMarker(specify, specifyId) async {
    var markerIdVal = specifyId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final marker = Marker(
      markerId: markerId,
      position: LatLng(specify['lat'], specify['lon']),
      onTap: () {
        modalBottomSheetForUser(specify, specifyId);
      },
      // infoWindow: InfoWindow(
      //   title: ' Id : ${specify['Id']}',
      //   snippet: 'Distance : ${distances[specifyId]?.toStringAsFixed(2)} KM',
      // ),
      icon: ((specify['status'] == 0 && specify['Id'] != 1) ||
              (specify['Id'] == 1 && de == 0))
          ? await BitmapDescriptor.fromAssetImage(
              ImageConfiguration.empty, "assets/images/Empty.png")
          : ((specify['status'] == 1 && specify['Id'] != 1) ||
                  (specify['Id'] == 1 && de == 1))
              ? await BitmapDescriptor.fromAssetImage(
                  ImageConfiguration.empty, "assets/images/middle.png")
              : await BitmapDescriptor.fromAssetImage(
                  ImageConfiguration.empty, "assets/images/Full.png"),
    );
    if (mounted) {
      setState(() {
        markers[markerId] = marker;
      });
    }
  }

  var s;

  Future<dynamic> modalBottomSheetForUser(specify, specifyId) async {
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl!.latitude;
    long = cl!.longitude;
    s = calculateDistance(lat, long, specify['lat'], specify['lon']);
    print('Dis : $s');

    List<Placemark> placemark = await placemarkFromCoordinates(
      specify['lat'],
      specify['lon'],
    );
    print(placemark);
    Placemark place = placemark[0];

    setState(() {
      streetBasketUser = '${place.street}';
      localityBasketUser = '${place.locality}';
      postalCodeBasketUser = '${place.postalCode}';
      countryBasketUser = '${place.country}';
    });
    print(streetBasketUser);
    print(localityBasketUser);
    print(postalCodeBasketUser);
    print(countryBasketUser);
    return showModalBottomSheet(
        constraints: const BoxConstraints(maxHeight: double.infinity),
        backgroundColor: Colors.black45,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        context: context,
        builder: (builder) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      const Text(
                        'ID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        specify['Id'].toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'DISTANCE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${s.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'HEIGHT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      specify['height'].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      'RADIUS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      specify['radius'].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      const Text(
                        'Country',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        countryBasketUser.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      const Text(
                        'Address:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          localityBasketUser.toString(),
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5, left: 5),
                  child: Row(
                    children: [
                      const Text(
                        'Street:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          streetBasketUser.toString(),
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      if ((specify['status'] == 0 && specify['Id'] != 1) ||
                          (specify['Id'] == 1 && de == 0))
                        Image.asset('assets/images/Empty.png')
                      else if ((specify['status'] == 1 && specify['Id'] != 1) ||
                          (specify['Id'] == 1 && de == 1))
                        Image.asset('assets/images/middle.png')
                      else
                        Image.asset('assets/images/Full.png'),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  addPolyLine(specifyId) {
    PolylineId id1 = PolylineId(specifyId);
    Polyline polyline1 = Polyline(
        width: 4,
        polylineId: id1,
        color: Colors.deepPurple,
        points: polylineCoordinates);

    if (mounted) {
      setState(() {
        polylines[id1] = polyline1;
      });
    }
  }

  initPolyline(var newLat, var newLong, specify, specifyId) async {
    // Polyline From Worker To ......
    polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(newLat, newLong), // Start Polyline
        PointLatLng(specify['lat'],
            specify['lon']), //30.415010, 31.565889  // End Polyline
        travelMode: TravelMode.driving,
        wayPoints: [
          PolylineWayPoint(
            location: "From Worker To .....",
          ),
        ]);
    // if (result1.points.isNotEmpty) {
    //   result1.points.forEach((PointLatLng point) {
    polylineCoordinates.add(LatLng(newLat, newLong)); // Start Polyline
    polylineCoordinates
        .add(LatLng(specify['lat'], specify['lon'])); // End Polyline
    // }
    // );
    // }

    // calc distance
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance = calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }
    print(totalDistance);

    if (mounted) {
      setState(() {
        distances[specifyId] = totalDistance;
      });
    }
    // addPolyLine(specifyId);
  }

  getPolyline(newLat, newLong) {
    if (mounted) {
      setState(() {
        FirebaseFirestore.instance.collection('baskets').get().then((value) {
          if (value.docs.isNotEmpty) {
            for (int i = 0; i < value.docs.length; i++) {
              if (value.docs[i]['isWorking'] == true) {
                initPolyline(newLat, newLong, value.docs[i].data(),
                    value.docs[i].id.toString());
              }
            }
          }
        });
      });
    }
  }
}

// AIzaSyDtdWNgEPfUGq9OYBJtO5EzNcP000t9Oao
