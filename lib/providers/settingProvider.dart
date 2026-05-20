import 'package:flutter/material.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/services/api_service.dart';

class SettingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  MarinaBayVisitor? currentVisitor;

  Future<MarinaBayVisitor?> addMarinaVisitor(Map<String, dynamic> data) async {
    final dataResp = await _apiService.addMarinaBayVisitor(data);
    if (dataResp == null) {
      return dataResp;
    }

    currentVisitor = dataResp;
    notifyListeners();
    return dataResp;
  }
}
