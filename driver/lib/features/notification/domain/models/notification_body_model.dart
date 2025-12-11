enum NotificationType{
  message,
  order,
  general,
  // ignore: constant_identifier_names
  order_request,
  block,
  unblock,
  otp,
  // ignore: constant_identifier_names
  cash_collect,
  unassign,
  withdraw,
}

class NotificationBodyModel {
  NotificationType? notificationType;
  int? orderId;
  int? customerId;
  int? vendorId;
  String? type;
  int? conversationId;

  NotificationBodyModel({
    this.notificationType,
    this.orderId,
    this.customerId,
    this.vendorId,
    this.type,
    this.conversationId,
  });

  NotificationBodyModel.fromJson(Map<String, dynamic> json) {
    notificationType = convertToEnum(json['order_notification']);
    orderId = json['order_id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    type = json['type'];
    conversationId = json['conversation_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_notification'] = notificationType.toString();
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['type'] = type;
    data['conversation_id'] = conversationId;
    return data;
  }

  NotificationType convertToEnum(String? enumString) {
    final Map<String, NotificationType> enumMap = {
      NotificationType.general.toString(): NotificationType.general,
      NotificationType.order.toString(): NotificationType.order,
      NotificationType.order_request.toString(): NotificationType.order_request,
      NotificationType.message.toString(): NotificationType.message,
      NotificationType.block.toString(): NotificationType.block,
      NotificationType.unblock.toString(): NotificationType.unblock,
      NotificationType.otp.toString(): NotificationType.otp,
      NotificationType.cash_collect.toString(): NotificationType.cash_collect,
      NotificationType.unassign.toString(): NotificationType.unassign,
      NotificationType.withdraw.toString(): NotificationType.withdraw,
    };

    return enumMap[enumString] ?? NotificationType.general;
  }

}
