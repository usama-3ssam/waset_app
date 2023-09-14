// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_app/screens/selected_role.dart';
import 'package:waste_app/shared/constants.dart';
import '../controller/app_cubit/cubit.dart';
import '../controller/app_cubit/states.dart';
import '../map/map_worker.dart';
import '../model/request_model.dart';
import '../shared/drawer.dart';
import '../shared/icon_broken.dart';
import 'chat_details_screen.dart';

//ignore: must_be_immutable
class WestAppLayout extends StatefulWidget {
  const WestAppLayout({Key? key}) : super(key: key);

  @override
  State<WestAppLayout> createState() => _WestAppLayoutState();
}

class _WestAppLayoutState extends State<WestAppLayout> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WasteAppCubit, WasteAppState>(
      listener: (context, state) async {
        WasteAppCubit.get(context).userModel;
      },
      builder: (context, state) {
        var cubit = WasteAppCubit.get(context);
        // get user data
        if (cubit.userModel == null) {
          cubit.getUserData();
          cubit.getRequests();
        }
        if (cubit.userModel!.subscribe == true) {
          return Scaffold(
            appBar: AppBar(
              elevation: 5,
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            drawer:
                cubit.userModel != null ? const NavigationDrawerWidget() : null,
            body: cubit.screens[cubit.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeBottomScreen(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    IconBroken.Home,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    IconBroken.Category,
                  ),
                  label: 'Recycling Category',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    IconBroken.Message,
                  ),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    IconBroken.Location,
                  ),
                  label: 'Baskets Location',
                ),
              ],
            ),
          );
        } else if (cubit.userModel!.subscribe == false) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Requests",
                style: TextStyle(color: Colors.white),
              ),
              elevation: 10.0,
              backgroundColor: defaultColor,
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
                color: Colors.white,
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 10,
                ),
                child: Column(
                  children: [
                    if (WasteAppCubit.get(context).userModel?.image != null)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => buildRequestItem(
                          WasteAppCubit.get(context).request[index],
                          context,
                          index,
                          // usermodel: WasteAppCubit.get(context).usersData[index]
                        ),
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 10,
                        ),
                        itemCount: WasteAppCubit.get(context).request.length,
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            drawer: WasteAppCubit.get(context).userModel != null
                ? const NavigationDrawerWidget()
                : null,
            floatingActionButton: FloatingActionButton(
              backgroundColor: defaultColor,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MapWorkerWasteManagementSystem(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Icon(
                IconBroken.Location,
                size: 30,
                color: Colors.white,
              ),
            ),
          );
        } else {
          return const SelectedRole();
        }
      },
    );
  }

  Widget buildRequestItem(
    RequestModel model,
    context,
    index,
    // {required UserModel usermodel}
  ) =>
      model.uId != WasteAppCubit.get(context).userModel!.uId
          ? Dismissible(
              movementDuration: const Duration(seconds: 1),
              resizeDuration: const Duration(seconds: 1),
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              // key: UniqueKey(),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: defaultColor,
                            radius: 30.0,
                            child: const Text(
                              'R',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Request from : ${model.name}',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Location : ${model.location}!',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${model.dateTime}',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          // IconButton(
                          //   onPressed: () {
                          //     // AppCubit.get(context).updateData(
                          //     //   states: 'done',
                          //     //   id: model['id'],
                          //     // );
                          //   },
                          //   icon: const Icon(
                          //     Icons.check_box,
                          //     color: Colors.green,
                          //   ),
                          // ),
                        ],
                      ),
                      if (model.uId !=
                          WasteAppCubit.get(context).userModel!.uId)
                        const SizedBox(
                          height: 10,
                        ),
                      if (model.uId !=
                          WasteAppCubit.get(context).userModel!.uId)
                        Padding(
                          padding: const EdgeInsets.all(
                            10.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetailsScreen(
                                          receiverUserDataModel:
                                              WasteAppCubit.get(context)
                                                  .userModel!,
                                          // receiverUserDataModel: usermodel,
                                          fromRequest: true,
                                          fromPost: false,
                                          user2: model,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        IconBroken.Chat,
                                        color: defaultColor,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'communicate with ${model.name}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              background: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(.5),
                    color: Colors.red.shade400,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.delete,
                      color: defaultColor.withOpacity(.7),
                      size: 100.0,
                    ),
                  ),
                ),
              ),
              onDismissed: (direction) async {
                if (WasteAppCubit.get(context).changeDirection(direction) ==
                    DismissDirection.startToEnd) {
                  await WasteAppCubit.get(context).deleteRequest(
                      WasteAppCubit.get(context).requestId[index]);
                  setState(() {
                    WasteAppCubit.get(context).request = [];
                    // WasteAppCubit.get(context).getRequests();
                  });
                } else {
                  await WasteAppCubit.get(context).deleteRequest(
                      WasteAppCubit.get(context).requestId[index]);
                  setState(() {
                    WasteAppCubit.get(context).request = [];
                    // WasteAppCubit.get(context).getRequests();
                  });
                }
              },
            )
          : const SizedBox(
              height: 0.0,
            );
}
