import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditItem extends StatelessWidget {
  EditItem(this._shoppingItem, {Key? key}) {
    _controllerName = TextEditingController(text: _shoppingItem['name']);
    _controllerQuantity =
        TextEditingController(text: _shoppingItem['quantity']);

    _reference = FirebaseFirestore.instance
        .collection('shopping_list')
        .doc(_shoppingItem['id']);
  }
  late String imageURL;
  Map _shoppingItem;
  late DocumentReference _reference;

  late TextEditingController _controllerName;
  late TextEditingController _controllerQuantity;
  GlobalKey<FormState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit an item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _key,
          child: Column(
            children: [
              TextFormField(
                controller: _controllerName,
                decoration: const InputDecoration(
                    hintText: 'Enter the name of the item'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _controllerQuantity,
                decoration: const InputDecoration(
                    hintText: 'Enter the quantity of the item'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item quantity';
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
                  // Reference referenceRoot = FirebaseStorage.instance.ref();
                  // Reference referenceDirImage = referenceRoot
                  //     .child('images'); // create the directory in Firebase

                  //Create a reference for the image to stored
                  // Reference referenceImageToUpload = referenceDirImage.child(
                  //   uniqueFileName,
                  // );

                  Reference referenceImageToUpload = FirebaseStorage.instance.refFromURL(_shoppingItem['image']);

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

              ElevatedButton(
                onPressed: () async {
                  if (_key.currentState!.validate()) {
                    String name = _controllerName.text;
                    String quantity = _controllerQuantity.text;

                    //Create the Map of data
                    Map<String, String> dataToUpdate = {
                      'name': name,
                      'quantity': quantity,
                      'image': imageURL,
                    };

                    //Call update()
                    _reference.update(dataToUpdate);
                    _controllerName.text = '';
                    _controllerQuantity.text = '';
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}