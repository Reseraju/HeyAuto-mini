import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:newheyauto/driver/drvr_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? _pollutionCertificatePath;
  String? _drivingLicensePath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateUserProfile(String name, List<String> uploadedFiles) async {
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
        await prefs.setStringList('uploadedFiles', uploadedFiles);

        await userDoc.update({
          'name': name,
          'uploaded_files': uploadedFiles,
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
                const SizedBox(
                  height: 8,
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
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _pollutionCertificatePath =
                            result.files.single.path ?? 'No file selected';
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
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setState(() {
                        _drivingLicensePath =
                            result.files.single.path ?? 'No file selected';
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
                updateUserProfile(name.text, [_pollutionCertificatePath?? '',_drivingLicensePath ?? '']);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DriverHomePage()),
                );
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
