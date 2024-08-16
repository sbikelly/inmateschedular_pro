import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService<T> {
  final String collectionName;
  final T Function(DocumentSnapshot<Map<String, dynamic>>) fromSnapshot;
  final Map<String, dynamic> Function(T) toJson;

  FirestoreService({
    required this.collectionName,
    required this.fromSnapshot,
    required this.toJson,
  });

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all documents in the collection
  Stream<List<T>> getAll() {
    return _db.collection(collectionName).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => fromSnapshot(doc)).toList());
  }

  // Fetch a single document by ID
  Future<T?> getById(String id) async {
    final docSnapshot = await _db.collection(collectionName).doc(id).get();
    return docSnapshot.exists ? fromSnapshot(docSnapshot) : null;
  }

  // Add a new document
  Future<void> add(T model) async {
    await _db.collection(collectionName).add(toJson(model));
  }

  // Update an existing document by ID
  Future<void> update(String id, T model) async {
    await _db.collection(collectionName).doc(id).update(toJson(model));
  }

  // Delete a document by ID
  Future<void> delete(String id) async {
    await _db.collection(collectionName).doc(id).delete();
  }
}
