// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_app/controller/app_cubit/cubit.dart';
import '../controller/app_cubit/states.dart';
import '../shared/componentes.dart';
import '../shared/constants.dart';
import '../shared/icon_broken.dart';
import 'home_screen.dart';

//ignore: must_be_immutable
class RequestScreen extends StatelessWidget {
  RequestScreen({Key? key}) : super(key: key);

  var textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var phoneController = TextEditingController();
  var locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WasteAppCubit, WasteAppState>(
        listener: (context, state) {},
        builder: (context, state) {
          locationController.text = locationController.text;
          return Scaffold(
            appBar: AppBar(
              elevation: 10,
              backgroundColor: defaultColor,
              centerTitle: true,
              title: const Text(
                'Request',
                style: TextStyle(
                  // fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  IconBroken.Arrow___Left_2,
                  color: Colors.white,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state is WasteAppCreatePostLoadingState)
                      const LinearProgressIndicator(),
                    if (state is WasteAppCreatePostLoadingState)
                      const SizedBox(
                        height: 10,
                      ),
                    Icon(
                      IconBroken.Danger,
                      color: Colors.grey[300],
                      size: 300,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: formKey,
                      child: defaultTextFormField(
                        controller: locationController,
                        type: TextInputType.text,
                        validate: (String? value) {
                          if (value!.isEmpty) {
                            return 'Location must not be empty';
                          }
                          return null;
                        },
                        label: 'Location',
                        prefix: IconBroken.Location,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 300,
                      height: 50,
                      child: MaterialButton(
                          child: Text(
                            'Send Request'.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            formKey.currentState!.validate();
                            if (formKey.currentState!.validate()) {
                              await WasteAppCubit.get(context).getRequests();
                              var now = DateTime.now();
                              WasteAppCubit.get(context)
                                  .createRequest(
                                dateTime: now.toString(),
                                text:
                                    'Request from ${WasteAppCubit.get(context).userModel!.name} ',
                                location: locationController.text,
                              )
                                  .then((value) {
                                locationController.text =
                                    locationController.text;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WestAppLayout(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              });
                              showToast(
                                text: 'The request has been sent',
                                state: ToastState.SUCCESS,
                              );
                              // onPressed: function,
                            } else {
                              showToast(
                                text: 'Location required!!',
                                state: ToastState.ERROR,
                              );
                            }
                          }),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: defaultColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
