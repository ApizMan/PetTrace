import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism/editProfile.dart';
import 'package:tourism/mapPage.dart';
import 'package:url_launcher/url_launcher.dart';

class TourPlacePage extends StatefulWidget {
  @override
  _TourPlacePageState createState() => _TourPlacePageState();
}

class _TourPlacePageState extends State<TourPlacePage> {
  final DatabaseReference _placesRef =
      FirebaseDatabase.instance.reference().child('place');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? selectedImage;

  List<Map<dynamic, dynamic>> placesList = [];
  late User _user;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _user = FirebaseAuth.instance.currentUser!;
  }

  void _loadPlaces() {
    _placesRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          placesList = data.entries.map((entry) {
            final Map<dynamic, dynamic> placeData = entry.value;
            placeData['key'] = entry.key;
            return placeData;
          }).toList();
        });
      }
    });
  }

  Future<void> _addPlace() async {
    final imagePicker = ImagePicker();
    final XFile? imageFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users').child(_user.uid);

    // Use once() to get a single value from the database
    DatabaseEvent userSnapshot = await userRef.once();

    // The value property of DatabaseEvent contains the actual data
    Map<dynamic, dynamic> userData =
        userSnapshot.snapshot.value as Map<dynamic, dynamic>;

    String fullName = userData['fullName'];

    if (imageFile != null) {
      final data = await _showInputDialog(File(imageFile.path));
      if (data != null && data['name'] != null && data['name'].isNotEmpty) {
        final storageRef =
            _storage.ref().child('place/${DateTime.now().toString()}');
        await storageRef.putFile(File(imageFile.path));
        final imageUrl = await storageRef.getDownloadURL();

        final newPlace = {
          'uid': _user.uid,
          'fullName': fullName,
          'name': data['name'],
          'address': data['address'] ?? '',
          'image': imageUrl,
        };

        // Update state after adding a new place
        setState(() {
          placesList.add(newPlace);
        });

        // This line generates a new key and sets the new place in Firebase
        _placesRef.push().set(newPlace);
      }
    }
  }

  _launchGoogleMaps(String location) async {
    final url = 'https://www.google.com/maps?q=$location';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

// for popup form
  Future<Map<String, dynamic>?> _showInputDialog(File selectedImage) async {
    String? placeName;
    String? address;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add a New Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.file(
                      selectedImage,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final imagePicker = ImagePicker();
                        final XFile? imageFile = await imagePicker.pickImage(
                            source: ImageSource.gallery);

                        if (imageFile != null) {
                          setState(() {
                            selectedImage = File(imageFile.path);
                          });
                        }
                      },
                      child: const Text('Select Image'),
                    ),
                    TextField(
                      onChanged: (value) => placeName = value,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      onChanged: (value) => address = value,
                      decoration: const InputDecoration(labelText: 'Posting'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': placeName,
                      'address': address,
                    });
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to show the edit dialog
  Future<void> _showEditDialog(Map<dynamic, dynamic> place, String? placeKey,
      String? initialImageUrl) async {
    String? updatedImageUrl = place['image'];
    String? updatedName = place['name'];
    String? updatedAddress = place['address'];

    // Initialize _newImage to null by default

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDialog(
          initialName: updatedName,
          initialAddress: updatedAddress,
          initialImageUrl: initialImageUrl, // Pass the current image URL
          onEdit: (name, address, newImage) async {
            // Check if placeKey is not null
            if (placeKey != null) {
              // Update the data in Firebase here
              try {
                String? imageUrl =
                    updatedImageUrl; // Use the initial image URL by default

                if (newImage != null) {
                  // Upload the new image to Firebase Storage
                  final storageRef = _storage
                      .ref()
                      .child('place/${DateTime.now().toString()}');
                  await storageRef.putFile(newImage);

                  // Get the updated image URL
                  imageUrl = await storageRef.getDownloadURL();
                }

                final updatedData = {
                  'name': name,
                  'address': address,
                  'image': imageUrl,
                };
                await _placesRef.child(placeKey).update(updatedData);
              } catch (e) {
                print('Error updating place data: $e');
                // Handle the error, e.g., show an error message to the user
              }
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _deletePlace(String? placeKey) async {
    if (placeKey != null) {
      try {
        await _placesRef.child(placeKey).remove();
      } catch (e) {
        print('Error deleting place data: $e');
        // Handle the error, e.g., show an error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disables the default back button
        title: Row(
          children: [
            Image.asset(
              'asset/logo.jpg', // Replace with the path to your logo asset
              height: 30, // Adjust the height as needed
            ),
            const SizedBox(
                width: 8), // Add some spacing between the logo and the title
            const Text('Pet'),
          ],
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              'asset/kitten-with-tracker.jpeg',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add your button click logic here
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MapScreen()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange, // Background color of the button
                  onPrimary: Colors.white, // Text color of the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Border radius of the button
                  ),
                  elevation: 5.0, // Elevation of the button
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0), // Padding of the button
                ),
                child: const Text('Trace Your Pet Now!'), // Text on the button
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Image.asset(
              'asset/kitten-img.jpeg',
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       const Text(
          //         'Posting Page', // Your title here
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       TextButton(
          //         onPressed: () {
          //           // Navigate to the "Location Pet" page
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => MapScreen(),
          //             ),
          //           );
          //         },
          //         child: const Text(
          //           'Location Pet',
          //           style: TextStyle(
          //             color: Colors.blue, // Change color as needed
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: placesList.length,
          //     itemBuilder: (context, index) {
          //       final place = placesList[index];
          //       return Card(
          //         elevation: 3,
          //         margin: const EdgeInsets.all(10),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Container(
          //               height: 200,
          //               width: double.infinity,
          //               child: Image.network(
          //                 place['image'],
          //                 fit: BoxFit.cover,
          //               ),
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.all(10),
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     place['fullName'] ?? "",
          //                     style: const TextStyle(
          //                       fontSize: 20,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //                   ),
          //                   const SizedBox(height: 18),
          //                   Text(
          //                     place['name'],
          //                     style: const TextStyle(
          //                       fontSize: 18,
          //                     ),
          //                   ),
          //                   const SizedBox(height: 18),
          //                   Text(
          //                     place['address'],
          //                     style: const TextStyle(fontSize: 18),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             Row(
          //               children: [
          //                 // Edit and Delete buttons on the right
          //                 Row(
          //                   children: [
          //                     IconButton(
          //                       onPressed: () {
          //                         _showEditDialog(
          //                             place, place['key'], place['image']);
          //                       },
          //                       icon: const Icon(Icons.edit),
          //                       color: Colors.green,
          //                     ),
          //                     IconButton(
          //                       onPressed: () {
          //                         _deletePlace(place['key']);
          //                         // Handle delete button press
          //                       },
          //                       icon: const Icon(Icons.delete),
          //                       color: Colors.red,
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Edit Dialog
class EditDialog extends StatefulWidget {
  final String? initialName;
  final String? initialAddress;
  final String? initialImageUrl; // Added initialImageUrl
  final Function(String?, String?, File?) onEdit; // Updated onEdit function

  EditDialog({
    required this.initialName,
    required this.initialAddress,
    required this.onEdit,
    this.initialImageUrl, // Added initialImageUrl
  });

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _newImage; // Added _newImage
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _addressController.text = widget.initialAddress ?? '';
    _imageUrl = widget
        .initialImageUrl; // Initialize _imageUrl with the initial image URL
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Post'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _newImage != null
                ? Image.file(
                    _newImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _imageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
            ElevatedButton(
              onPressed: () async {
                final imagePicker = ImagePicker();
                final XFile? imageFile =
                    await imagePicker.pickImage(source: ImageSource.gallery);

                if (imageFile != null) {
                  setState(() {
                    _newImage = File(imageFile.path);
                  });
                }
              },
              child: const Text('Select Image'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Posting'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            final updatedName = _nameController.text;
            final updatedAddress = _addressController.text;
            widget.onEdit(updatedName, updatedAddress, _newImage);
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
