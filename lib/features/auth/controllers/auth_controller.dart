import 'dart:async';
import 'package:efood_kitchen/data/api/api_checker.dart';
import 'package:efood_kitchen/common/models/error_response.dart';
import 'package:efood_kitchen/features/auth/domain/models/profile_model.dart';
import 'package:efood_kitchen/features/auth/domain/reposotories/auth_repo.dart';
import 'package:efood_kitchen/helper/custom_snackbar_helper.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo}) ;


  late XFile _pickedFile;
  XFile get pickedFile => _pickedFile;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;
  User _profileModel = User();
  User get profileModel => _profileModel;


  Future<Response> login(String email, String password) async {
    _isLoading = true;
    update();
    Response response;
    try {
      response = await authRepo.login(email, password);
      if (response.statusCode == 200) {
        try {
          // Ensure token is saved and headers are updated before fetching profile
          await authRepo.saveUserToken(response.body['token']);
        } catch (_) {}
        // Now fetch profile (await so subsequent logic runs after profile is loaded)
        await getProfile();
      } else {
        // response.body may be a String when there's a network error or a statusText
        try {
          ErrorResponse errorResponse = ErrorResponse.fromJson(response.body);
          showCustomSnackBarHelper(errorResponse.errors![0].message!);
        } catch (_) {
          // Fallback to statusText or a generic message
          showCustomSnackBarHelper(response.statusText ?? 'Something went wrong');
        }
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      // Defensive catch-all: ensure UI doesn't get stuck loading
      showCustomSnackBarHelper(e.toString());
      response = Response(statusCode: 0, statusText: e.toString());
    } finally {
      _isLoading = false;
      update();
    }
    return response;
  }

  Future<Response> getProfile() async {
    _isLoading = true;
    update();
    Response response = await authRepo.profile();
    if (response.statusCode == 200) {
      _profileModel =  User.fromJson(response.body);
      await authRepo.updateToken(_profileModel.branch!.id.toString());
      saveBranchId(_profileModel.profile!.branchId.toString());
    }
    _isLoading = false;
    update();
    return response;
  }



  Future<void> updateToken(String branchId) async {
    await authRepo.updateToken(branchId);
  }

  void saveBranchId(String branchId) {
    authRepo.saveBranchId(branchId);
  }

  String getBranchId() {
    return authRepo.getBranchId();
  }



  void toggleRememberMe(bool? value) {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authRepo.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password) {
    authRepo.saveUserNumberAndPassword(number, password);
  }



  Future<bool> clearUserNumberAndPassword() async {
    return authRepo.clearUserNumberAndPassword();
  }


  String getUserToken() {
    return authRepo.getUserToken();
  }

  String getUserNumber() {
    return authRepo.getUserNumber();
  }



  String getUserPassword() {
    return authRepo.getUserPassword();
  }

}