-- ========================================================
-- LANGKAH 1: MEMBUAT DATABASE DEMO
-- ========================================================
CREATE DATABASE IF NOT EXISTS demo;
USE demo;

-- Hapus tabel lama jika sudah ada
DROP TABLE IF EXISTS Products;

-- ========================================================
-- LANGKAH 2: MEMBUAT TABEL Products & MEMASUKKAN DATA
-- ========================================================
CREATE TABLE Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(20) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(10, 2) NOT NULL,
    productAmount INT NOT NULL,
    productDescription TEXT,
    productStatus VARCHAR(20) DEFAULT 'Available'
);

-- Memasukkan beberapa baris data sampel
INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
VALUES
    ('P001', 'Keyboard Mechanical DareU', 650000.00, 15, 'Keyboard optik gaming', 'Available'),
    ('P002', 'Mouse Logitech G102', 399000.00, 30, 'Mouse gaming RGB 8000 DPI', 'Available'),
    ('P003', 'Monitor Dell 24 inch', 3250000.00, 10, 'Panel IPS 75Hz', 'Available'),
    ('P004', 'Headset HyperX Cloud', 1450000.00, 8, 'Headset gaming 7.1', 'OutOfStock'),
    ('P005', 'Speaker Bluetooth JBL', 890000.00, 20, 'Tahan air IPX7', 'Available');

-- ========================================================
-- LANGKAH 3: LATIHAN DENGAN INDEX
-- ========================================================

-- 1. Evaluasi kueri SEBELUM membuat index (Full table scan, type = ALL)
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';
EXPLAIN SELECT * FROM Products WHERE productName = 'Mouse Logitech G102' AND productPrice = 399000.00;

-- 2. Buat Unique Index pada kolom productCode
CREATE UNIQUE INDEX idx_productCode ON Products(productCode);

-- 3. Buat Composite Index pada kolom productName dan productPrice
CREATE INDEX idx_name_price ON Products(productName, productPrice);

-- 4. Evaluasi kueri SETELAH membuat index (type menjadi const / ref, rows berkurang)
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';
EXPLAIN SELECT * FROM Products WHERE productName = 'Mouse Logitech G102' AND productPrice = 399000.00;

-- ========================================================
-- LANGKAH 4: LATIHAN DENGAN VIEW
-- ========================================================

-- 1. Buat view untuk menampilkan: productCode, productName, productPrice, productStatus
CREATE OR REPLACE VIEW view_products AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

-- Menampilkan isi data dari view
SELECT * FROM view_products;

-- 2. Memperbarui view (menambahkan kolom productAmount dan memfilter produk yang 'Available')
CREATE OR REPLACE VIEW view_products AS
SELECT productCode, productName, productPrice, productAmount, productStatus
FROM Products
WHERE productStatus = 'Available';

-- Periksa kembali isi view setelah diperbarui
SELECT * FROM view_products;

-- 3. Menghapus view
DROP VIEW IF EXISTS view_products;

-- ========================================================
-- LANGKAH 5: LATIHAN DENGAN STORED PROCEDURE
-- ========================================================

DELIMITER //

-- 1. Stored Procedure untuk mengambil seluruh data produk
DROP PROCEDURE IF EXISTS sp_getAllProducts //
CREATE PROCEDURE sp_getAllProducts()
BEGIN
    SELECT * FROM Products;
END //

-- 2. Stored Procedure untuk menambahkan produk baru
DROP PROCEDURE IF EXISTS sp_addProduct //
CREATE PROCEDURE sp_addProduct(
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10, 2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    INSERT INTO Products(productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_desc, p_status);
END //

-- 3. Stored Procedure untuk memperbarui informasi produk berdasarkan ID
DROP PROCEDURE IF EXISTS sp_updateProductById //
CREATE PROCEDURE sp_updateProductById(
    IN p_id INT,
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(10, 2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Products
    SET productCode = p_code,
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_desc,
        productStatus = p_status
    WHERE Id = p_id;
END //

-- 4. Stored Procedure untuk menghapus produk berdasarkan ID
DROP PROCEDURE IF EXISTS sp_deleteProductById //
CREATE PROCEDURE sp_deleteProductById(
    IN p_id INT
)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //

DELIMITER ;

-- ========================================================
-- PENGUJIAN STORED PROCEDURE
-- ========================================================

-- Menampilkan semua produk:
CALL sp_getAllProducts();

-- Menambah produk baru:
CALL sp_addProduct('P006', 'Webcam FullHD 1080p', 750000.00, 12, 'Mic noise cancelling', 'Available');

-- Mengubah data produk ID 6 yang baru dibuat:
CALL sp_updateProductById(6, 'P006', 'Webcam 1080p Pro', 800000.00, 10, 'Resolusi 1080p 60fps', 'Available');

-- Menghapus produk ID 6:
CALL sp_deleteProductById(6);

-- Cek kembali daftar produk terakhir:
CALL sp_getAllProducts();