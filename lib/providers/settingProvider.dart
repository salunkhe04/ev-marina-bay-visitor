import 'package:flutter/material.dart';
import 'package:marina_bay_cell_building_visitors/model/app_update.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/pages/visitors/app_update_screen.dart';
import 'package:marina_bay_cell_building_visitors/services/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();

  List<MarinaBayVisitor> _visitor = [];
  AppUpdate? update;

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
    await getMarinaBayVisitor();
    notifyListeners();
  }

  Future<void> getAppUpdate(BuildContext context) async {
    print("checking for update");
    final resp = await _apiService.getAppUpdate();
    update = resp;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (resp == null) return;

    String currentVersion = packageInfo.buildNumber;
    print("current Version ${currentVersion}");
    int parsedVer = int.tryParse(currentVersion) ?? 0;

    print("resp v${resp.versionNumber}");
    if (parsedVer < (resp.versionNumber ?? 0)) {
      //
      print("sfa");
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AppUpdateSheet(update: resp),
      );
    }

    notifyListeners();
    // return resp;
  }
}
