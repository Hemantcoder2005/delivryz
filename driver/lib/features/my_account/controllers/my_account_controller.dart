import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sixam_mart_delivery/api/api_checker.dart';
import 'package:sixam_mart_delivery/common/models/response_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/earning_report_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/wallet_payment_model.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/models/withdraw_request_model.dart';
import 'package:sixam_mart_delivery/features/my_account/domain/services/my_account_service_interface.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';

class MyAccountController extends GetxController implements GetxService {
  final MyAccountServiceInterface myAccountServiceInterface;
  MyAccountController({required this.myAccountServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Transactions>? _transactions;
  List<Transactions>? get transactions => _transactions;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  List<Transactions>? _walletProvidedTransactions;
  List<Transactions>? get walletProvidedTransactions => _walletProvidedTransactions;

  late DateTimeRange _selectedDateRange;

  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  String? _from;
  String? get from => _from;

  String? _to;
  String? get to => _to;

  int? _pageSize;
  int? get pageSize => _pageSize;

  List<String> _offsetList = [];

  int _offset = 1;
  int get offset => _offset;

  EarningReportModel? _earningReportModel;
  EarningReportModel? get earningReportModel => _earningReportModel;

  List<Data>? _earningList;
  List<Data>? get earningList => _earningList;

  final List<String> _earningTypes = ['all_types_earning', 'delivery_fee', 'delivery_tips'];
  List<String> get earningTypes => _earningTypes;

  String? _selectedEarningType = 'all_types_earning';
  String? get selectedEarningType => _selectedEarningType;

  final List<String> _dateTypes = ['all_time', 'custom_date_range'];
  List<String> get dateTypes => _dateTypes;

  String? _selectedDateType = 'all_time';
  String? get selectedDateType => _selectedDateType;

  bool? _downloadLoading = false;
  bool? get downloadLoading => _downloadLoading;

  List<WithdrawRequestModel>? _withdrawRequestList;
  List<WithdrawRequestModel>? get withdrawRequestList => _withdrawRequestList;

  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await myAccountServiceInterface.makeCollectCashPayment(amount, paymentGatewayName);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> getWalletPaymentList() async {
    _transactions = null;
    List<Transactions>? transactions = await myAccountServiceInterface.getWalletPaymentList();
    if(transactions != null) {
      _transactions = [];
      _transactions!.addAll(transactions);
    }
    update();
  }

  Future<void> getWalletProvidedEarningList() async {
    _walletProvidedTransactions = null;
    List<Transactions>? walletProvidedTransactions = await myAccountServiceInterface.getWalletProvidedEarningList();
    if(walletProvidedTransactions != null) {
      _walletProvidedTransactions = [];
      _walletProvidedTransactions!.addAll(walletProvidedTransactions);
    }
    update();
  }

  Future<void> makeWalletAdjustment() async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await myAccountServiceInterface.makeWalletAdjustment();
    if(responseModel.isSuccess) {
      await Get.find<ProfileController>().getProfile();
      await getWalletProvidedEarningList();
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
    }else{
      Get.back();
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
  }

  void setPaymentIndex(int index){
    _paymentIndex = index;
    update();
  }

  void changeDigitalPaymentName(String? name, {bool canUpdate = true}){
    _digitalPaymentName = name;
    if(canUpdate) {
      update();
    }
  }

  void setIndex(int index) {
    _selectedIndex = index;
    update();
  }

  void showDatePicker(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      _selectedDateRange = result;

      _from = _selectedDateRange.start.toString().split(' ')[0];
      _to = _selectedDateRange.end.toString().split(' ')[0];
      update();
      debugPrint('===$from / ===$to');
    }
  }

  Future<void> getEarningReport({required String offset, required String? type, required String? startDate, required String? endDate, bool fromFilter = false}) async {

    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _earningList = null;
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      EarningReportModel? earningReportModel = await myAccountServiceInterface.getEarningReport(offset: offset, type: type == 'all_types_earning' ? 'all' : type, startDate: startDate, endDate: endDate);
      if (earningReportModel != null) {
        if (offset == '1') {
          _earningList = [];
        }
        _earningReportModel = earningReportModel;
        _earningList!.addAll(earningReportModel.earning!.data!);
        _pageSize = earningReportModel.earning!.total;
        _isLoading = false;
        _isFiltered = fromFilter;
        update();
      }
    }else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setEarningType(String? type) {
    _selectedEarningType = type;
    update();
  }

  void setDateType(String? type) {
    _selectedDateType = type;
    update();
  }

  void resetEarningFilter({bool isUpdate = true}) {
    _selectedEarningType = 'all_types_earning';
    _selectedDateType = 'all_time';
    _from = null;
    _to = null;
    _isFiltered = false;
    if(isUpdate) {
      update();
    }
  }

  Future<void> downloadEarningInvoice({required int dmId}) async {
    _downloadLoading = true;
    update();

    final response = await myAccountServiceInterface.downloadEarningInvoice(dmId: dmId);

    if (response.statusCode == 200) {

      try {

        // Get the document directory path
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/earning_invoice_$dmId.pdf';

        // Save the PDF file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyString!.codeUnits);

        // Open the PDF file
        OpenFile.open(filePath);
      } catch (e) {
        showCustomSnackBar('file_opening_failed'.tr);
      }

    } else {
      ApiChecker.checkApi(response);
    }

    _downloadLoading = false;
    update();
  }

  Future<void> getWithdrawRequestList() async {
    List<WithdrawRequestModel>? withdrawRequestList = await myAccountServiceInterface.getWithdrawRequestList();
    if(withdrawRequestList != null) {
      _withdrawRequestList = [];
      _withdrawRequestList!.addAll(withdrawRequestList);
    }
    update();
  }

}