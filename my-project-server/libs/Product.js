const mysql = require("mysql");

module.exports = {
    createProduct: async (pool, productName, imgesUrl, categoryId, price, stock) => {
        var sql = "INSERT INTO products (product_name, imgesUrl, category_id, price) "
            + "VALUES (?, ?, ?, ?)";
        sql = mysql.format(sql, [productName, imgesUrl, categoryId, price]);

        return await pool.query(sql);
    },

    getByProductId: async (pool, productId) => {
        var sql = "SELECT a.*, b.category_name FROM "
            + "products a "
            + "JOIN category b ON a.category_id = b.category_id "
            + "WHERE product_id = ?";

        sql = mysql.format(sql, [productId]);

        return await pool.query(sql);
    },

    updateProduct: async (pool, productId, productName, imgesUrl, categoryId, price) => {
        var sql = "UPDATE products SET "
            + "product_name=?,"
            + "imgesUrl=?,"
            + "category_id=?,"
            + "price=? "
            + "WHERE product_id = ?";
        sql = mysql.format(sql, [productName, imgesUrl, categoryId, price, productId]);

        return await pool.query(sql);
    },
    deleteProduct: async (pool, productId) => {
        var sql = "DELETE FROM products WHERE product_id = ?";
        sql = mysql.format(sql, [productId]);

        return await pool.query(sql);
    },
    updateImage: async (pool, productId, filename) => {
        var sql = "UPDATE products SET image_url = ? "
            + "WHERE product_id = ?";
        sql = mysql.format(sql, [filename, productId]);

        return await pool.query(sql);
    },
    getSumProduct: async (pool) => {
        var sql = "SELECT a.category_id,"
            + "b.category_name,"
            + "COUNT(a.product_id) AS product_count "
            + "FROM products a "
            + "JOIN category b ON a.category_id = b.category_id "
            + "GROUP BY a.category_id, b.category_name";

        return await pool.query(sql);
    },

    getByProductDetail: async (pool, productId) => {
        var sql = `SELECT * FROM product_variants as pv 
                INNER JOIN product_size as ps on pv.size_id = ps.size_id
                INNER JOIN color as clr on pv.color_id = clr.color_id
                WHERE pv.product_id = ? 
                ORDER BY ps.size_id ASC`
        sql = mysql.format(sql, [productId]);


        return await pool.query(sql);
    },

    getByProductSize: async (pool, productId) => {
        var sql = `SELECT * FROM product_variants as pv
        INNER JOIN color as clr on pv.color_id = clr.color_id
        INNER JOIN product_size as ps on pv.size_id = ps.size_id
        where pv.product_id = ?
        GROUP BY ps.size_id`
        sql = mysql.format(sql, [productId]);


        return await pool.query(sql);
    },
    getByProductColor: async (pool, productId) => {
        var sql = `SELECT * FROM product_variants as pv
        INNER JOIN color as clr on pv.color_id = clr.color_id
        INNER JOIN product_size as ps on pv.size_id = ps.size_id
        where pv.product_id = ?
        GROUP BY clr.color_id`
        
        sql = mysql.format(sql, [productId]);
        console.log(sql);


        return await pool.query(sql);
    },
    getByProductsCategory: async (pool, categoryId) => {
        let where_id = "";

    if(categoryId > 0) {
    where_id =  "WHERE ct.category_id = ?"
 }

    var sql = `SELECT * FROM products as pd 
            JOIN category as ct on pd.category_id = ct.category_id ${where_id}`
        sql = mysql.format(sql, [categoryId]);


        return await pool.query(sql);
    },
    searchProduct: async (pool, searchProduct) => {
        var sql = `SELECT * FROM products as pd
        INNER JOIN category as ct on pd.category_id = ct.category_id
        WHERE pd.product_name LIKE "%${searchProduct}%" OR ct.category_name LIKE "%${searchProduct}%"`
        console.log(sql);
        sql = mysql.format(sql, [searchProduct]);


        return await pool.query(sql);
    },
    // สต็อกของแอดมิน
    stockProduct: async (pool) => {
        var sql = "SELECT products.product_name, " +
                  "color.color_name, " +
                  "product_size.size_name, " +
                  "product_variants.stock " +
                  "FROM product_variants " +
                  "JOIN products ON product_variants.product_id = products.product_id " +
                  "JOIN color ON product_variants.color_id = color.color_id " +
                  "JOIN product_size ON product_variants.size_id = product_size.size_id";
        console.log(sql);
      
        return await pool.query(sql);
      },

// เพิ่ม ลบ แก้ไขสต็อกของเจ้าของร้าน

createVariant: async (productId, sizeId, colorId, stock) => {
    var sql = "INSERT INTO product_variants (product_id, size_id, color_id, stock) "
        + "VALUES (?, ?, ?, ?)";
    sql = mysql.format(sql, [productId, sizeId, colorId, stock]);
  
    return await pool.query(sql);
  },
  
getByVariantId: async (pool, variantId) => {
    var sql = "SELECT a.*, b.product_name, c.size_name, d.color_name FROM "
        + "product_variants a "
        + "JOIN products b ON a.product_id = b.product_id "
        + "JOIN product_size c ON a.size_id = c.size_id "
        + "JOIN color d ON a.color_id = d.color_id "
        + "WHERE a.variant_id = ?";
  
    sql = mysql.format(sql, [variantId]);
  
    return await pool.query(sql);
},

  
updateVariant: async (pool, variantId, product_id, size_id, color_id, stock) => {
    var sql = "UPDATE product_variants SET "
        + "product_id=?,"
        + "size_id=?,"
        + "color_id=?,"
        + "stock=? "
        + "WHERE variant_id = ?";
    sql = mysql.format(sql,[product_id, size_id, color_id, stock, variantId]);
  
    return await pool.query(sql);
},
  
deleteVariant: async (pool, variantId) => {
    var sql = "DELETE FROM product_variants WHERE variant_id = ?";
    sql = mysql.format(sql, [variantId]);
  
    return await pool.query(sql);
},
}