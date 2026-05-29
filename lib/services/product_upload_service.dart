import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_data.dart';

/// One-time migration function to upload all products to Firestore.
///
/// Each product's [ProductModel.id] is used as the Firestore document ID
/// inside the 'products' collection.
Future<void> uploadAllProducts() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('products');

    for (final product in allProducts) {
      await collection.doc(product.id).set(product.toMap());
      print('Uploaded: ${product.id} - ${product.name}');
    }

    print('Upload Complete');
  } catch (e, stackTrace) {
    print('ERROR uploading products: $e');
    print('Stack trace: $stackTrace');
  }
}
