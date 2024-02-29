import 'package:flutter/material.dart';

// tutorial used: https://youtu.be/Dh-cTQJgM-Q
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // TODO: add model name for vault access (optionnal) for later
  // https://pub.dev/packages/device_info_plus
  // get name of device

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(64, 64, 64, 1),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // empty space
              const SizedBox(height: 50),

              // Title 
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  // Lock Icon
                  Icon(
                    Icons.lock, 
                    size:40,
                    color: Colors.white,
                  ),

                  SizedBox(width: 10),
              
                  // CryptedEye
                  Text(
                    "CryptedEye",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  // > Login
                  Text(
                    " > Login",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  ),       
                ],
              ),

              const SizedBox(height: 40),

              // Icon: Profile pic
              const Icon(
                Icons.account_circle_rounded,
                size:200,
                color: Colors.black,
              ),
          
              // Login Name: (has a default val, will be changeable in settings)
              const Text(
                "Login to Vault",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
                    
              const SizedBox(height: 50),   
              
              // Password prompt
              Container(
                width: 250,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "> Access Password",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              
              
              const SizedBox(height: 10),
            
              // Login button
              Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 
                          // Add switch between pages
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // TODO: fix left padding, align text to left and add right padding for arrow
                        child: const Padding(
                          padding: EdgeInsets.only(left: 0.0),
                          child: Text(
                            "Access Vault",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
          
          ]),
        ),
      ),

    );
  }
}