import 'package:firebase_login/domain/location/datasource/location_datasource.dart';

class LocationRepository {
  final LocationDataSource _locationDataSource;

  LocationRepository(this._locationDataSource);


  Future<List<dynamic>> getAlllocationsOnCallFunction(){
    return _locationDataSource.getAllLocationsOnCallFunction();
  }
}
