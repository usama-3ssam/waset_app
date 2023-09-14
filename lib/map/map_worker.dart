// ignore_for_file: avoid_print
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waste_app/shared/constants.dart';
import '../screens/home_screen.dart';
import '../shared/icon_broken.dart';
import 'basket_list_view.dart';
import 'components_map.dart';
import 'notification.dart';

//ignore: must_be_immutable
class MapWorkerWasteManagementSystem extends StatefulWidget {
  const MapWorkerWasteManagementSystem({Key? key}) : super(key: key);

  @override
  State<MapWorkerWasteManagementSystem> createState() =>
      _MapWorkerWasteManagementSystem();
}

class _MapWorkerWasteManagementSystem
    extends State<MapWorkerWasteManagementSystem> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    getPermission();
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      worker(position.latitude, position.longitude);
      getPolyline(position.latitude, position.longitude);
      getMarkerData();
      getAddressFromLatAndLonWorker(position);

      print("dsdssssssssssssss : $distances");
      print("nearest basket id:  $nearest_basket_id");
      print("Minimum Distance:  $min_d");
    });
    getLatAndLongWorker();
    NotificationsServices.initialize(flutterLocalNotificationsPlugin);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const WestAppLayout(),
              ),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(
            IconBroken.Arrow___Left_2,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Worker',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  var x = 1;
                  if (x == 1) {
                    if (there_is_full_basket == false) {
                      await NotificationsServices.sendNotification(
                        title: "No FULL Baskets",
                        body: "",
                        fln: flutterLocalNotificationsPlugin,
                      );
                    } else {
                      await NotificationsServices.sendNotification(
                        title: "Nearest Basket Id : $nearest_basket_id",
                        body:
                            "Minimum Distance : ${min_d.toStringAsFixed(2)} KM",
                        fln: flutterLocalNotificationsPlugin,
                      );
                    }
                  }

                  if (mounted) setState(() {});
                },
                icon: const Icon(
                  IconBroken.Notification,
                  color: Colors.white,
                ),
              ),
              if (there_is_full_basket == true)
                Positioned(
                  top: 4,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(
                      4,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '.',
                      style: TextStyle(
                        fontSize: 5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const BasketListView();
                  },
                ),
              );
            },
            icon: const Icon(
              IconBroken.Edit,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: defaultColor,
      ),
      body: Stack(
        children: [
          retSensor(),
          queryBasketsInfo(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: defaultFormField(
                  controller: searchController,
                  type: TextInputType.text,
                  onChange: (value) {},
                  onSubmit: (value) async {},
                  onTap: () {},
                  label: 'Location',
                  hint: 'Move Basket To New Location',
                  validate: (String value) {
                    if (value.isEmpty) {
                      return 'Location Must Not Be Empty';
                    }
                    return null;
                  },
                  prefix: Icons.location_on,
                ),
              ),
              kGooglePlex == null
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: SizedBox(
                        height: 600.0,
                        width: 400.0,
                        child: GoogleMap(
                          markers: Set<Marker>.of(markers.values),
                          polylines: Set<Polyline>.of(polylines.values),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          tiltGesturesEnabled: true,
                          compassEnabled: true,
                          trafficEnabled: true,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          mapType: MapType.normal,
                          initialCameraPosition: kGooglePlex!,
                          onMapCreated: (GoogleMapController controller) {
                            controllerMap.complete(controller);
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addNewBasket(new_id, distance, 0);
        },
        backgroundColor: Colors.blue.withOpacity(0.5),
        child: const Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // End Polyline

  Future<void> getAddressFromLatAndLonWorker(Position position) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    print(placemark);
    Placemark place = placemark[0];

    setState(() {
      street = '${place.street}';
      locality = '${place.locality}';
      postalCode = '${place.postalCode}';
      country = '${place.country}';
    });
    print(street);
    print(locality);
    print(postalCode);
    print(country);
  }

  Future<void> getAddressFromLatAndLonBasket(Position position) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    print(placemark);
    Placemark place = placemark[0];

    setState(() {
      street = '${place.street}';
      locality = '${place.locality}';
      postalCode = '${place.postalCode}';
      country = '${place.country}';
    });
    print(street);
    print(locality);
    print(postalCode);
    print(country);
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

  Future<void> getLatAndLongWorker() async {
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl!.latitude;
    long = cl!.longitude;
    kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 9.4746,
    );

    if (mounted) setState(() {});
  }

  worker(var newLat, var newLong) async {
    const markerId = MarkerId('worker 1');
    final marker = Marker(
      markerId: markerId,
      position: LatLng(newLat, newLong),
      onTap: () {
        modalBottomSheetForWorker(context);
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
    addPolyLine(specifyId);
  }

  getPolyline(newLat, newLong) {
    if (mounted) {
      setState(() {
        FirebaseFirestore.instance.collection('baskets').get().then((value) {
          if (value.docs.isNotEmpty) {
            for (int i = 0; i < value.docs.length; i++) {
              if (value.docs[i]['isWorking'] == true) {
                if (value.docs[i]['Id'] == nearest_basket_id &&
                    nearest_basket_id != 0) {
                  polylineCoordinates.clear();
                  initPolyline(newLat, newLong, value.docs[i].data(),
                      value.docs[i].id.toString());
                } else if (nearest_basket_id == 0) {
                  polylineCoordinates.clear();
                }
              }
            }
          }
        });
      });
    }
  }

  Future<void> addNewBasket(id, distance, st) async {
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl!.latitude;
    long = cl!.longitude;
    var newPosition = LatLng(lat, long);
    gmc?.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 15));

    basket.add({
      'Id': id,
      'height': 20,
      'lat': lat,
      'lon': long,
      'radius': 14,
      'status': 0,
      'isWorking': true,
    }).then((DocumentReference doc) {
      print('My Document Id : ${doc.id}');
      print('Length : ${myMarker.length}');
    });

    final marker = Marker(
      markerId: MarkerId(id.toString()),
      infoWindow: InfoWindow(
        title: id,
        snippet: "Total Distance: ${distance.toStringAsFixed(
          2,
        )} KM",
      ),
      position: newPosition,
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty, "assets/images/Empty.png"),
    );

    if (mounted) {
      setState(() {
        markers[MarkerId(new_id.toString())] = marker;
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
        modelBottomSheet(specify, specifyId);
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

  Future<dynamic> modelBottomSheet(specify, specifyId) async {
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
      streetBasketWorker = '${place.street}';
      localityBasketWorker = '${place.locality}';
      postalCodeBasketWorker = '${place.postalCode}';
      countryBasketWorker = '${place.country}';
    });
    print(streetBasketWorker);
    print(localityBasketWorker);
    print(postalCodeBasketWorker);
    print(countryBasketWorker);
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
          return StreamBuilder(
            stream: basket.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
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
                          Expanded(
                            child: Container(
                              height: 35.0,
                              width: 110.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                color: Colors.white,
                              ),
                              child: TextField(
                                controller: editHeight,
                                keyboardType: TextInputType.number,
                                onSubmitted: (value) {
                                  basket.doc(specifyId.toString()).update({
                                    'height': editHeight.text,
                                  });
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                  contentPadding: const EdgeInsets.all(8),
                                  hintText: specify['height'].toString(),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {},
                                onTap: () {
                                  setState(() {});
                                },
                              ),
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
                            'RADIUS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            child: Container(
                              height: 35,
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                color: Colors.white,
                              ),
                              child: TextField(
                                controller: editRadius,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                  contentPadding: const EdgeInsets.all(8),
                                  hintText: specify['radius'].toString(),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (value) {},
                                onTap: () {},
                                onSubmitted: (value) {
                                  basket.doc(specifyId.toString()).update({
                                    'radius': editRadius.text,
                                  });
                                },
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // Row(
                      //   children: [
                      //     const Spacer(),
                      //     const Text(
                      //       'LATITUDE',
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //     Text(
                      //       specify['lat'].toString(),
                      //       style: const TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.green,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),

                      // Row(
                      //   children: [
                      //     const Spacer(),
                      //     const Text(
                      //       'LONGITUDE',
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //     Text(
                      //       specify['lon'].toString(),
                      //       style: const TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.green,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      Row(
                        children: [
                          const Text(
                            'Address:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              localityBasketWorker.toString(),
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
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
                              streetBasketWorker.toString(),
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
                      const SizedBox(
                        height: 10,
                      ),
                      // Row(
                      //   children: [
                      //     const Spacer(),
                      //     const Text(
                      //       'Postal Code',
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //     Text(
                      //       postalCodeBasketWorker.toString(),
                      //       style: const TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.green,
                      //       ),
                      //     ),
                      //     const Spacer(),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 3,
                      // ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text(
                              'Update Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () async {
                              cl = await Geolocator.getCurrentPosition()
                                  .then((value) => value);
                              var lat = cl!.latitude;
                              var long = cl!.longitude;
                              basket_1_lat = lat;
                              basket_1_long = long;
                              var newPosition = LatLng(lat, long);
                              gmc?.animateCamera(
                                  CameraUpdate.newLatLngZoom(newPosition, 15));
                              polylineCoordinates.clear();
                              basket.doc(specifyId.toString()).update({
                                'lat': basket_1_lat,
                                'lon': basket_1_long,
                              });
                              polylineCoordinates.clear();
                              setState(() {});
                            },
                            child: const Icon(
                              IconBroken.Edit,
                              color: Colors.white,
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () async {
                          //     cl = await Geolocator.getCurrentPosition()
                          //         .then((value) => value);
                          //     var lat = cl!.latitude;
                          //     var long = cl!.longitude;
                          //     basket_1_lat = lat;
                          //     basket_1_long = long;
                          //     var newPosition = LatLng(lat, long);
                          //     gmc?.animateCamera(
                          //         CameraUpdate.newLatLngZoom(newPosition, 15));
                          //     polylineCoordinates.clear();
                          //     basket.doc(specifyId.toString()).update({
                          //       'lat': basket_1_lat,
                          //       'lon': basket_1_long,
                          //     });
                          //     polylineCoordinates.clear();
                          //     setState(() {});
                          //   },
                          //   icon: const Icon(
                          //     Icons.edit,
                          //     color: Colors.white,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            const Spacer(),
                            if ((specify['status'] == 0 &&
                                    specify['Id'] != 1) ||
                                (specify['Id'] == 1 && de == 0))
                              Image.asset('assets/images/Empty.png')
                            else if ((specify['status'] == 1 &&
                                    specify['Id'] != 1) ||
                                (specify['Id'] == 1 && de == 1))
                              Image.asset('assets/images/middle.png')
                            else
                              Image.asset('assets/images/Full.png'),
                            const Spacer(),
                            IconButton(
                              onPressed: () async {
                                markers.clear();
                                polylineCoordinates.clear();
                                basket.doc(specifyId.toString()).update({
                                  'isWorking': false,
                                });
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                              ),
                            ),
                            // Container(
                            //   child: TextButton(
                            //     onPressed: () {
                            //       setState(() {
                            //         test_Is_Working = !test_Is_Working;
                            //         markers.clear();
                            //         polylineCoordinates.clear();
                            //         basket.doc(specifyId.toString()).update({
                            //           'isWorking': test_Is_Working,
                            //         });
                            //       });
                            //     },
                            //     child: specify['isWorking']
                            //         ? const Text(
                            //             'Working',
                            //             style: TextStyle(
                            //               fontSize: 25,
                            //               color: Colors.black,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //           )
                            //         : const Text(
                            //             'Not Working',
                            //             style: TextStyle(
                            //               fontSize: 25,
                            //               color: Colors.black,
                            //               fontWeight: FontWeight.bold,
                            //             ),
                            //           ),
                            //     style: ButtonStyle(
                            //       backgroundColor: specify['isWorking']
                            //           ? const MaterialStatePropertyAll(
                            //               Colors.green)
                            //           : const MaterialStatePropertyAll(
                            //               Colors.red,
                            //             ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        });
  }

  // var min_d = -1.0;
  // void getMinDistance(specify, specifyId) {
  //   if ((specify['status'] == 2 && specify['Id'] != 1) ||
  //       (specify['Id'] == 1 && de == 2)) {
  //     var s = distances[specifyId];
  //     if (s! < min_d || min_d == -1.0) {
  //       print("min Distance : $s");
  //       min_d = s;
  //       nearest_basket_id = specify['Id'];
  //     }
  //   }
  // }

  var there_is_full_basket = false;
  var s;
  var min_d = -1.0;
  var nearest_basket_id = 0;

  void getMarkerData() async {
    cl = await Geolocator.getCurrentPosition().then((value) => value);
    lat = cl!.latitude;
    long = cl!.longitude;
    var test_min_d = -1.0;
    there_is_full_basket = false;
    nearest_basket_id = 0;
    if (mounted) {
      setState(() {
        FirebaseFirestore.instance
            .collection('baskets')
            .get()
            .then((value) async {
          if (value.docs.isNotEmpty) {
            new_id = 1;
            for (int i = 0; i < value.docs.length; i++) {
              if (value.docs[i]['isWorking'] == true) {
                if ((value.docs[i]['status'] == 2 &&
                        value.docs[i]['Id'] != 1) ||
                    (value.docs[i]['Id'] == 1 && de == 2)) {
                  there_is_full_basket = true;
                  s = calculateDistance(
                      lat, long, value.docs[i]['lat'], value.docs[i]['lon']);
                  print('Dis : $s');

                  if (s < test_min_d || test_min_d == -1.0) {
                    print("min Distance : $s");
                    min_d = s;
                    test_min_d = s;
                    nearest_basket_id = value.docs[i]['Id'];
                  }
                }
                initMarker(value.docs[i].data(), value.docs[i].id.toString());
              }

              new_id++;
            }
          }
        });
      });
      if (mounted) setState(() {});
    }
  }

  var not;
  var col;
  bool full_3 = false;
  bool full_2 = false;

  Widget defaultFormField({
    required TextEditingController controller,
    required TextInputType type,
    required String label,
    required Function validate,
    required IconData prefix,
    String hint = 'Search',
    bool isClickable = true,
    Function? onSubmit,
    Function? onChange,
    Function? onTap,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: type,
        onTap: () {
          onTap!();
        },
        onFieldSubmitted: (value) {
          onSubmit!(value);
        },
        onChanged: (value) {
          onChange!(value);
        },
        validator: (value) {
          return validate(value);
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            prefix,
          ),
          border: const OutlineInputBorder(),
        ),
      );
}
// AIzaSyDtdWNgEPfUGq9OYBJtO5EzNcP000t9Oao
