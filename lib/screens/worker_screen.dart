// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_app/controller/app_cubit/states.dart';
import '../controller/app_cubit/cubit.dart';
import '../shared/drawer.dart';

//ignore: must_be_immutable
class WorkerScreen extends StatefulWidget {
  const WorkerScreen({Key? key}) : super(key: key);

  @override
  State<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WasteAppCubit, WasteAppState>(
      listener: (context, state) async {},
      builder: (context, state) {
        // get user data

        if (WasteAppCubit.get(context).request.isEmpty ||
            WasteAppCubit.get(context).userModel == null) {
          WasteAppCubit.get(context).getUserData();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Worker",
            ),
            elevation: 0.0,
            backgroundColor: Colors.white,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),

          drawer: WasteAppCubit.get(context).userModel != null
              ? const NavigationDrawerWidget()
              : null,
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: defaultColor,
          //   onPressed: () {
          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const MapWorkerWasteManagementSystem(),
          //       ),
          //       (Route<dynamic> route) => false,
          //     );
          //   },
          //   child: const Icon(
          //     IconBroken.Location,
          //     size: 30,
          //     color: Colors.black,
          //   ),
          // ),
        );
      },
    );
  }
}
