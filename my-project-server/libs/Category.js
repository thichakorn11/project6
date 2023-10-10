const mysql = require("mysql");

module.exports ={
    createCategory: async (pool, categoryName, imageUrl) => {
        var sql = "INSERT INTO category (category_name, imageUrl) "
                + "VALUES (?, ?) ";
        sql = mysql.format(sql, [categoryName, imageUrl]);

        return await pool.query(sql);
    },
    getAllCategory: async (pool) => {
        var sql = "SELECT * FROM "
                    + "category a "
    
        return await pool.query(sql);
    },

    getByCategoryId: async (pool, categoryId) => {
    var sql = "SELECT * FROM "
                + "category a "
                + "WHERE category_id = ?";

    sql = mysql.format(sql, [categoryId]);
    
    return await pool.query(sql);
},

updateCategory: async (pool, categoryId, categoryName, imageUrl ) => {
    var sql = `UPDATE category SET category_name = ?,  imageUrl = ? WHERE category_id = ?`;
    sql = mysql.format(sql, [categoryName, imageUrl, categoryId ]);

    return await pool.query(sql);
},
deleteCategory: async (pool, categoryId) => {
    var sql = "DELETE FROM category WHERE category_id = ?";
    sql = mysql.format(sql, [categoryId]);

    return await pool.query(sql);
}


}