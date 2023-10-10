const mysql = require("mysql");

module.exports = {
    createCart: async (pool,  userID, product_id, color_id, size_id, amount) => {
        var sql = "INSERT INTO tbl_cart (user_id, product_id, color_id, size_id, amount) "
            + "VALUES (?, ?, ?, ?, ?)";
        sql = mysql.format(sql, [userID, product_id, color_id, size_id, amount]);

        return await pool.query(sql);
    },

    getCartbyUserId: async (pool, userId) => {
        var sql = `SELECT * FROM tbl_cart as cart
        JOIN users as us on cart.user_id = us.user_id
        JOIN products as pd on cart.product_id = pd.product_id
        JOIN product_size as ps on cart.size_id = ps.size_id
        JOIN color as clr on cart.color_id = clr.color_id
        WHERE cart.user_id = ? `;

        sql = mysql.format(sql, [userId]);

        return await pool.query(sql);
    },

    updateCart: async (pool, cartID, userID,  product_id, color_id, size_id, amount) => {
        var sql = "UPDATE tbl_cart SET "
            + "cart_id=?,"
            + "user_id=?,"
            + "product_id=?,"
            + "color_id=?,"
            + "size_id=?,"
            + "amount=?,"
            + "WHERE cart_id = ?";
        sql = mysql.format(sql, [pool, cartID, userID, product_id, color_id, size_id, amount]);

        return await pool.query(sql);
    },
    deleteCart: async (pool, cartId) => {
        var sql = "DELETE FROM tbl_cart WHERE cart_id = ?";
        sql = mysql.format(sql, [cartId]);

        return await pool.query(sql);
    },

    updateCartAmount: async (pool, cartID, amount) => {
        var sql = `UPDATE tbl_cart SET amount =? WHERE cart_id =?`;
        sql = mysql.format(sql,[amount, cartID]);

        return await pool.query(sql);
    },
}