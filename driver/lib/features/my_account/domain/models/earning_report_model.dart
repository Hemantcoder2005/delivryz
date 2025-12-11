class EarningReportModel {
  Earning? earning;
  double? totalDmTips;
  double? totalDeliveryCharge;
  String? type;
  String? limit;
  String? offset;

  EarningReportModel({
    this.earning,
    this.totalDmTips,
    this.totalDeliveryCharge,
    this.type,
    this.limit,
    this.offset,
  });

  EarningReportModel.fromJson(Map<String, dynamic> json) {
    earning = json['earning'] != null ? Earning.fromJson(json['earning']) : null;
    totalDmTips = json['total_dm_tips']?.toDouble();
    totalDeliveryCharge = json['total_delivery_charge']?.toDouble();
    type = json['type'];
    limit = json['limit'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (earning != null) {
      data['earning'] = earning!.toJson();
    }
    data['total_dm_tips'] = totalDmTips;
    data['total_delivery_charge'] = totalDeliveryCharge;
    data['type'] = type;
    data['limit'] = limit;
    data['offset'] = offset;
    return data;
  }
}

class Earning {
  List<Data>? data;
  int? total;

  Earning({this.data, this.total});

  Earning.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}

class Data {
  int? id;
  int? deliveryManId;
  double? dmTips;
  String? createAt;
  double? originalDeliveryCharge;
  double? deliveryFeeComission;
  String? moduleType;
  Order? order;

  Data({
    this.id,
    this.deliveryManId,
    this.dmTips,
    this.createAt,
    this.originalDeliveryCharge,
    this.deliveryFeeComission,
    this.moduleType,
    this.order,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deliveryManId = json['delivery_man_id'];
    dmTips = json['dm_tips']?.toDouble();
    createAt = json['created_at'];
    originalDeliveryCharge = json['original_delivery_charge']?.toDouble();
    deliveryFeeComission = json['delivery_fee_comission']?.toDouble();
    moduleType = json['module_type'];
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['delivery_man_id'] = deliveryManId;
    data['dm_tips'] = dmTips;
    data['created_at'] = createAt;
    data['original_delivery_charge'] = originalDeliveryCharge;
    data['delivery_fee_comission'] = deliveryFeeComission;
    data['module_type'] = moduleType;
    if (order != null) {
      data['order'] = order!.toJson();
    }
    return data;
  }
}

class Order {
  int? id;
  String? paymentMethod;

  Order({this.id, this.paymentMethod});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentMethod = json['payment_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['payment_method'] = paymentMethod;
    return data;
  }
}
