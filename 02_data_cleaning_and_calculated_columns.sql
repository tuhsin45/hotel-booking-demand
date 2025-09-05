USE HotelBookingAnalysis;
GO

ALTER TABLE hotel_bookings 
ADD total_nights AS (stays_in_weekend_nights + stays_in_week_nights);

ALTER TABLE hotel_bookings 
ADD total_guests AS (adults + children + babies);

CREATE OR ALTER VIEW vw_hotel_bookings_enhanced AS
SELECT 
    *,
    total_nights,
    total_guests,
    
    CASE 
        WHEN arrival_date_month = 'January' THEN 1
        WHEN arrival_date_month = 'February' THEN 2
        WHEN arrival_date_month = 'March' THEN 3
        WHEN arrival_date_month = 'April' THEN 4
        WHEN arrival_date_month = 'May' THEN 5
        WHEN arrival_date_month = 'June' THEN 6
        WHEN arrival_date_month = 'July' THEN 7
        WHEN arrival_date_month = 'August' THEN 8
        WHEN arrival_date_month = 'September' THEN 9
        WHEN arrival_date_month = 'October' THEN 10
        WHEN arrival_date_month = 'November' THEN 11
        WHEN arrival_date_month = 'December' THEN 12
    END as arrival_month_num,
    
    CASE 
        WHEN arrival_date_month IN ('December', 'January', 'February') THEN 'Winter'
        WHEN arrival_date_month IN ('March', 'April', 'May') THEN 'Spring'
        WHEN arrival_date_month IN ('June', 'July', 'August') THEN 'Summer'
        WHEN arrival_date_month IN ('September', 'October', 'November') THEN 'Fall'
    END as season,
    
    CASE 
        WHEN lead_time = 0 THEN 'Same Day'
        WHEN lead_time BETWEEN 1 AND 7 THEN '1-7 days'
        WHEN lead_time BETWEEN 8 AND 30 THEN '1-4 weeks'
        WHEN lead_time BETWEEN 31 AND 90 THEN '1-3 months'
        WHEN lead_time BETWEEN 91 AND 180 THEN '3-6 months'
        WHEN lead_time > 180 THEN '6+ months'
    END as lead_time_category,
    
    CASE 
        WHEN (stays_in_weekend_nights + stays_in_week_nights) = 0 THEN 'No Stay'
        WHEN (stays_in_weekend_nights + stays_in_week_nights) = 1 THEN '1 night'
        WHEN (stays_in_weekend_nights + stays_in_week_nights) BETWEEN 2 AND 3 THEN '2-3 nights'
        WHEN (stays_in_weekend_nights + stays_in_week_nights) BETWEEN 4 AND 7 THEN '4-7 nights'
        WHEN (stays_in_weekend_nights + stays_in_week_nights) BETWEEN 8 AND 14 THEN '1-2 weeks'
        WHEN (stays_in_weekend_nights + stays_in_week_nights) > 14 THEN '2+ weeks'
    END as stay_duration_category,
    
    (stays_in_weekend_nights + stays_in_week_nights) * adr as total_revenue,
    
    CASE 
        WHEN is_repeated_guest = 1 THEN 'Returning Guest'
        ELSE 'New Guest'
    END as guest_segment,
    
    CASE 
        WHEN is_canceled = 0 THEN 'Successful Booking'
        ELSE 'Canceled Booking'
    END as booking_status

FROM hotel_bookings;

CREATE OR ALTER VIEW vw_booking_summary_stats AS
SELECT 
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as total_cancellations,
    AVG(CAST(is_canceled AS FLOAT)) * 100 as cancellation_rate_pct,
    AVG(CAST(lead_time AS FLOAT)) as avg_lead_time,
    AVG(CAST(total_nights AS FLOAT)) as avg_stay_duration,
    AVG(adr) as avg_daily_rate,
    SUM(total_nights * adr) as total_revenue,
    COUNT(DISTINCT country) as countries_count,
    MIN(arrival_date_year) as earliest_year,
    MAX(arrival_date_year) as latest_year
FROM vw_hotel_bookings_enhanced;

UPDATE hotel_bookings 
SET children = 0 
WHERE children IS NULL;

UPDATE hotel_bookings 
SET babies = 0 
WHERE babies IS NULL;

UPDATE hotel_bookings 
SET agent = 'No Agent' 
WHERE agent IS NULL OR agent = 'NULL';

UPDATE hotel_bookings 
SET company = 'No Company' 
WHERE company IS NULL OR company = 'NULL';

SELECT 
    'Records with 0 adults' as issue,
    COUNT(*) as count
FROM hotel_bookings 
WHERE adults = 0
UNION ALL
SELECT 
    'Records with negative ADR',
    COUNT(*)
FROM hotel_bookings 
WHERE adr < 0
UNION ALL
SELECT 
    'Records with 0 total nights and not canceled',
    COUNT(*)
FROM hotel_bookings 
WHERE total_nights = 0 AND is_canceled = 0;

CREATE OR ALTER VIEW vw_hotel_bookings_clean AS
SELECT *
FROM vw_hotel_bookings_enhanced
WHERE adults > 0 
  AND adr >= 0
  AND NOT (total_nights = 0 AND is_canceled = 0);

SELECT 'Original Records' as dataset, COUNT(*) as record_count
FROM hotel_bookings
UNION ALL
SELECT 'Clean Records', COUNT(*)
FROM vw_hotel_bookings_clean;
