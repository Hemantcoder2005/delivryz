import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/ai/domain/models/attribute_data_model.dart';
import 'package:sixam_mart_store/features/ai/domain/repositories/ai_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/features/ai/domain/models/other_data_model.dart';
import 'package:sixam_mart_store/features/ai/domain/models/title_des_model.dart';
import 'package:sixam_mart_store/features/ai/domain/models/title_suggestion_model.dart';
import 'package:sixam_mart_store/features/ai/domain/models/variation_data_model.dart';

class AiRepository implements AiRepositoryInterface {
  final ApiClient apiClient;
  AiRepository({required this.apiClient});

  @override
  Future<TitleDesModel?> generateTitleAndDes({required String title, required String langCode, required String storeId, required String moduleType, required String generateFrom}) async {
    TitleDesModel? titleDesModel;
    Response response = await apiClient.getData('${AppConstants.generateTitleAndDes}?name=$title&langCode=$langCode&store_id=$storeId&module_type=$moduleType&requestType=$generateFrom');
    if(response.statusCode == 200) {
      titleDesModel = TitleDesModel.fromJson(response.body);
    }
    return titleDesModel;
  }

  @override
  Future<OtherDataModel?> generateOtherData({required String title, required String description, required String storeId, required String moduleType, required String generateFrom, required int moduleId}) async {
    OtherDataModel? otherDataModel;
    Response response = await apiClient.getData('${AppConstants.generateOtherData}?name=$title&description=$description&store_id=$storeId&module_type=$moduleType&requestType=$generateFrom&module_id=$moduleId');
    if(response.statusCode == 200) {
      otherDataModel = OtherDataModel.fromJson(response.body);
    }
    return otherDataModel;
  }

  @override
  Future<VariationDataModel?> generateVariationData({required String title, required String description, required String storeId, required String moduleType, required String generateFrom}) async {
    VariationDataModel? variationDataModel;
    Response response = await apiClient.getData('${AppConstants.generateVariationData}?name=$title&description=$description&store_id=$storeId&module_type=$moduleType&requestType=$generateFrom');
    if(response.statusCode == 200) {
      variationDataModel = VariationDataModel.fromJson(response.body);
    }
    return variationDataModel;
  }

  @override
  Future<AttributeDataModel?> generateAttributeData({required String title, required String description, required String storeId, required String moduleType, required String generateFrom}) async {
    AttributeDataModel? attributeDataModel;
    Response response = await apiClient.getData('${AppConstants.generateVariationData}?name=$title&description=$description&store_id=$storeId&module_type=$moduleType&requestType=$generateFrom');
    if(response.statusCode == 200) {
      attributeDataModel = AttributeDataModel.fromJson(response.body);
    }
    return attributeDataModel;
  }

  @override
  Future<TitleSuggestionModel?> generateTitleSuggestions({required String keywords, required String storeId, required String moduleType,}) async {
    TitleSuggestionModel? titleSuggestionModel;
    Response response = await apiClient.getData('${AppConstants.generateTitleSuggestion}?keywords=$keywords&store_id=$storeId&module_type=$moduleType');
    if(response.statusCode == 200) {
      titleSuggestionModel = TitleSuggestionModel.fromJson(response.body);
    }
    return titleSuggestionModel;
  }

  @override
  Future<Response> generateFromImage({required XFile image}) async {
    Map<String, String> fields = {};
    Response response = await apiClient.postMultipartData(AppConstants.generateFromImage, fields, [MultipartBody('image', image)]);
    return response;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

}