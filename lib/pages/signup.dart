import 'dart:convert';
import 'dart:developer';
import 'package:blog/pages/HomePage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blog/NetworkHandler.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  final bool isSignin;
  const Signup({super.key, required this.isSignin});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool vis = true;
  final _globalkey = GlobalKey<FormState>();
  Networkhandler networkhandler = Networkhandler();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String errorText = '';
  bool validate = false;
  bool circular = false;
  final storage = new FlutterSecureStorage();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.teal,
            child: Form(
                key: _globalkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      !widget.isSignin
                          ? "Sign up with email"
                          : "Sign in with email",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    usernameTextField(),
                    !widget.isSignin ? emailTextField() : Container(),
                    passwordTextField(),
                    SizedBox(
                      height: 20,
                    ),
                    !widget.isSignin
                        ? ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                circular = true;
                              });
                              await checkUser();
                              if (_globalkey.currentState!.validate() &&
                                  validate) {
                                Map<String, String> data = {
                                  "username": _usernameController.text,
                                  "password": _passwordController.text,
                                  "email": _emailController.text
                                };
                                await networkhandler.post(
                                    "/user/register/", data);
                                setState(() {
                                  circular = false;
                                });
                              } else {
                                setState(() {
                                  circular = false;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: circular
                                ? CircularProgressIndicator()
                                : Text('Sign up'),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                circular = true;
                              });
                              login();
                            },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: circular
                                ? CircularProgressIndicator()
                                : Text('Sign In'),
                          ),
                    Divider(
                      indent: 40,
                      endIndent: 40,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            widget.isSignin ? "forget password ?" : "",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            widget.isSignin
                                ? setState(() {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Signup(isSignin: false),
                                      ),
                                    );
                                  })
                                : setState(() {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Signup(isSignin: true),
                                      ),
                                    );
                                  });
                          },
                          child: Text(
                            widget.isSignin
                                ? "new user?"
                                : "Already Have an Account! Sign In?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ))));
  }

  checkUser() async {
    if (_usernameController.text.isEmpty) {
      setState(() {
        validate = false;
        errorText = "Username Can't be empty";
        circular = false;
      });
    } else {
      var response = await networkhandler
          .get("/user/checkusername/${_usernameController.text}");

      if (response["Status"]) {
        setState(() {
          circular = false;
          validate = false;
          errorText = "Username already taken";
        });
      } else {
        setState(() {
          validate = true;
        });
      }
    }
  }

  login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        validate = false;
        errorText = "Username and Password Can't be empty";
        circular = false;
      });
    } else {
      var response = await networkhandler
          .get("/user/checkusername/${_usernameController.text}");

      if (response != null && response["Status"]) {
        Map<String, String> data = {
          "username": _usernameController.text,
          "password": _passwordController.text,
        };
        var loginResponse = await networkhandler.post("/user/login/", data);
        if (loginResponse != null) {
          try {
            Map output = jsonDecode(loginResponse.body);
            if (loginResponse.statusCode == 200 ||
                loginResponse.statusCode == 201) {
              await storage.write(key: "token", value: output["token"]);
              setState(() {
                validate = true;
                circular = false;
              });
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => Homepage()),
                  (route) => false);
            } else {
              setState(() {
                validate = false;
                errorText = "Password is Incorrect";
                circular = false;
              });
            }
          } catch (e) {
            log('Error decoding login response: $e');
            log('Response body: ${loginResponse.body}');
            setState(() {
              validate = false;
              errorText = "Invalid response from server";
              circular = false;
            });
          }
        } else {
          setState(() {
            validate = false;
            errorText = "Login failed";
            circular = false;
          });
        }
      } else {
        setState(() {
          validate = false;
          errorText = "Username not found";
          circular = false;
        });
      }
    }
  }

  Widget usernameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
      child: Column(
        children: [
          Text("Username"),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              errorText: validate ? null : errorText,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
      child: Column(
        children: [
          Text("Email"),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value!.isEmpty) return "Email can't be empty";
              if (!value.contains("@")) return "Email is Invalid";
              return null;
            },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget passwordTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
      child: Column(
        children: [
          Text("Password"),
          TextFormField(
            controller: _passwordController,
            validator: (value) {
              if (value!.isEmpty) return "Password can't be empty";
              if (value.length < 8) return "Password length must have >=8";
              return null;
            },
            obscureText: vis,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(vis ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    vis = !vis;
                  });
                },
              ),
              helperText: "Password length should have >=8",
              helperStyle: TextStyle(
                fontSize: 14,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
