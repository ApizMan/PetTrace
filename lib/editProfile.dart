import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tourism/loginpage.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('users');

  final DatabaseReference _databasepet =
      FirebaseDatabase.instance.reference().child('pet');

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  TextEditingController petNameController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load user data based on the current user's ID
    //loadUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    String uid = user!.uid;
    Map<dynamic, dynamic>? petData;

    print("User ID: $uid");

    if (uid != null) {
      DatabaseReference usersRef =
          FirebaseDatabase.instance.reference().child('users');

      DatabaseEvent snapshot = await usersRef.child(uid).once();
      dynamic snapshotData = snapshot.snapshot.value;

      print("Snapshot data: $snapshotData");

      String email = snapshotData['email'] ?? '';
      String name = snapshotData['name'] ?? '';
      String phoneNumber = snapshotData['phone'] ?? '';

      DatabaseReference petsRef =
          FirebaseDatabase.instance.reference().child('pet');

      Query petQuery = petsRef.orderByChild('uid').equalTo(uid);
      DatabaseEvent petsSnapshot = await petQuery.once();

      Map<dynamic, dynamic>? petData =
          petsSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (petData != null) {
        // If pet data exists, set the values in the controllers
        Map<dynamic, dynamic> firstPet = petData.values.first;
        String petName = firstPet['petName'] ?? '';
        String longitude = firstPet['longitude'] ?? '';
        String latitude = firstPet['latitude'] ?? '';

        petNameController.text = petName;
        longitudeController.text = longitude;
        latitudeController.text = latitude;
      } else {
        // If pet data doesn't exist, you can handle it accordingly
        print("No pet data found for user ID: $uid");
      }

      print("Retrieved Name: $name, Phone: $phoneNumber");

      // Use the TextEditingController's `text` property directly to set the initial values
      nameController.text = name;
      phoneController.text = phoneNumber;
      emailController.text = email;

      print(
          "Name in controller: ${nameController.text}, Phone in controller: ${phoneController.text}");
      print("kk");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'asset/logo.jpg', // Replace with the path to your logo asset
              height: 30, // Adjust the height as needed
            ),
            const SizedBox(
                width: 8), // Add some spacing between the logo and the title
            const Text('Edit Profile'),
          ],
        ),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'asset/logo.jpg', // Replace with the path to your image asset
                  width: 250, // Set your desired width
                  height: 250, // Set your desired height
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          // Update user data in Firebase Realtime Database
                          await _database.child(_auth.currentUser!.uid).update({
                            'email': emailController.text.trim(),
                            'name': nameController.text.trim(),
                            'phone': phoneController.text.trim(),
                          });

                          // Successfully updated profile
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Profile updated successfully'),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: const Center(
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: petNameController,
                              decoration: const InputDecoration(
                                labelText: 'Pet Name',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: longitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: latitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Check if pet data exists for the current user
                      ElevatedButton(
                        onPressed: () async {
                          // Check if pet data exists for the current user
                          if (petNameController.text.isNotEmpty) {
                            // Update pet information in the 'pets' node
                            await _databasepet
                                .child(_auth.currentUser!.uid)
                                .update({
                              'petName': petNameController.text.trim(),
                              'longitude': longitudeController.text.trim(),
                              'latitude': latitudeController.text.trim(),
                              'uid': _auth.currentUser!.uid,
                            });

                            // Successfully updated pet
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Pet updated successfully'),
                            ));
                          } else {
                            // Insert pet information into the 'pets' node
                            await _databasepet
                                .child(_auth.currentUser!.uid)
                                .set({
                              'petName': petNameController.text.trim(),
                              'longitude': longitudeController.text.trim(),
                              'latitude': latitudeController.text.trim(),
                              'uid': _auth.currentUser!.uid,
                            });

                            // Successfully added pet
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Pet added successfully'),
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Center(
                            child: Text(
                              petNameController.text.isNotEmpty
                                  ? 'Update Pet'
                                  : 'Add Pet',
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0),
                              side: const BorderSide(
                                width: 1.0,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _auth.signOut();
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
