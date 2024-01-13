import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quatityController = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();

  /* A GlobalKey is a unique identifier that lets you access a specific widget element
  *  anywhere in your Flutter app, regardless of its location in the widget tree.
  *  Think of it as a special tag that sets a widget apart from all others,
  *  allowing you to interact with it directly from any code block.*/

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('shopping_list');

  late String imageURL = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Name'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quatityController,
                decoration: const InputDecoration(hintText: 'Quantity'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item Quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              IconButton(
                onPressed: () async {
                  /*
                  Step 1: Pick/Capture an image
                  Step 2: Upload the image to Firebase storage
                  Step 3: Get the URL of the uploaded image
                  Step 4: Store the image URL inside the corresponding document of the database
                  Step 5: Display the image on the list
                  * */

                  /*Step 1: Pick Image*/
                  //Install image_picker
                  //Import the corresponding library

                  ImagePicker imagePicker = ImagePicker();
                  XFile? file =
                      await imagePicker.pickImage(source: ImageSource.gallery);

                  print('${file?.path}');
                  if (file == null) return;

                  //Create the unique name and import dart:core
                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  /*Step 2: Upload to Firebase storage*/
                  //Install the firebase_storage
                  //Import the library

                  //Get a reference to storage root
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImage = referenceRoot
                      .child('images'); // create the directory in Firebase

                  //Create a reference for the image to stored
                  Reference referenceImageToUpload = referenceDirImage.child(
                    uniqueFileName,
                  );

                  //Handle errors/success
                  try {
                    //Store the file
                    await referenceImageToUpload.putFile(File(file!.path));
                    //Success: get the download URL
                    imageURL = await referenceImageToUpload.getDownloadURL();
                  } catch (error) {
                    //some error
                  }
                },
                icon: const Icon(
                  Icons.camera_alt,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (imageURL!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Image is empty',
                        ),
                      ),
                    );
                  }
                  if (key.currentState!.validate()) {
                    String itemName = _nameController.text;
                    String itemQuantity = _quatityController.text.toString();
                    String itemImage = imageURL;
                    // Create a Map of data to push into database
                    Map<String, String> dataToSend = {
                      'name': itemName,
                      'quantity': itemQuantity,
                      'image': itemImage,
                    };

                    // Add a new item to document by reference
                    _reference.add(dataToSend);
                    _nameController.text = '';
                    _quatityController.text = '';
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Submit",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
