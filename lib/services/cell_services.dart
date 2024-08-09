import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inmateschedular_pro/dashboards/dash_widgets/dash_models.dart';

class CellService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CellModel>> getCells() {
    return _db.collection('cells').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CellModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addCell(CellModel cell) async {
    await _db.collection('cells').add(cell.toJson());
  }

  Future<void> updateCell(CellModel cell) async {
    await _db.collection('cells').doc(cell.id).update(cell.toJson());
  }

  Future<void> deleteCell(String id) async {
    await _db.collection('cells').doc(id).delete();
  }
}
