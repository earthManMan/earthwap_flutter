import 'package:firebase_login/domain/location/repo/location_repository.dart';

class LocationService {
  final LocationRepository _locationRepository;

  Map<String, List<String>> _locations = {};

  LocationService(this._locationRepository) {
    _initializeLocations();
  }

  Map<String, List<String>> get locations => _locations;

  Future<void> _initializeLocations() async {
    if (_locations.isEmpty) {
      final result = await _locationRepository.getAlllocationsOnCallFunction();
      for (final location in result) {
        List<String> locationParts = location.toString().split(' ');

        // 시/도를 키로, 해당 시/도에 속하는 구/군들을 값으로 저장
        String province = locationParts[0];
        String district = locationParts[1];
        if (_locations.containsKey(province)) {
          _locations[province]!.add(district);
        } else {
          _locations[province] = [district];
        }
      }
    }
  }
}
