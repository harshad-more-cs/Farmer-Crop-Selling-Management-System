-- Farmer Crop Selling Management System
-- MySQL 8.0 | Educational DBMS mini project
-- WARNING: This script DROPS and recreates FarmerCropDB. Use only for this project.

DROP DATABASE IF EXISTS FarmerCropDB;
CREATE DATABASE FarmerCropDB;
USE FarmerCropDB;

-- 1. MASTER TABLES
CREATE TABLE Farmers (
    farmer_id INT PRIMARY KEY AUTO_INCREMENT,
    farmer_name VARCHAR(100) NOT NULL,
    village VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE
);

CREATE TABLE Buyers (
    buyer_id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE
);

CREATE TABLE Crops (
    crop_id INT PRIMARY KEY AUTO_INCREMENT,
    farmer_id INT NOT NULL,
    crop_name VARCHAR(50) NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL,
    price_per_kg DECIMAL(10,2) NOT NULL,
    harvest_date DATE,
    CONSTRAINT fk_crops_farmer FOREIGN KEY (farmer_id)
        REFERENCES Farmers(farmer_id),
    CONSTRAINT chk_crop_quantity CHECK (quantity_kg >= 0),
    CONSTRAINT chk_crop_price CHECK (price_per_kg > 0)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    buyer_id INT NOT NULL,
    crop_id INT NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    order_status ENUM('Placed','Completed','Cancelled') NOT NULL DEFAULT 'Placed',
    CONSTRAINT fk_orders_buyer FOREIGN KEY (buyer_id)
        REFERENCES Buyers(buyer_id),
    CONSTRAINT fk_orders_crop FOREIGN KEY (crop_id)
        REFERENCES Crops(crop_id),
    CONSTRAINT chk_order_quantity CHECK (quantity_kg > 0),
    CONSTRAINT chk_order_total CHECK (total_amount >= 0)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('UPI','Cash','Bank Transfer','Other') NOT NULL,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
);

-- 2. SAMPLE MASTER DATA
INSERT INTO Farmers (farmer_name, village, phone) VALUES
('Ramesh Patil','Baramati','9000000001'),
('Suresh Shinde','Indapur','9000000002'),
('Vijay Jadhav','Daund','9000000003');

INSERT INTO Buyers (buyer_name, city, phone) VALUES
('Fresh Mart','Pune','9100000001'),
('Green Grocery','Baramati','9100000002'),
('City Vegetables','Mumbai','9100000003'),
('Daily Needs Store','Indapur','9100000004');

INSERT INTO Crops (farmer_id, crop_name, quantity_kg, price_per_kg, harvest_date) VALUES
(1,'Onion',100.00,25.00,'2026-10-20'),
(1,'Tomato',80.00,30.00,'2026-10-22'),
(2,'Wheat',200.00,28.00,'2026-10-18'),
(3,'Potato',150.00,22.00,'2026-10-21');

-- 3. TRIGGERS: validate stock and deduct it for each new order
DELIMITER $$
CREATE TRIGGER trg_check_stock_before_order
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE v_available DECIMAL(10,2);
    SELECT quantity_kg INTO v_available
    FROM Crops
    WHERE crop_id = NEW.crop_id
    FOR UPDATE;

    IF v_available IS NULL OR NEW.quantity_kg > v_available THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient crop stock for this order';
    END IF;
END$$

CREATE TRIGGER trg_reduce_stock_after_order
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    UPDATE Crops
    SET quantity_kg = quantity_kg - NEW.quantity_kg
    WHERE crop_id = NEW.crop_id;
END$$
DELIMITER ;

-- 4. VIEW: order information in one place
CREATE VIEW OrderDetails AS
SELECT o.order_id, b.buyer_name, c.crop_name, f.farmer_name,
       o.quantity_kg, c.price_per_kg, o.total_amount,
       o.order_date, o.order_status
FROM Orders o
JOIN Buyers b ON b.buyer_id = o.buyer_id
JOIN Crops c ON c.crop_id = o.crop_id
JOIN Farmers f ON f.farmer_id = c.farmer_id;

-- 5. STORED PROCEDURE
DELIMITER $$
CREATE PROCEDURE ShowAvailableCrops()
BEGIN
    SELECT crop_id, crop_name, quantity_kg, price_per_kg
    FROM Crops
    WHERE quantity_kg > 0
    ORDER BY crop_name;
END$$
DELIMITER ;

-- 6. SAMPLE ORDERS (triggers will deduct stock)
INSERT INTO Orders (buyer_id,crop_id,quantity_kg,order_date,total_amount) VALUES
(1,1,40.00,'2026-10-27',1000.00),
(2,2,20.00,'2026-10-27',600.00),
(3,3,50.00,'2026-10-27',1400.00);

-- 7. SAMPLE PAYMENTS: order 2 is partially paid
INSERT INTO Payments (order_id,amount,payment_date,payment_method) VALUES
(1,1000.00,'2026-10-27','UPI'),
(2,300.00,'2026-10-27','Cash'),
(3,1400.00,'2026-10-27','UPI');

-- 8. QUICK VERIFICATION
SELECT * FROM Farmers;
SELECT * FROM Buyers;
SELECT crop_id,crop_name,quantity_kg,price_per_kg FROM Crops ORDER BY crop_id;
SELECT * FROM OrderDetails ORDER BY order_id;
CALL ShowAvailableCrops();
