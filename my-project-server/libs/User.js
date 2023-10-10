const mysql = require("mysql");

module.exports = {
    checkPassword: async (pool, authenSignature) => {
        let sql = "SELECT a.user_id, a.user_name, a.name,"
                    +"a.email, a.role_id, b.role_name "
                    +"FROM users a JOIN roles b ON a.role_id = b.role_id "
                    +"WHERE MD5(CONCAT(user_name, '&', password)) = ?";

        sql = mysql.format(sql, [authenSignature]);

        return await pool.query(sql);
    },

    // สมัครสมาชิก
    createUser: async (pool, nameUser, roleId, email, address, tel, userName, password) => {
      var sql = "INSERT INTO users (name, role_id, email, address, tel, user_name, password) "
                  + "VALUES (?, 3, ?, ?, ?, ?, ?)";

          sql = mysql.format(sql, [nameUser, roleId, email, address, tel, userName, password]);

          return await pool.query(sql);
  },

  getByUserId: async (pool, UserId) => {
      var sql = "SELECT u.*, r.role_name FROM "
                  + "Users u "
                  + "JOIN roles r ON u.role_id = r.role_id "
                  + "WHERE u.User_id = ?";
  
      sql = mysql.format(sql, [UserId]);
      
      return await pool.query(sql);
  },

//  ข้อมูลลูกค้า
  getByCustomer: async (pool, RoleId) => {
    var sql = "SELECT a.*, b.role_name "
                + "FROM users a "
                + "JOIN roles b ON a.role_id = b.role_id "
                + "WHERE a.role_id = ?";
  
    sql = mysql.format(sql, [RoleId]);
  
    return await pool.query(sql);
  },

  // แก้ไขโปรไฟล์ลูกค้า
  updateUser: async (pool, userId, name, email, tel,address, userName, password,roleId) => {
    var sql = "UPDATE users SET "
        + "name=?,"
        + "email=?,"
        + "tel=?,"
        + "address=?,"
        + "user_name=?,"
        + "password=?,"
        + "role_id=?"
        + "WHERE user_id = ?";
    sql = mysql.format(sql,[name, email, tel,address, userName, password ,roleId,userId]);

    return await pool.query(sql);
},

//  ข้อมูลของแอดมิน

createAdmin: async (pool, name, email, address, tel, userName, password, roleId) => {
    var sql = "INSERT INTO users (name, email, address, tel, user_name, password, role_id) "
        + "VALUES (?, ?, ?, ?, ?, ?, 1)";
    sql = mysql.format(sql, [name, email, address, tel, userName, password, roleId]);
  
    return await pool.query(sql);
  },
  
  getByAdminId: async (pool, roleId) => {
    var sql = "SELECT a.*, b.role_name FROM "
        + "users a "
        + "JOIN roles b ON a.role_id = b.role_id "
        + "WHERE a.role_id = ?";
  
    sql = mysql.format(sql, [roleId]);
  
    return await pool.query(sql);
  },
  
  updateAdmin: async (pool, userId, name, email, tel, address, userName, password, roleId) => {
    var sql = "UPDATE users SET "
        + "name=?,"
        + "email=?,"
        + "tel=?,"
        + "address=?,"
        + "user_name=?,"
        + "password=?,"
        + "role_id=? "
        + "WHERE user_id = ?";
    sql = mysql.format(sql,[name, email, tel, address, userName, password ,roleId, userId]);
  
    return await pool.query(sql);
  },
  
  deleteAdmin: async (pool, userId) => {
    var sql = "DELETE FROM users WHERE user_id = ?";
    sql = mysql.format(sql, [userId]);
  
    return await pool.query(sql);
  },
}  