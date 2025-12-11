class ProfileModel {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? email;
  String? identityNumber;
  String? identityType;
  List<String>? identityImageFullUrl;
  String? imageFullUrl;
  String? fcmToken;
  int? zoneId;
  int? active;
  double? avgRating;
  int? ratingCount;
  int? memberSinceDays;
  int? orderCount;
  int? todaysOrderCount;
  int? thisWeekOrderCount;
  double? cashInHands;
  int? earnings;
  String? type;
  double? balance;
  double? todaysEarning;
  double? thisWeekEarning;
  double? thisMonthEarning;
  String? createdAt;
  String? updatedAt;
  double? payableBalance;
  bool? adjustable;
  bool? overFlowWarning;
  bool? overFlowBlockWarning;
  double? withDrawableBalance;
  double? totalWithdrawn;
  bool? showPayNowButton;
  double? dmMaxMyAccount;
  bool? showWithdrawButton;
  double? pendingWithdraw;

  ProfileModel({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.email,
    this.identityNumber,
    this.identityType,
    this.identityImageFullUrl,
    this.imageFullUrl,
    this.fcmToken,
    this.zoneId,
    this.active,
    this.avgRating,
    this.memberSinceDays,
    this.orderCount,
    this.todaysOrderCount,
    this.thisWeekOrderCount,
    this.cashInHands,
    this.ratingCount,
    this.createdAt,
    this.updatedAt,
    this.earnings,
    this.type,
    this.balance,
    this.todaysEarning,
    this.thisWeekEarning,
    this.thisMonthEarning,
    this.payableBalance,
    this.adjustable,
    this.overFlowWarning,
    this.overFlowBlockWarning,
    this.withDrawableBalance,
    this.totalWithdrawn,
    this.showPayNowButton,
    this.dmMaxMyAccount,
    this.showWithdrawButton,
    this.pendingWithdraw,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    identityNumber = json['identity_number'];
    identityType = json['identity_type'];
    identityImageFullUrl = json['identity_image_full_url'].cast<String>();
    imageFullUrl = json['image_full_url'];
    fcmToken = json['fcm_token'];
    zoneId = json['zone_id'];
    active = json['active'];
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
    memberSinceDays = json['member_since_days'];
    orderCount = json['order_count'];
    todaysOrderCount = json['todays_order_count'];
    thisWeekOrderCount = json['this_week_order_count'];
    cashInHands = json['cash_in_hands']?.toDouble();
    earnings = json['earning'];
    type = json['type'];
    balance = json['balance']?.toDouble();
    todaysEarning = json['todays_earning']?.toDouble();
    thisWeekEarning = json['this_week_earning']?.toDouble();
    thisMonthEarning = json['this_month_earning']?.toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    payableBalance = json['Payable_Balance']?.toDouble();
    adjustable = json['adjust_able'];
    overFlowWarning = json['over_flow_warning'];
    overFlowBlockWarning = json['over_flow_block_warning'];
    withDrawableBalance = json['withdraw_able_balance']?.toDouble();
    totalWithdrawn = json['total_withdrawn']?.toDouble();
    showPayNowButton = json['show_pay_now_button'];
    dmMaxMyAccount = json['dm_max_cash_in_hand']?.toDouble();
    showWithdrawButton = json['show_withdraw_button'];
    pendingWithdraw = json['pending_withdraw']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['email'] = email;
    data['identity_number'] = identityNumber;
    data['identity_type'] = identityType;
    data['identity_image_full_url'] = identityImageFullUrl;
    data['image_full_url'] = imageFullUrl;
    data['fcm_token'] = fcmToken;
    data['zone_id'] = zoneId;
    data['active'] = active;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['member_since_days'] = memberSinceDays;
    data['order_count'] = orderCount;
    data['todays_order_count'] = todaysOrderCount;
    data['this_week_order_count'] = thisWeekOrderCount;
    data['cash_in_hands'] = cashInHands;
    data['earning'] = earnings;
    data['balance'] = balance;
    data['type'] = type;
    data['todays_earning'] = todaysEarning;
    data['this_week_earning'] = thisWeekEarning;
    data['this_month_earning'] = thisMonthEarning;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['Payable_Balance'] = payableBalance;
    data['adjust_able'] = adjustable;
    data['over_flow_warning'] = overFlowWarning;
    data['over_flow_block_warning'] = overFlowBlockWarning;
    data['withdraw_able_balance'] = withDrawableBalance;
    data['total_withdrawn'] = totalWithdrawn;
    data['show_pay_now_button'] = showPayNowButton;
    data['dm_max_cash_in_hand'] = dmMaxMyAccount;
    data['show_withdraw_button'] = showWithdrawButton;
    data['pending_withdraw'] = pendingWithdraw;
    return data;
  }
}

