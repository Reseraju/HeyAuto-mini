import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:newheyauto/driver/pages/drvr_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io'; // For File class


class DrvrRegistration extends StatefulWidget {
  const DrvrRegistration({
    Key? key,
  }) : super(key: key);

  @override
  _DrvrRegistrationState createState() => _DrvrRegistrationState();
}

class _DrvrRegistrationState extends State<DrvrRegistration> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  int _activeStepIndex = 0;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController autoLocation = TextEditingController();
  TextEditingController vehicleNo = TextEditingController();

  String? _pollutionCertificatePath;
  String? _drivingLicensePath;

  @override
  void initState() {
    super.initState();
  }

  // Upload Pollution Certificate to Firebase Storage
  Future<String?> uploadPollutionCertificate(File file) async {
    try {
      final fileName = 'pollution_certificate_${DateTime.now().millisecondsSinceEpoch}.pdf'; // You can change the file name if needed
      final reference = firebase_storage.FirebaseStorage.instance.ref().child('pollution_certificates/$fileName');
      await reference.putFile(file);
      final downloadUrl = await reference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading pollution certificate: $e');
      return null;
    }
  }

  // Upload Driving License to Firebase Storage
  Future<String?> uploadDrivingLicense(File file) async {
    try {
      final fileName = 'driving_license_${DateTime.now().millisecondsSinceEpoch}.pdf'; // You can change the file name if needed
      final reference = firebase_storage.FirebaseStorage.instance.ref().child('driving_licenses/$fileName');
      await reference.putFile(file);
      final downloadUrl = await reference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading driving license: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String name, File pollutionCertificate, File drivingLicense, String vehicleNo, String autoLocation) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final user = FirebaseAuth.instance.currentUser;
      final phoneNumber = user?.phoneNumber;
      final drivers = FirebaseFirestore.instance.collection('Drivers');
      await drivers.doc(user?.uid).set({
        'phone_number': phoneNumber,
      });

      if (currentUser != null) {
        final usersCollection = FirebaseFirestore.instance.collection('Drivers');
        final userDoc = usersCollection.doc(currentUser.uid);

        // Save field values in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);

        // Upload Pollution Certificate and get its download URL
        String? pollutionCertificateUrl;
        if (pollutionCertificate != null) {
          pollutionCertificateUrl = await uploadPollutionCertificate(pollutionCertificate);
        }

        // Upload Driving License and get its download URL
        String? drivingLicenseUrl;
        if (drivingLicense != null) {
          drivingLicenseUrl = await uploadDrivingLicense(drivingLicense);
        }

        await userDoc.update({
          'name': name,
          'auto_location': autoLocation,
          'vehicle_no': vehicleNo,
          'pollution_certificate_url': pollutionCertificateUrl,
          'driving_license_url': drivingLicenseUrl,
        });

        print('User profile updated successfully.');
      } else {
        print('No authenticated user found.');
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }


  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text(
            'Account Details',
            style: TextStyle(fontFamily: 'Bebas', letterSpacing: 2),
          ),
          content: Container(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Full Name',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: vehicleNo,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Vehicle No',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: autoLocation,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Auto Stand Location',
                  ),
                ),
              ],
            ),
          ),
        ),
        Step(
          state: _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 1,
          title: const Text(
            'Upload Files',
            style: TextStyle(fontFamily: 'Bebas', letterSpacing: 2),
          ),
          content: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _pollutionCertificatePath = result.files.single.path ?? 'No file selected';
                      });
                    }
                  },
                  child: const Text('Upload Pollution Certificate'),
                ),
                const SizedBox(height: 8),
                Text(_pollutionCertificatePath ?? 'No file selected'),
                if (_pollutionCertificatePath != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _pollutionCertificatePath = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _drivingLicensePath = result.files.single.path ?? 'No file selected';
                      });
                    }
                  },
                  child: const Text('Upload Driving License'),
                ),
                const SizedBox(height: 8),
                Text(_drivingLicensePath ?? 'No file selected'),
                if (_drivingLicensePath != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _drivingLicensePath = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ),
        ),
        Step(
            state: StepState.complete,
            isActive: _activeStepIndex >= 2,
            title: const Text(
              'Confirm Details',
              style: TextStyle(fontFamily: 'Bebas', letterSpacing: 2),
            ),
            content: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Name: ${name.text}'),
              ],
            ))),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registration Form',
          style: TextStyle(fontFamily: 'Bebas', letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade400,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _activeStepIndex,
        steps: stepList(),
        onStepContinue: () {
          if (_activeStepIndex < (stepList().length - 1)) {
            setState(() {
              _activeStepIndex += 1;
            });
          } else {
            print('Submitted');
          }
        },
        onStepCancel: () {
          if (_activeStepIndex == 0) {
            return;
          }

          setState(() {
            _activeStepIndex -= 1;
          });
        },
        onStepTapped: (int index) {
          setState(() {
            _activeStepIndex = index;
          });
        },
      ),
      floatingActionButton: _activeStepIndex == stepList().length - 1
          ? FloatingActionButton.extended(
              onPressed: () {
                final pollutionCertificateFile = _pollutionCertificatePath != null ? File(_pollutionCertificatePath!) : null;
                final drivingLicenseFile = _drivingLicensePath != null ? File(_drivingLicensePath!) : null;
                updateUserProfile(name.text, pollutionCertificateFile!, drivingLicenseFile!, vehicleNo.text, autoLocation.text);
              },
              label: const Text('Submit'),
              icon: const Icon(Icons.check),
              backgroundColor: Colors.green.shade400,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
