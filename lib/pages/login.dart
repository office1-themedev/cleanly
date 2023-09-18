import 'package:flutter/material.dart';
import 'package:cleanly_dashboard/service/auth.dart';
import 'package:velocity_x/velocity_x.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({Key ? key}) : super(key: key);

  @override
  _ApiScreenState createState() => _ApiScreenState();
}


class _ApiScreenState extends State<ApiScreen>{

  // call Auth method
  CleanlyAuth authClass = CleanlyAuth();
  // snackbar alert message
  CleanlySnackBar(message,context){
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  // setup cpntroller of input box
  TextEditingController textController = TextEditingController();
  TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
                key: _formKey,
                child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/logo-transparent.png', width: 100,),
                            const SizedBox(
                              height: 50,
                            ),
                            TextFormField(
                              controller: textController,
                              decoration: const InputDecoration(
                                icon: Icon(
                                  Icons.webhook,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),

                                hintText: 'Enter base url',
                                labelText: 'Base URL:',
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Bricolage',
                              ),
                              validator: (String? value) {
                                return (value == null || !value.contains('http')) ? 'Please use valid url' : null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: passController,
                              decoration: const InputDecoration(
                                icon: Icon(
                                  Icons.key_outlined,
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                                hintText: 'Enter api key',
                                labelText: 'API Key:',
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Bricolage',
                              ),
                              validator: (String? value) {
                                return (value == null || value.isEmpty) ? 'Please enter API Key' : null;
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),

                              child: ElevatedButton(
                                onPressed: () {
                                  // Validate will return true if the form is valid, or false if
                                  // the form is invalid.
                                  if (_formKey.currentState!.validate()) {
                                    authClass.login(context, textController.text.toString(), passController.text.toString());
                                  }
                                },
                                style: const ButtonStyle(
                                  padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 30,vertical: 15)),
                                  backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
                                ),
                                child: 'Connect'.text.white.fontFamily('Bricolage').widest.size(20).make()
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
          ),
        )
      );
  }
}
