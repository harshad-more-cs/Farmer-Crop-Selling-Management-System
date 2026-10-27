-- Farmer Crop Selling Management System: DBMS concept demonstrations
USE FarmerCropDB;

-- A. DDL/DML and basic SELECT
SELECT * FROM Farmers;
SELECT * FROM Buyers;
SELECT * FROM Crops;
SELECT * FROM Orders;
SELECT * FROM Payments;

-- B. WHERE and ORDER BY
SELECT crop_name, quantity_kg, price_per_kg
FROM Crops
WHERE quantity_kg > 0
ORDER BY price_per_kg DESC;

-- C. Aggregate functions
SELECT COUNT(*) AS total_farmers FROM Farmers;
SELECT AVG(price_per_kg) AS average_crop_price FROM Crops;
SELECT SUM(total_amount) AS total_order_value FROM Orders;
SELECT MIN(price_per_kg) AS lowest_price, MAX(price_per_kg) AS highest_price FROM Crops;

-- D. INNER JOIN: crop listing with farmer
SELECT f.farmer_name, c.crop_name, c.quantity_kg, c.price_per_kg
FROM Farmers f
INNER JOIN Crops c ON c.farmer_id = f.farmer_id
ORDER BY f.farmer_name;

-- E. Multi-table JOIN: orders
SELECT o.order_id, b.buyer_name, c.crop_name, f.farmer_name,
       o.quantity_kg, o.total_amount
FROM Orders o
JOIN Buyers b ON b.buyer_id = o.buyer_id
JOIN Crops c ON c.crop_id = o.crop_id
JOIN Farmers f ON f.farmer_id = c.farmer_id;

-- F. LEFT JOIN: include farmers even if they have no crops
SELECT f.farmer_name, c.crop_name
FROM Farmers f
LEFT JOIN Crops c ON c.farmer_id = f.farmer_id;

-- G. RIGHT JOIN: include buyers even if they have no orders
SELECT b.buyer_name, o.order_id, o.total_amount
FROM Orders o
RIGHT JOIN Buyers b ON b.buyer_id = o.buyer_id
ORDER BY b.buyer_name;

-- H. GROUP BY and HAVING: number of listings per farmer
SELECT f.farmer_name, COUNT(c.crop_id) AS listing_count
FROM Farmers f
LEFT JOIN Crops c ON c.farmer_id = f.farmer_id
GROUP BY f.farmer_id, f.farmer_name
HAVING COUNT(c.crop_id) >= 1;

-- I. Subquery: crops priced above the average price
SELECT crop_name, price_per_kg
FROM Crops
WHERE price_per_kg > (SELECT AVG(price_per_kg) FROM Crops);

-- J. View
SELECT * FROM OrderDetails;

-- K. Stored procedure
CALL ShowAvailableCrops();

-- L. Payment report: amount paid and balance
SELECT o.order_id, b.buyer_name, o.total_amount,
       COALESCE(SUM(p.amount),0) AS amount_paid,
       o.total_amount - COALESCE(SUM(p.amount),0) AS balance_due
FROM Orders o
JOIN Buyers b ON b.buyer_id = o.buyer_id
LEFT JOIN Payments p ON p.order_id = o.order_id
GROUP BY o.order_id, b.buyer_name, o.total_amount
ORDER BY o.order_id;

-- M. Safe UPDATE example (changes sample buyer city)
-- Uncomment to run:
-- UPDATE Buyers SET city='Pune' WHERE buyer_id=2;

-- N. Trigger test: successful order should reduce onion stock by 10 kg.
-- Initial onion stock after sample order = 60 kg.
-- Run once; expected stock afterwards = 50 kg.
-- INSERT INTO Orders (buyer_id,crop_id,quantity_kg,order_date,total_amount)
-- VALUES (1,1,10,'2026-10-27',250.00);
-- SELECT crop_name,quantity_kg FROM Crops WHERE crop_id=1;

-- O. Trigger failure test: request more stock than available.
-- This should return "Insufficient crop stock for this order".
-- Do not uncomment with other statements; test separately.
-- INSERT INTO Orders (buyer_id,crop_id,quantity_kg,order_date,total_amount)
-- VALUES (1,1,9999,'2026-10-27',249975.00);
