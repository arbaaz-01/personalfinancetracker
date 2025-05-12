class UserProfileModel {
  final String? id;
  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phoneNumber;
  final String? currency;
  
  UserProfileModel({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    this.currency = '₹',
  });
}
