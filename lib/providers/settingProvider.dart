import 'package:flutter/material.dart';
import 'package:marina_bay_cell_building_visitors/model/app_update.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/model/pagination.dart';
import 'package:marina_bay_cell_building_visitors/pages/visitors/app_update_screen.dart';
import 'package:marina_bay_cell_building_visitors/services/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();

  List<MarinaBayVisitor> _visitor = [];
  AppUpdate? update;

  MarinaBayVisitor? currentVisitor;

  List<MarinaBayVisitor> get visitors => _visitor;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  PaginationModel<MarinaBayVisitor> _visit = PaginationModel<MarinaBayVisitor>(
    code: 404,
    message: '',
    page: 1,
    limit: 10,
    totalPages: 1,
    totalItems: 0,
    data: [],
  );

  Future<PaginationModel<MarinaBayVisitor>> getMarinaBayVisitor(
    String? project, [
    String query = '',
    int page = 1,
    int limit = 10,
  ]) async {
    final leads = await _apiService.getMarinaBayVisitor(
      project,
      query,
      page,
      limit,
    );
    _visit = leads;
    notifyListeners();
    return leads;
  }

  // Future<void> getMarinaBayVisitor(String? project) async {
  //   final desgs = await _apiService.getMarinaBayVisitor(project);
  //   _visitor = desgs;
  //   notifyListeners();
  // }

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
      await showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AppUpdateSheet(update: resp),
      );
    }

    notifyListeners();
    // return resp;
  }
}
