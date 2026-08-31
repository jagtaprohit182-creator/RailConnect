-- RailConnect Database Schema
-- This SQL file creates all necessary tables for the railway reservation system

-- Create Database
CREATE DATABASE IF NOT EXISTS railconnect;
USE railconnect;

-- 1. USERS TABLE - Store user information
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mobile VARCHAR(15) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. ADMINS TABLE - Store admin information
CREATE TABLE IF NOT EXISTS admins (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. STATIONS TABLE - Store all railway stations
CREATE TABLE IF NOT EXISTS stations (
    station_id INT PRIMARY KEY AUTO_INCREMENT,
    station_code VARCHAR(10) UNIQUE NOT NULL,
    station_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- 4. TRAINS TABLE - Store train information
CREATE TABLE IF NOT EXISTS trains (
    train_id INT PRIMARY KEY AUTO_INCREMENT,
    train_number VARCHAR(10) UNIQUE NOT NULL,
    train_name VARCHAR(100) NOT NULL,
    from_station_id INT NOT NULL,
    to_station_id INT NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    journey_duration VARCHAR(20),
    coach_count INT DEFAULT 12,
    seats_per_coach INT DEFAULT 72,
    total_seats INT,
    available_seats INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_station_id) REFERENCES stations(station_id),
    FOREIGN KEY (to_station_id) REFERENCES stations(station_id)
);

-- 5. CLASS_PRICING TABLE - Store fare for different classes
CREATE TABLE IF NOT EXISTS class_pricing (
    pricing_id INT PRIMARY KEY AUTO_INCREMENT,
    train_id INT NOT NULL,
    class_name VARCHAR(50) NOT NULL,
    base_fare DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (train_id) REFERENCES trains(train_id)
);

-- 6. SEATS TABLE - Store seat information for each train
CREATE TABLE IF NOT EXISTS seats (
    seat_id INT PRIMARY KEY AUTO_INCREMENT,
    train_id INT NOT NULL,
    coach_number INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    class_type VARCHAR(50) NOT NULL,
    status ENUM('Available', 'Booked', 'Reserved') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (train_id) REFERENCES trains(train_id),
    UNIQUE KEY unique_seat (train_id, coach_number, seat_number)
);

-- 7. BOOKINGS TABLE - Store booking information
CREATE TABLE IF NOT EXISTS bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    pnr VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    train_id INT NOT NULL,
    journey_date DATE NOT NULL,
    class_type VARCHAR(50) NOT NULL,
    number_of_passengers INT NOT NULL,
    total_fare DECIMAL(10, 2) NOT NULL,
    base_fare DECIMAL(10, 2),
    reservation_charge DECIMAL(10, 2),
    service_charge DECIMAL(10, 2),
    gst_tax DECIMAL(10, 2),
    booking_status ENUM('Confirmed', 'Cancelled', 'Pending') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (train_id) REFERENCES trains(train_id)
);

-- 8. PASSENGERS TABLE - Store passenger details for each booking
CREATE TABLE IF NOT EXISTS passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    seat_id INT,
    coach_number INT,
    seat_number VARCHAR(10),
    passenger_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    id_proof_type VARCHAR(50) NOT NULL,
    id_proof_number VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
);

-- 9. PAYMENTS TABLE - Store payment information
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- 10. CANCELLATIONS TABLE - Store cancellation details
CREATE TABLE IF NOT EXISTS cancellations (
    cancellation_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    cancellation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    refund_amount DECIMAL(10, 2),
    refund_status VARCHAR(50),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Insert Sample Stations
INSERT INTO stations (station_code, station_name, city) VALUES
('DEL', 'New Delhi Railway Station', 'Delhi'),
('MUM', 'Mumbai Central', 'Mumbai'),
('BLR', 'Bangalore City Railway Station', 'Bangalore'),
('HYD', 'Hyderabad Deccan', 'Hyderabad'),
('KOL', 'Kolkata Central', 'Kolkata'),
('CHE', 'Chennai Central', 'Chennai');

-- Insert Sample Trains
INSERT INTO trains (train_number, train_name, from_station_id, to_station_id, departure_time, arrival_time, journey_duration, total_seats, available_seats) VALUES
('12001', 'Rajdhani Express', 1, 2, '16:00:00', '09:00:00', '17 hrs', 864, 864),
('12002', 'Shatabdi Express', 1, 3, '06:00:00', '22:30:00', '16.5 hrs', 864, 864),
('12003', 'Premier Limited', 1, 4, '18:00:00', '07:00:00', '13 hrs', 864, 864),
('12004', 'Express Special', 2, 3, '08:00:00', '20:00:00', '12 hrs', 864, 864),
('12005', 'Night Express', 1, 5, '20:00:00', '14:00:00', '18 hrs', 864, 864);

-- Insert Class Pricing for Train 12001
INSERT INTO class_pricing (train_id, class_name, base_fare) VALUES
(1, 'AC First Class', 3500.00),
(1, 'AC 2 Tier', 2800.00),
(1, 'AC 3 Tier', 2200.00),
(1, 'Sleeper', 1500.00),
(1, 'Second Sitting', 800.00);

-- Insert Class Pricing for Train 12002
INSERT INTO class_pricing (train_id, class_name, base_fare) VALUES
(2, 'AC First Class', 3200.00),
(2, 'AC 2 Tier', 2600.00),
(2, 'AC 3 Tier', 2100.00),
(2, 'Sleeper', 1400.00),
(2, 'Second Sitting', 750.00);

-- Insert Class Pricing for Train 12003
INSERT INTO class_pricing (train_id, class_name, base_fare) VALUES
(3, 'AC First Class', 3800.00),
(3, 'AC 2 Tier', 3100.00),
(3, 'AC 3 Tier', 2400.00),
(3, 'Sleeper', 1700.00),
(3, 'Second Sitting', 900.00);

-- Insert Class Pricing for Train 12004
INSERT INTO class_pricing (train_id, class_name, base_fare) VALUES
(4, 'AC First Class', 2800.00),
(4, 'AC 2 Tier', 2200.00),
(4, 'AC 3 Tier', 1800.00),
(4, 'Sleeper', 1200.00),
(4, 'Second Sitting', 650.00);

-- Insert Class Pricing for Train 12005
INSERT INTO class_pricing (train_id, class_name, base_fare) VALUES
(5, 'AC First Class', 4000.00),
(5, 'AC 2 Tier', 3200.00),
(5, 'AC 3 Tier', 2500.00),
(5, 'Sleeper', 1800.00),
(5, 'Second Sitting', 1000.00);

-- Create indexes for better query performance
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_booking_pnr ON bookings(pnr);
CREATE INDEX idx_booking_user ON bookings(user_id);
CREATE INDEX idx_seat_train ON seats(train_id);
CREATE INDEX idx_passenger_booking ON passengers(booking_id);
