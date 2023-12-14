/*import 'package:segadi/objectbox.g.dart';
import 'package:segadi/model/status.dart';

class ObjectBox {
  late final Store _store;
  late final Box<statusSupport> _statusBox;

  ObjectBox._init(this._store) {
    _statusBox = Box<statusSupport>(_store);
  }

  static Future<ObjectBox> init() async {
    final store = await openStore();
    return ObjectBox._init(store);
  }

  statusSupport? getStatus(int id) => _statusBox.get(id);
  Stream<List<statusSupport>> getStatusAll() => _statusBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());
  int insertStatus(statusSupport status) => _statusBox.put(status);
  bool deleteStatus(int id) => _statusBox.remove(id);
}
*/