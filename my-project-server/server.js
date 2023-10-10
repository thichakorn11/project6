const SECRET_KEY = "MySecretKey";

const express = require("express");
var mysql = require("mysql");
var md5 = require('md5');
//เรียกใช้ jsonwebtoken

const jwt = require('jsonwebtoken');


//สร้าง server
const app = express();
const multer = require("multer");
const bodyParser = require("body-parser");
const util = require('util');
const User = require("./libs/User");
// const Workout = require("./libs/Workout");
const Product = require("./libs/Product");
const Category = require("./libs/Category");
const Cart = require("./libs/Cart");
const Order = require("./libs/Order");
const { error } = require("console");
const port = 3000;
const user = {}


app.use(bodyParser.urlencoded({ extends: false }));
app.use(bodyParser.json());

var pool = mysql.createPool({  //สร้างเพื่อเชื่อมไปยังฐานข้อมูล
    connectionLimit: 10,
    host: "localhost",
    user: "root",
    password: "1234",
    database: "shop"
});


pool.query = util.promisify(pool.query);


//เรียกใช้ express

app.post("/api/access_request", async (req, res) => {
    const authenSignature = req.body.auth_signature;
    console.log(authenSignature);

    const authToken = req.body.auth_token;
    console.log(authToken);

    var decoded = jwt.verify(authToken, SECRET_KEY);

    console.log(decoded);

    if (decoded) {
        let result = await User.checkPassword(pool, authenSignature);

        console.log(result);


        if (result.length > 0) {
            var data = result[0];

            var payload = {
                user_id: data.user_id, user_name: data.user_name, name: data.name,
                email: data.email,
                role_id: data.role_id, role_name: data.role_name
            };

            const accessToken = jwt.sign(payload, SECRET_KEY);

            res.json({
                result: true,
                access_token: accessToken,
                data: payload
            });
            user.id = data.user_id

        } else {
            res.json({
                result: false,
                message: "Username หรือ Password ไม่ถูกต้อง"
            });
        }
    } else {
        res.json({
            result: false,
            message: "Usernsme  หรือ Password ไม่ถูกต้อง"
        });

    }
});


app.post("/api/authen_request", (req, res) => {
    const user_name = req.body.user_name;
    //console.log("222222");
    const sql = "SELECT * FROM users WHERE MD5(user_name) = ? ";
    pool.query(sql, [user_name], (error, result) => {
        
        console.log("-------------")
        console.log(result)
        console.log("-------------")
        //ถ้าเกิด error จะส่งข้อมูลรายละเอียดข้อผิดพลาดไปยัง client
        if (error) {
            res.json({
                result: false,
                message: error.message
            })
        } else {
            // ตรวจสอบค่า มีข้อมูล username ที่ส่งมาในฐานข้อมูลหรือไม่
            // ตรวจสอบโดยนับจำนวนแถวของข้อมูลที่ได้รับจากรากฐานข้อมูล
            // ถ้า results.length (จำนวนแถว) เป็น 0 แปลว่าไม่พบข้อมูลในฐษนข้อมูล
            if (result.length > 0) {

                //สร้างตัวแปร payload เพื่อเก็บข้อมูลที่จะทำให้ authenToken
                var payload = { user_name: user_name };

                //สร้าง authenToken โดยใช้ function ของ jwt 
                const authToken = jwt.sign(payload, SECRET_KEY);
              

                //ส่ง authenToken กลับไปยัง client 
                res.json({
                    result: true,
                    auth_token: authToken
                });


            } else {
                res.json({
                    result: false,
                    message: "ไม่พบข้อมูลผู้ใช้"
                });

            }
        }
    });


});

app.listen(port, () => {

});


let checkAuth = (req, res, next) => {
    let token = null;

    if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
        token = req.headers.authorization.split(' ')[1];
    } else if (req.query && req.query.token) {
        token = req.query.token;
    } else {
        token = req.body.token;
    }

    if (token) {
        jwt.verify(token, "MySecretKey", (err, decoded) => {
            if (err) {
                console.log(err);
                res.send(JSON.stringify({
                    result: false,
                    message: "ไม่ได้เข้าสู่ระบบ"
                }));
            } else {
                req.decoded = decoded;
                next();
            }
        });
    } else {
        res.status(401).send("Not authorized");
    }
}

app.post('/api/logout', checkAuth, (req, res) => {
    // Assuming the token is stored in a cookie, you can expire it.
    res.cookie('jwt', '', { expires: new Date(0) });

    // Optionally, you can also add the token to a blacklist here.
    // tokenBlacklist.add(req.user._id);

    res.json({ message: 'Logout successful' });
  });


app.get("/api/products/type/:categoryId", checkAuth, async (req, res) => {
    const categoryId = req.params.categoryId;
    const sql = "SELECT a.*, b.category_name "
        + "FROM products a "
        + "JOIN category b ON a.category_id = b.category_id";

    if (categoryId == 0) {
        pool.query(sql, (error, result) => {
            console.log(result);
            if (error) {
                res.json({
                    result: false,
                    message: error.message
                });
            } else {
                res.json({
                    result: true,
                    data: result
                });
            }
        });
    } else {
        pool.query(sql + "WHERE a.category_id = ? ",
            [categoryId], (error, result) => {
                console.log(result);
                if (error) {
                    res.json({
                        result: false,
                        message: error.message
                    });
                } else {
                    res.json({
                        result: true,
                        data: result
                    });
                }
            });
    }
});


app.get("/api/category", checkAuth, (req, res) => {
    const query = "SELECT * FROM category";

    pool.query(query, (error, result) => {
        // console.log(result);
        if (error) {
            res.json({
                result: false,
                message: error.message
            })
        } else {
            res.json({
                result: true,
                data: result
            });
        }
    });
});

app.post("/api/products/add", checkAuth, async (req, res) => {
    const input = req.body;  //นำค่าที่ผู้ใช้ป้อนทุกตัวมาเก็บไว้ใน input

    try {
        var result = await Product.createProduct(pool,
            input.product_name, input.imgesUrl, input.category_id,
            input.price);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.get("/api/products/:productId", async (req, res) => {
    const productId = req.params.productId;
  
    console.log(result);
    try {
        var result = await Product.getByProductId(pool, productId);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

// รายละเอียดการสั่งซื้อ แสดงสีและไซส์
app.get("/api/product_variants/:productId", async (req, res) => {
    const productId = req.params.productId;
    console.log("-----------");
    console.log(result);

    try {
        var result = await Product.getByProductDetail(pool, productId);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});
//แสดงรายการสินค้า สี ไซต์
app.get("/api/product_variants/size/:productId", async (req, res) => {
    const productId = req.params.productId;
    console.log("id",user.id)
    console.log("----------");
   

    try {
        var result = await Product.getByProductSize(pool, productId);
        console.log(result);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.get("/api/product_variants/color/:productId", async (req, res) => {
    const productId = req.params.productId;
    console.log("-----------");
   

    try {
        var result = await Product.getByProductColor(pool, productId);
        console.log(result);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});
app.get("/api/products/category/:categoryId", async (req, res) => {
    const categoryId = req.params.categoryId;
    console.log("-----------");
   

    try {
        var result = await Product.getByProductsCategory(pool, categoryId);
        console.log(result);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});
//ค้นหาสินค้า
app.get("/api/products/search/:productSearch", async (req, res) => {
    const productSearch = req.params.productSearch;
    console.log("-----------");
    console.log(productSearch);

    try {
        var result = await Product.searchProduct(pool, productSearch);
        console.log(result);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});
// เพิ่ม ลบ สินค้า
app.post("/api/products/update", checkAuth, async (req, res) => {
    const input = req.body;
    console.log(result);
    try {
        var result = await Product.updateProduct(pool,
            input.product_id,
            input.product_name,
            input.imgesUrl,
            input.category_id,
            input.price);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.post("/api/products/delete", checkAuth, async (req, res) => {
    const input = req.body;

    try {
        var result = await Product.deleteProduct(pool, input.product_id);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

//สมัครสมาชิก
app.get("/api/users/type/:roleId", checkAuth, async (req, res) => {
    const roleId = req.params.roleId;
    const sql = "SELECT a.*, b.role_name "
        + "FROM users a "
        + "JOIN roles b ON a.role_id = b.role_id";

    if (roleId == 0) {
        pool.query(sql, (error, result) => {
            console.log(result);
            if (error) {
                res.json({
                    result: false,
                    message: error.message
                });
            } else {
                res.json({
                    result: true,
                    data: result
                });
            }
        });
    } else {
        pool.query(sql + "WHERE a.role_id = ? ",
            [roleId], (error, result) => {
                console.log(result);
                if (error) {
                    res.json({
                        result: false,
                        message: error.message
                    });
                } else {
                    res.json({
                        result: true,
                        data: result
                    });
                }
            });
    }
});

app.get("/api/roles", checkAuth, (req, res) => {
    const query = "SELECT * FROM roles";

    pool.query(query, (error, result) => {
        // console.log(result);
        if (error) {
            res.json({
                result: false,
                message: error.message
            })
        } else {
            res.json({
                result: true,
                data: result
            });
        }
    });
});

app.post("/api/users/add", async (req, res) => {
    const input = req.body;

    console.log(input);
    try {
        var result = await User.createUser(pool,
            input.name, input.email, input.address,
            input.tel, 
            input.user_name, input.password);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});


app.get("/api/users/:userId", async (req, res) => {
    const userId = req.params.userId;
    console.log(result);
    try {
       var result = await User.getByUserId(pool, userId);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.post("/api/users/update", checkAuth, async (req, res) => {
    const input = req.body;
    console.log(input);
    try {
        var result = await User.updateUser(pool,
            input.user_id,
            input.name,
            input.email,
            input.tel,
            input.address,
            input.user_name,
            input.password,
            input.role_id,
            );

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message

        });
        console.log(ex.message)
    }
});
app.post("/api/users/delete", checkAuth, async (req, res) => {
    const input = req.body;
    console.log(result);

    try {
        var result = await User.deleteUser(pool, input.user_id);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

//category
app.get("/api/category",checkAuth,  (req, res) => {
    const query = "SELECT * FROM category";

    pool.query(query, (error, result) => {
        // console.log(result);
        if (error) {
            res.json({
                result: false,
                message: error.message
            })
        } else {
            res.json({
                result: true,
                data: result
            });
        }
    });
});

app.post("/api/category/add", checkAuth, async (req, res) => {
    const input = req.body;

    try {
        var result = await Category.createCategory(pool,
            input.category_name, 
            input.imageUrl);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});


app.get("/api/category/:categoryId", checkAuth, async (req, res) => {
    const categoryId = req.params.categoryId;
    console.log(result);
    try {
        var result = await Category.getByCategoryId(pool, categoryId);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.post("/api/category/update", checkAuth, async (req, res) => {
    const input = req.body;
    console.log(input);
    console.log("-------");
    try {
        var result = await Category.updateCategory(pool,
            input.category_id,
            input.category_name,
            input.imageUrl);

        res.json({
            result: true
        });
    } catch (ex) {
        console.log(ex.message);
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.post("/api/category/delete", checkAuth, async (req, res) => {
    const input = req.body;

    try {
        var result = await Category.deleteCategory(pool, input.category_id);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

// การสร้าง chart
app.get("/api/report", checkAuth, async (req, res) => {
    try {
      var result = await Product.getSumProduct(pool);
  
      res.json({
        result: true,
        data: result
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }

  });
   //report order
   app.get("/api/report_order", checkAuth, async (req, res) => {
    try {
      var result = await Order.orderReport(pool)
  
      res.json({
        result: true,
        data: result
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }

  });


  //Cart

  app.get("/api/cart/:userId", async (req, res) => {
    const userId = req.params.userId;
    try {
        var result = await Cart.getCartbyUserId(pool, userId);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.post("/api/cart/add",  async (req, res) => {
    const input = req.body;
    console.log(input);

    try {
        var result = await Cart.createCart(pool,
            input.user_id, input.product_id, input.color_id, input.size_id, input.amount );

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});
app.post("/api/cart/delete", checkAuth, async (req, res) => {
    const input = req.body;
    console.log(input)


    try {
        var result = await Cart.deleteCart(pool, input.cart_id);

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.post("/api/cart/updateAmount", checkAuth, async (req, res) => {
    const input = req.body;
    console.log(input);
    console.log("-------");
    try {
        var result = await Cart.updateCartAmount(pool,
            input.cart_id,
            +input.amount);

        res.json({
            result: true
        });
    } catch (ex) {
        console.log(ex);
        res.json({
            result: false,
            message: ex.message
        });
    }
});

//order
app.get("/api/order/:userId", async (req, res) => {
    const userId = req.params.userId;
    console.log(result);
    console.log(user.id);
    try {
        var result = await Order.getOrderbyUserId(pool, userId);

        res.json({
            result: true,
            data: result
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});

app.post("/api/order/add",  async (req, res) => {
    const input = req.body;
    console.log(input);

    try {
        var result = await Order.createOrder(pool,
            
            input.user_id, input.product_id, input.color_id, input.size_id, 1, input.amount, input.total , 4, 1 );

        res.json({
            result: true
        });
    } catch (ex) {
        res.json({
            result: false,
            message: ex.message
        });
    }
});
  
// ข้อมูลลูกค้า

app.get("/api/customer", checkAuth, async (req, res) => {
    console.log(result);
    try {
      var result = await User.getByCustomer(pool, 3); // ส่งค่า RoleId 3
      res.json({
        result: true,
        data: result
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }
  });

// ข้อมูลแอดมิน

app.get("/api/user/role/:roleId", checkAuth, async (req, res) => {
    const roleId = req.params.roleId;
  
    // แก้ไขคำสั่ง SQL ใน WHERE clause ให้ใช้ "role1" แทนค่า null
    const sql = "SELECT a.*, b.role_name "
    + "FROM users a "
    + "JOIN roles b ON a.role_id = b.role_id " 
    + "WHERE a.role_id = ? OR a.role_id = 1";
  
    pool.query(sql, [roleId], (error, result) => {
      if (error) {
        res.json({
          result: false,
          message: error.message
        });
      } else {
        res.json({
          result: true,
          data: result
        });
      }
    });
  });
  
  
  app.get("/api/roles", checkAuth, (req, res) => {
    const query = "SELECT * FROM roles";
  
    pool.query(query, (error, result) => {
      if (error) {
        res.json({
          result: false,
          message: error.message
        });
      } else {
        res.json({
          result: true,
          data: result
        });
      }
    });
  });
  
  app.post("/api/user/add", async (req, res) => {
    const input = req.body;
  
    try {
      var result = await User.createAdmin(pool,
        input.name, input.email, input.address,
        input.tel,
        input.user_name, input.password);
  
      res.json({
        result: true
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }
  });
  
  app.get("/api/user/:userId", async (req, res) => {
    const userId = req.params.userId;
  
    try {
      var result = await User.getByUserId(pool, userId);
  
      res.json({
        result: true,
        data: result
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }
  });
  
  app.post("/api/user/update", checkAuth, async (req, res) => {
    const input = req.body;
  
    try {
      var result = await User.updateAdmin(pool,
        input.user_id,
        input.name,
        input.email,
        input.tel,
        input.address,
        input.user_name,
        input.password,
        input.role_id);
  
      res.json({
        result: true
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }
  });
  
  app.post("/api/user/delete", checkAuth, async (req, res) => {
    const input = req.body;
  
    try {
      var result = await User.deleteAdmin(pool, input.user_id);
  
      res.json({
        result: true
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }
  });
  
  app.get("/api/admin", checkAuth, async (req, res) => {
    try {
      var result = await User.getByAdminId(pool, 1); // ส่งค่า RoleId 1
      res.json({
        result: true,
        data: result
      });
    } catch (ex) {
      res.json({
        result: false,
        message: ex.message
      });
    }
  });

  //สต็อกของแอดมิน

  app.get("/api/stock", checkAuth, async (req, res) => {
    try {
      var result = await Product.stockProduct(pool);
      console.log(result); 
      res.json({
        result: true,
        data: result,
      });
    } catch (ex) {
      console.error(ex); // ใช้ console.error สำหรับการแสดงข้อผิดพลาด
      res.json({
        result: false,
        message: ex.message,
      });
    }
  });

// สต็อกของเจ้าของ

  
  