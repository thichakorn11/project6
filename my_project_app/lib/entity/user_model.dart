class User {
  final int userId;
  final String name;
  final int roleId;
  final String roleName;
  final String email;
  final String address;
  final String tel;
  final String userName;
  final String password;

  const User(
      {required this.userId,
      required this.name,
      required this.roleId,
      required this.roleName,
      required this.email,
      required this.address,
      required this.tel,
      required this.userName,
      required this.password});

  factory User.fromJSON(Map<String, dynamic> json) {
    //print(json["user_id"]);
    return User(
      userId: json["user_id"],
      name: json["name"],
      roleId: json["role_id"],
      roleName: json["role_name"],
      email: json["email"],
      address: json["address"],
      tel: json["tel"],
      userName: json["user_name"],
      password: json["password"],
    );
  }
}
