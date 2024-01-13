import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edit_item.dart';

class ItemDetails extends StatelessWidget {
  ItemDetails(this.itemId, {Key? key}) : super(key: key) {
    _reference =
        FirebaseFirestore.instance.collection('shopping_list').doc(itemId);
    _futureData = _reference.get();
  }

  String itemId;

  late DocumentReference _reference;

  //_reference.get()  --> returns Future<DocumentSnapshot>
  //_reference.snapshots() --> Stream<DocumentSnapshot>
  late Future<DocumentSnapshot> _futureData;
  late Map data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
        actions: [
          IconButton(
            onPressed: () {
              //add the id to the map
              data['id'] = itemId;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditItem(
                    data,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
            ),
          ),
          IconButton(
            onPressed: () {
              //Delete the item
              _reference.delete();
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _futureData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Some error occurred ${snapshot.error}'),
            );
          }

          if (snapshot.hasData) {
            //Get the data
            DocumentSnapshot documentSnapshot = snapshot.data;
            data = documentSnapshot.data() as Map;

            //display the data
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data['name']}'),
                Text('${data['quantity']}'),
                SizedBox(
                  width: 220,
                  child: Image.network('${data['image']}'),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
