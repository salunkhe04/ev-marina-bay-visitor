// const baseUrl = "http://192.168.1.120:8082";
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:marina_bay_cell_building_visitors/core/helper/helper.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/model/upload_file.dart';
import 'package:package_info_plus/package_info_plus.dart';

// const baseUrl = "https://api.evhomes.tech";

const baseUrl = "http://192.168.1.14:8082";

const storageUrl = "https://api2.evhomes.tech";

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  late Dio _dio1;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        sendTimeout: Duration(seconds: 60),
        receiveTimeout: Duration(seconds: 60),
      ),
    );

    _dio1 = Dio(
      BaseOptions(
        baseUrl: storageUrl,
        sendTimeout: Duration(seconds: 60),
        receiveTimeout: Duration(seconds: 60),
      ),
    );
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ResponseInterceptor());

    _dio1.interceptors.add(_AuthInterceptor());
    _dio1.interceptors.add(_ResponseInterceptor());
  }

  Future<UploadFile?> uploadFile(
    File file, [
    void Function(int, int)? onSendProgress,
  ]) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final Response response = await _dio1.post(
        '/upload/path=marinaVisitorApp',
        data: formData,
        options: Options(
          // sendTimeout: Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 15),
        ),
        onSendProgress: onSendProgress,
      );

      print(response);
      if (response.statusCode != 200) {
        // Handle non-200 status codes
        //Helper.showCustomSnackBar(response.data["message"]);
        return null;
      }

      final data = response.data;
      return UploadFile.fromMap(data);
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response != null) {
        // Backend response error message
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        // Other types of errors (network, etc.)
        errorMessage = e.message?.toString() ?? errorMessage;
      }

      // Prevent literal 'null' from showing
      if (errorMessage.trim().toLowerCase() == 'null') {
        errorMessage = 'Something went wrong';
      }
      //Helper.showCustomSnackBar(errorMessage);

      return null;
    }
  }

  Future<List<MarinaBayVisitor>> getMarinaBayVisitor() async {
    try {
      final Response response = await _dio.get('/marina-bay-visitors');
      if (response.data['code'] != 200) {
        //Helper.showCustomSnackBar(response.data['message']);
        return [];
      }
      print(response);
      final List<dynamic> dataList = response.data["data"];
      final List<MarinaBayVisitor> designations = dataList.map((data) {
        return MarinaBayVisitor.fromJson(data as Map<String, dynamic>);
      }).toList();
      return designations;
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response != null) {
        // Backend response error message
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        // Other types of errors (network, etc.)
        errorMessage = e.message?.toString() ?? errorMessage;
      }
      // Prevent literal 'null' from showing
      if (errorMessage.trim().toLowerCase() == 'null') {
        errorMessage = 'Something went wrong';
      }
      //Helper.showCustomSnackBar(errorMessage);
      return [];
    }
  }

  Future<MarinaBayVisitor?> addMarinaBayVisitor(
    Map<String, dynamic> data,
  ) async {
    try {
      final Response response = await _dio.post(
        '/add-marina-bay-visitors',
        data: data,
      );
      if (response.data['code'] != 200) {
        Helper.showCustomSnackBar(response.data['message']);
        return null;
      }

      final parsedData = MarinaBayVisitor.fromJson(response.data['data']);
      print(parsedData);
      // Helper.showCustomSnackBar(response.data['message'], Colors.green);
      return parsedData;
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.message?.toString() ?? errorMessage;
      }
      // Prevent literal 'null' from showing
      if (errorMessage.trim().toLowerCase() == 'null') {
        errorMessage = 'Something went wrong';
      }
      Helper.showCustomSnackBar(errorMessage);

      return null;
    }
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // if (!await _isConnected()) {
    //   return handler.reject(DioException(
    //       requestOptions: options,
    //       type: DioExceptionType.connectionError,
    //       error: "No internet connection",
    //       message: "No internet connection"));
    // }
    if (kIsWeb) {
      options.headers['x-platform'] = 'web';
    }

    try {
      final info = await PackageInfo.fromPlatform();
      final appVersion = info.version;
      options.headers['x-app-version'] = appVersion;

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String type = "unknown";
      String os = "unknown";

      if (Platform.isAndroid) {
        type = "mobile";
        os = "android ${androidInfo.version.release}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;

        type = "mobile";
        os = "ios ${iosInfo.systemVersion}";
      }
      options.headers['x-device-name'] = androidInfo.model;
      options.headers['x-device-type'] = type;
      options.headers['x-device-os'] = os;
    } catch (e) {
      //
    }
    try {
      // final accessToken = await storage.read(key: 'accessToken');
      // final refreshToken = await storage.read(key: 'refreshToken');
      // if (accessToken != null) {
      //   options.headers['Authorization'] = 'Bearer $accessToken';
      // }
      // if (refreshToken != null) {
      //   options.headers['x-refresh-token'] = 'Bearer $refreshToken';
      // }
    } catch (e) {
      // await storage.deleteAll();
      // await SharedPrefService.deleteUser();
    }
    handler.next(options);
  }
}

class _ResponseInterceptor extends Interceptor {
  _ResponseInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final accessToken = response.headers.value('Authorization');
    final refreshToken = response.headers.value('x-refresh-token');
    final forceLogoutHeader = response.headers.value('x-force-logout');
    try {
      // if (accessToken != null && accessToken.startsWith('Bearer ')) {
      //   final newToken = accessToken.split(" ")[1];
      //   await storage.write(key: "accessToken", value: newToken);
      // }
      // if (refreshToken != null && refreshToken.startsWith('Bearer ')) {
      //   final newToken = refreshToken.split(" ")[1];
      //   await storage.write(key: "refreshToken", value: newToken);
      // }

      // if (forceLogoutHeader != null &&
      //     forceLogoutHeader.contains('force-logout')) {
      //   await forceLogout(); // Use actual server error message
      //   return;
      // }
    } catch (e) {
      //
    }
    handler.next(response);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler handler) async {
    String errorMessage = handleDioError(e);

    // Handle network issues
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      //Helper.showCustomSnackBar("No internet connection");

      return handler.resolve(
        Response(
          requestOptions: e.requestOptions,
          data: {'message': "Offline", '_cached': true, 'code': 200},
          statusCode: 200,
          statusMessage: "No internet connection",
        ),
      );
    }

    // Check for force logout header
    final forceLogoutHeader = e.response?.headers.value('x-force-logout');
    if (forceLogoutHeader != null &&
        forceLogoutHeader.toLowerCase().contains('force-logout')) {
      // await forceLogout(errorMessage); // Use actual server error message
      return;
    }

    // Otherwise, forward error
    return handler.reject(
      DioException(
        requestOptions: e.requestOptions,
        error: errorMessage,
        response: e.response,
        type: e.type,
      ),
    );
  }
}

String handleDioError(DioException e) {
  final serverMessage = e.response?.data?['message'];
  if (serverMessage != null &&
      serverMessage is String &&
      serverMessage.isNotEmpty) {
    return serverMessage;
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return "Request timed out. Check your network.";
    case DioExceptionType.connectionError:
      return "Failed to connect. Check your internet connection.";
    case DioExceptionType.badResponse:
      return "Server error: ${e.response?.statusCode}";
    default:
      return "Unexpected error occurred: ${e.message}";
  }
}
