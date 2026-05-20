import 'dart:async';

// import 'package:ev_homes/core/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdatePlayStore extends StatefulWidget {
  const AppUpdatePlayStore({super.key});

  @override
  State<AppUpdatePlayStore> createState() => _AppUpdatePlayStoreState();
}

class _AppUpdatePlayStoreState extends State<AppUpdatePlayStore> {
  AppUpdateInfo? _updateInfo;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool _flexibleUpdateAvailable = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate()
        .then((info) {
          setState(() {
            _updateInfo = info;
          });
          if (info.updateAvailability == UpdateAvailability.updateAvailable) {
            InAppUpdate.performImmediateUpdate().catchError((e) {
              // Helper.showCustomSnackBar(e.toString());
              return AppUpdateResult.inAppUpdateFailed;
            });
          }
        })
        .catchError((e) {
          // Helper.showCustomSnackBar(e.toString());
        });
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: const Text('In App Update')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Center(child: Text('Update info: $_updateInfo')),
              ElevatedButton(
                child: Text('Check for Update'),
                onPressed: () => checkForUpdate(),
              ),
              ElevatedButton(
                child: Text('Update Now'),
                onPressed:
                    _updateInfo?.updateAvailability ==
                        UpdateAvailability.updateAvailable
                    ? () {
                        InAppUpdate.performImmediateUpdate().catchError((e) {
                          // Helper.showCustomSnackBar(e.toString());
                          return AppUpdateResult.inAppUpdateFailed;
                        });
                      }
                    : null,
              ),
              ElevatedButton(
                child: Text('Update Later'),
                onPressed:
                    _updateInfo?.updateAvailability ==
                        UpdateAvailability.updateAvailable
                    ? () {
                        InAppUpdate.startFlexibleUpdate()
                            .then((_) {
                              setState(() {
                                _flexibleUpdateAvailable = true;
                              });
                            })
                            .catchError((e) {
                              // Helper.showCustomSnackBar(e.toString());
                            });
                      }
                    : null,
              ),
              ElevatedButton(
                child: Text('Complete flexible update'),
                onPressed: !_flexibleUpdateAvailable
                    ? null
                    : () {
                        InAppUpdate.completeFlexibleUpdate()
                            .then((_) {
                              // Helper.showCustomSnackBar("Success!");
                            })
                            .catchError((e) {
                              // Helper.showCustomSnackBar(e.toString());
                            });
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
