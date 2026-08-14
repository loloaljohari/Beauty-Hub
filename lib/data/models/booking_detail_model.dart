class BookingDetailModel {
  final int? id;
  final String? status;
  final String? bookingDate;
  final String? startTime;
  final String? endTime;
  final String? totalPrice;
  final String? depositAmount;
  final String? remainingAmount;
  final String? notes;
  final UserModel? user;
  final List<dynamic>? bookingServices; // قم بتعديلها إذا كان لديك موديل للخدمات

  BookingDetailModel({
    required this.id,
    required this.status,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    this.notes,
    required this.user,
    required this.bookingServices,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailModel(
      id: json['id']==null ? 0 : int.parse(json['id'].toString()),
      status: json['status']==null ? '' : json['status'].toString(),
      bookingDate: json['booking_date']==null ? '' : json['booking_date'].toString(),
      startTime: json['start_time']==null ? '' : json['start_time'].toString(),
      endTime: json['end_time']==null ? '' : json['end_time'].toString(),
      totalPrice: json['total_price']==null ? '' : json['total_price'].toString(),
      depositAmount: json['deposit_amount']==null ? '' : json['deposit_amount'].toString(),
      remainingAmount: json['remaining_amount']==null ? '' : json['remaining_amount'].toString(),
      notes: json['notes']==null ? '' : json['notes'].toString(),
      user: json['user'] == null ? null : UserModel.fromJson(json['user']),
      bookingServices: json['booking_services'] ?? [],
    );
  }
}

class UserModel {
  final String fullName;
  final String phone;
  final String email;
  final String? profilePhoto;
  final String gender;
  final String birthDate;
  final String city;

  UserModel({
    required this.fullName,
    required this.phone,
    required this.email,
    this.profilePhoto,
    required this.gender,
    required this.birthDate,
    required this.city,     
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name']==null ? '' : json['full_name'].toString(),
      phone: json['phone']==null ? '' : json['phone'].toString(),
      email: json['email']==null ? '' : json['email'].toString(),
      profilePhoto: json['profile_photo']==null ? '' : json['profile_photo'].toString(),
      gender: json['gender']==null ? '' : json['gender'].toString(),
      birthDate: json['birth_date']==null ? '' : json['birth_date'].toString(),
      city: json['city']==null ? '' : json['city'].toString(),
    );
  }
}
