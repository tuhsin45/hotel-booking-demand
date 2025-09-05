CREATE DATABASE HotelBookingAnalysis;
GO
USE HotelBookingAnalysis;
GO

DROP TABLE IF EXISTS hotel_bookings;

CREATE TABLE hotel_bookings (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    hotel VARCHAR(50) NOT NULL,
    is_canceled BIT NOT NULL,
    lead_time INT,
    arrival_date_year INT,
    arrival_date_month VARCHAR(20),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    meal VARCHAR(10),
    country VARCHAR(10),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    is_repeated_guest BIT,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    booking_changes INT,
    deposit_type VARCHAR(50),
    agent VARCHAR(50),
    company VARCHAR(50),
    days_in_waiting_list INT,
    customer_type VARCHAR(50),
    adr DECIMAL(10,2),
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(50),
    reservation_status_date DATE
);

CREATE INDEX IX_hotel_bookings_hotel ON hotel_bookings(hotel);
CREATE INDEX IX_hotel_bookings_is_canceled ON hotel_bookings(is_canceled);
CREATE INDEX IX_hotel_bookings_arrival_date ON hotel_bookings(arrival_date_year, arrival_date_month);
CREATE INDEX IX_hotel_bookings_market_segment ON hotel_bookings(market_segment);
CREATE INDEX IX_hotel_bookings_country ON hotel_bookings(country);
CREATE INDEX IX_hotel_bookings_customer_type ON hotel_bookings(customer_type);

/*
BULK INSERT hotel_bookings
FROM 'd:\sql\hotel\hotel_bookings.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
*/

SELECT COUNT(*) as total_records FROM hotel_bookings;
SELECT TOP 10 * FROM hotel_bookings;
SELECT 
    'Total Records' as metric,
    COUNT(*) as value
UNION ALL
SELECT 
    'Records with NULL hotel',
    COUNT(*)
FROM hotel_bookings 
WHERE hotel IS NULL
UNION ALL
SELECT 
    'Records with NULL is_canceled',
    COUNT(*)
FROM hotel_bookings 
WHERE is_canceled IS NULL;
