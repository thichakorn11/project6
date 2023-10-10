class Role {
  final int roleId;
  final String roleName;

  const Role({required this.roleId, required this.roleName});

  factory Role.fromJSON(Map<String, dynamic> json) {
    return Role(roleId: json["role_id"], roleName: json["role_name"]);
  }
}
