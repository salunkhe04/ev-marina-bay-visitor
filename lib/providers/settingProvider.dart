import 'package:flutter/material.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/services/api_service.dart';

class SettingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();

  List<MarinaBayVisitor> _visitor = [];

  MarinaBayVisitor? currentVisitor;

  List<MarinaBayVisitor> get visitors => _visitor;

  Future<void> getMarinaBayVisitor() async {
    final desgs = await _apiService.getMarinaBayVisitor();
    _visitor = desgs;
    notifyListeners();
  }

  Future<MarinaBayVisitor?> addMarinaVisitor(Map<String, dynamic> data) async {
    final dataResp = await _apiService.addMarinaBayVisitor(data);
    if (dataResp == null) {
      return dataResp;
    }

    currentVisitor = dataResp;
    notifyListeners();
    return dataResp;
  }

  Future<void> updateVisitor(String id, Map<String, dynamic> data) async {
    final resp = await _apiService.updateVisitor(id, data);
    if (resp == null) return;
    // await getMarinaBayVisitor();
    notifyListeners();
  }
}
