drop database carrentalservice;
create database CarRentalService;
use CarRentalService;
create table vehicles(
	 vehicle_id int auto_increment primary key ,
     license_plate varchar(50) unique,
     make varchar(20),
     model varchar(10),
     year year,
     color varchar(20),
     daily_rate float(10) ,
     status char(50),
     type_id int,
     foreign key(type_id) references vechile_types(type_id));
     
     create table vechile_types(
     type_id int primary key auto_increment,
     type_name varchar(50),
	rental_category varchar(50));

     
     create table customers
     (customer_id int primary key auto_increment,
     name varchar(20),
     driver_license_number varchar(50),
     phone varchar(50));
     
     
     create table rentals(rental_id int primary key auto_increment,
     customer_id int,
     vehicle_id int,
     rental_date date,
     return_date date,
     total_cost int,
     foreign key (customer_id) references customers(customer_id),
     foreign key (vehicle_id) references vehicles(vehicle_id));
     
     create table payments(payment_id int primary key auto_increment,
     rental_id int,
     
     foreign key (rental_id) references rentals(rental_id),
     payment_date date,
     amount int);
     

     INSERT INTO vechile_types (type_name, rental_category)
VALUES 
('SUV', 'Premium'),
('Sedan', 'Standard'),
('Hatchback', 'Economy');

INSERT INTO vehicles (license_plate, make, model, year, color, daily_rate, status, type_id)
VALUES
('MH12AB1234', 'Toyota', 'Innova', 2020, 'White', 2500.00, 'Available', 1),
('MH14CD5678', 'Hyundai', 'Creta', 2021, 'Black', 2200.00, 'Rented', 1),
('MH10EF9999', 'Honda', 'City', 2019, 'Red', 2000.00, 'Maintenance', 2),
('MH20GH4321', 'Maruti', 'Baleno', 2022, 'Blue', 1500.00, 'Available', 3),
('MH09JK7654', 'Tata', 'Safari', 2021, 'Silver', 2800.00, 'Rented', 1),
('MH15LM5678', 'Skoda', 'Slavia', 2023, 'Grey', 2300.00, 'Available', 2);


INSERT INTO customers (name, driver_license_number, phone)
VALUES
('Amit Sharma', 'DL12345', '9876543210'),
('Riya Mehta', 'DL54321', '8765432109'),
('Arjun Verma', 'DL67890', '9988776655'),
('Neha Patil', 'DL09876', '9090909090'),
('Sakshi Rinke', 'DL11223', '9797979797'),
('Karan Joshi', 'DL44556', '9898989898');


INSERT INTO rentals (customer_id, vehicle_id, rental_date, return_date, total_cost)
VALUES
(1, 2, '2025-09-20', '2025-09-25', 11000.00),   
(2, 1, '2025-09-10', '2025-09-15', 12500.00),   
(3, 4, '2025-09-01', '2025-09-05', 7500.00),
(4, 3, '2025-09-05', '2025-09-12', 14000.00),   
(5, 5, '2025-09-28', '2025-10-08', 28000.00),   
(6, 2, '2025-08-01', '2025-08-05', 9000.00),    
(1, 4, '2025-07-15', '2025-07-20', 7500.00),    
(5, 1, '2025-06-01', '2025-06-10', 25000.00),   
(2, 5, '2025-08-15', '2025-08-25', 25000.00),   
(6, 3, '2025-09-25', '2025-10-02', 16000.00);   

INSERT INTO payments (rental_id, payment_date, amount)
VALUES
(1, '2025-09-25', 11000.00),
(2, '2025-09-15', 12500.00),
(3, '2025-09-05', 7500.00),
(4, '2025-09-12', 14000.00),
(5, '2025-10-08', 28000.00),
(6, '2025-08-05', 9000.00),
(7, '2025-07-20', 7500.00),
(8, '2025-06-10', 25000.00),
(9, '2025-08-25', 25000.00),
(10, '2025-10-05', 16000.00);


select * from vehicles;
select * from payments;
select * from rentals;
select * from customers;
select * from vehicles v join vechile_types vt on v.type_id=vt.type_id;
     
-- 1.	List all vehicles currently rented out (not yet returned).
select vehicle_id,license_plate,make,model,status from vehicles
where status ="Rented";


-- Calculate the total revenue generated per vehicle model
SELECT v.model, SUM(p.amount) AS total_revenue
FROM payments p
JOIN rentals r ON p.rental_id = r.rental_id
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
GROUP BY v.model
ORDER BY total_revenue DESC;


-- Find the most frequently rented vehicle type
SELECT vt.type_name, COUNT(r.rental_id) AS total_rentals
FROM rentals r
join vehicles v on r.vehicle_id = v.vehicle_id 
join vechile_types vt on vt.type_id=v.type_id
GROUP BY vt.type_name
ORDER BY total_rentals DESC
LIMIT 1;

-- Identify customers with overdue rentals
SELECT c.name, v.make, v.model, r.return_date ,(DATEDIFF(CURDATE(), r.return_date)) AS days_late
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
WHERE r.return_date < CURDATE() 
AND v.status = 'Rented';

-- Calculate the average rental duration per vehicle type
SELECT vt.type_name,
       ROUND(AVG(DATEDIFF(r.return_date, r.rental_date)), 2) AS avg_rental_days
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
JOIN vechile_types vt ON v.type_id = vt.type_id
GROUP BY vt.type_name;

-- Find the vehicle that has been rented the most times
SELECT v.make, v.model, COUNT(r.rental_id) AS total_rentals
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_id
ORDER BY total_rentals DESC
LIMIT 1;

-- List all rentals that incurred additional charges (late fees etc.)
SELECT r.rental_id, c.name, v.model, r.return_date, CURDATE() AS today,
       (DATEDIFF(CURDATE(), r.return_date)) AS days_late
FROM rentals r
JOIN customers c ON r.customer_id = c.customer_id
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
WHERE r.return_date < CURDATE() 
AND v.status = 'Rented';

-- Identify customers who have rented more than one time
SELECT c.name, COUNT(r.rental_id) AS total_rentals
FROM customers c
JOIN rentals r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) >1;

-- Calculate the utilization rate (percentage of time rented) for each vehicle

-- Let’s assume utilization = (total rented days / total possible days since first rental) * 100

SELECT v.vehicle_id, v.make, v.model,
       ROUND(SUM(DATEDIFF(r.return_date, r.rental_date)) / 
       DATEDIFF(CURDATE(), MIN(r.rental_date)) * 100, 2) AS utilization_rate
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_id;

-- Find the most profitable customer (highest total payment amount)
SELECT c.name, SUM(p.amount) AS total_spent
FROM payments p
JOIN rentals r ON p.rental_id = r.rental_id
JOIN customers c ON r.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 3;


