import 'package:firebase_database/firebase_database.dart';
import 'package:gcx_device_manager/models/device.dart';

class DeviceDatabaseManager {
  final _database = FirebaseDatabase.instance.ref();

  Stream<List<Device>> getDeviceStream() {
    final devicesStream = _database.child('devices').onValue;
    final results = devicesStream.map((event) {
      final deviceMap = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      final deviceList = deviceMap.entries.map((element) {
        return Device.fromJson(Map<String, dynamic>.from(element.value));
      }).toList();
      return deviceList;
    });
    return results;
  }

  Stream<Device?> getDevice(String id) {
    final deviceStream = _database.child('devices/$id').onValue;
    final result = deviceStream.map((event) {
      if (event.snapshot.value != null) {
        final deviceData = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        final device = Device.fromJson(deviceData);
        return device;
      } else {
        return null;
      }
    });
    return result;
  }

  Future<Device?> getDeviceOnce(String id) async {
    final deviceSnapshot = await _database.child('devices/$id').once();
    if (deviceSnapshot.snapshot.value != null) {
      final deviceData = Map<String, dynamic>.from(
          deviceSnapshot.snapshot.value as Map<dynamic, dynamic>);
      final device = Device.fromJson(deviceData);
      return device;
    } else {
      return null;
    }
  }

  void deleteDevice(Device device) {
    final id = device.id;
    _database.child('devices/$id').remove();
  }

  void updateDevice(Device device) {
    final id = device.id;
    _database.child('devices/$id').update(device.toJson());
  }
}
