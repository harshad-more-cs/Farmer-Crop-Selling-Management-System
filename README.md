# Farmer Crop Selling Management System — DBMS Mini Project

**Database:** MySQL 8.0  
**Interface:** MySQL command-line client  
**Project focus:** Relational database design and SQL concepts  
**Sample data:** Fictional records for demonstration

## What the project does
- Stores farmers and buyers.
- Lists crops, available quantities and price per kilogram.
- Records crop orders and calculates sample order totals.
- Uses triggers to reject orders exceeding stock and deduct stock after a new order.
- Stores payments and supports balance-due reports.
- Demonstrates primary/foreign keys, constraints, joins, subqueries, aggregates, a view and a stored procedure.

## Requirements
- MySQL Server 8.0 or compatible.
- MySQL command-line client.
- A text editor for SQL files.

## Run it step by step
1. Start MySQL Server.
2. Open Terminal / Command Prompt and log in:
   ```bash
   mysql -u root -p
   ```
   Enter your MySQL password when prompted.
3. Run the setup script from the terminal. Navigate to the folder containing the project first:
   ```bash
   mysql -u root -p < sql/01_setup_and_sample_data.sql
   ```
   If you are already at the `mysql>` prompt instead, use:
   ```sql
   SOURCE /full/path/to/sql/01_setup_and_sample_data.sql;
   ```
   Replace the example path with the actual path on your laptop.
4. Open the MySQL client again if needed and run:
   ```sql
   USE FarmerCropDB;
   SOURCE /full/path/to/sql/02_queries_and_tests.sql;
   ```
5. To verify the tables:
   ```sql
   SHOW TABLES;
   SELECT * FROM Farmers;
   SELECT * FROM Crops;
   SELECT * FROM OrderDetails;
   CALL ShowAvailableCrops();
   ```

## Important reset warning
`01_setup_and_sample_data.sql` begins with `DROP DATABASE IF EXISTS FarmerCropDB;`. Running it again deletes and recreates this project's database. Use it only when you are okay losing changes in `FarmerCropDB`. Back up any work first.

## Expected sample results
After running the setup script:
- Farmers: 3 rows.
- Buyers: 4 rows.
- Crop listings: 4 rows.
- Orders: 3 rows.
- Payments: 3 rows.
- Total sample order value: ₹3,000.
- Total sample payments: ₹2,700.
- Onion stock: 60 kg (100 kg original stock minus 40 kg ordered).
- Tomato stock: 60 kg (80 kg minus 20 kg).
- Wheat stock: 150 kg (200 kg minus 50 kg).
- Potato stock: 150 kg (no order yet).
- Order 2 balance: ₹300.

## Testing the stock trigger
Run this only once after setup:
```sql
INSERT INTO Orders (buyer_id,crop_id,quantity_kg,order_date,total_amount)
VALUES (1,1,10,'2026-10-27',250.00);
SELECT crop_name, quantity_kg FROM Crops WHERE crop_id=1;
```
Expected onion stock: 50 kg.

Then test invalid stock separately:
```sql
INSERT INTO Orders (buyer_id,crop_id,quantity_kg,order_date,total_amount)
VALUES (1,1,9999,'2026-10-27',249975.00);
```
Expected: an error saying `Insufficient crop stock for this order`. No order should be added.

## Suggested screenshots for submission
1. `SHOW TABLES;`
2. `SELECT * FROM Farmers;`
3. `SELECT * FROM Crops;`
4. Multi-table JOIN query output.
5. `SELECT * FROM OrderDetails;`
6. `CALL ShowAvailableCrops();`
7. Trigger stock reduction before and after the test order.
8. Payment balance query.

## Limitations / honest scope
This is a DBMS academic project using a MySQL terminal, not a deployed commercial marketplace. Sample records are fictional. The trigger covers new orders; editing/cancelling an order would require additional inventory logic. Payment records are manually entered and are not connected to a real payment gateway.
