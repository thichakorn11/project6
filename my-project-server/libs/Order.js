const mysql = require("mysql");

module.exports = {
    createOrder: async (pool,  userID, product_id, color_id, size_id, receipt_id, amount, total, order_status, transport_type) => {
        var sql = "INSERT INTO tbl_order (user_id, product_id, color_id, size_id, receipt_id, amount, total, order_status, transport_type) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        sql = mysql.format(sql, [userID, product_id, color_id, size_id, receipt_id, amount, total, order_status, transport_type]);

        return await pool.query(sql);
    },

    getOrderbyUserId: async (pool, userId) => {
        var sql = 
        `SELECT * FROM tbl_cart as cart
        JOIN users as us on cart.user_id = us.user_id
        JOIN products as pd on cart.product_id = pd.product_id
        JOIN product_size as ps on cart.size_id = ps.size_id
        JOIN color as clr on cart.color_id = clr.color_id
        WHERE cart.user_id = ? `

        sql = mysql.format(sql, [userId]);

        return await pool.query(sql);
    },

    updateCart: async (pool, cartID, userID, variantId, amount) => {
        var sql = "UPDATE tbl_cart SET "
            + "cart_id=?,"
            + "user_id=?,"
            + "variant_id=?,"
            + "amount=?,"
            + "WHERE cart_id = ?";
        sql = mysql.format(sql, [pool, cartID, userID, variantId, amount]);

        return await pool.query(sql);
    },
    deleteCart: async (pool, cartId) => {
        var sql = "DELETE FROM tbl_cart WHERE cart_id = ?";
        sql = mysql.format(sql, [cartId]);

        return await pool.query(sql);
    },
//chart order
    orderReport: async (pool, ) => {
        var sql = 
        `SELECT *,sum(amount) as sumAmount FROM tbl_order as ord
        INNER JOIN products as pd on ord.product_id = pd.product_id 
        GROUP BY ord.product_id `

        sql = mysql.format(sql);

        return await pool.query(sql);
    },

}