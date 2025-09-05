USE HotelBookingAnalysis;
GO

SELECT 
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as total_cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as total_revenue,
    COUNT(DISTINCT country) as countries_served,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 1) as avg_lead_time_days
FROM vw_hotel_bookings_clean;

SELECT 
    arrival_date_year,
    arrival_month_num,
    arrival_date_month as month_name,
    season,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(SUM(total_nights * adr), 0) as monthly_revenue,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay
FROM vw_hotel_bookings_clean
GROUP BY arrival_date_year, arrival_month_num, arrival_date_month, season
ORDER BY arrival_date_year, arrival_month_num;

SELECT 
    hotel as hotel_type,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as total_revenue,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 1) as avg_lead_time_days
FROM vw_hotel_bookings_clean
GROUP BY hotel;

SELECT 
    lead_time_category,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 1) as avg_lead_time_days,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    CASE lead_time_category
        WHEN 'Same Day' THEN 1
        WHEN '1-7 days' THEN 2
        WHEN '1-4 weeks' THEN 3
        WHEN '1-3 months' THEN 4
        WHEN '3-6 months' THEN 5
        WHEN '6+ months' THEN 6
    END as sort_order
FROM vw_hotel_bookings_clean
GROUP BY lead_time_category
ORDER BY sort_order;

SELECT 
    market_segment,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as total_revenue,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM vw_hotel_bookings_clean), 2) as market_share_pct
FROM vw_hotel_bookings_clean
GROUP BY market_segment
ORDER BY total_bookings DESC;

SELECT 
    customer_type,
    hotel,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as total_revenue
FROM vw_hotel_bookings_clean
GROUP BY customer_type, hotel
ORDER BY customer_type, hotel;

SELECT 
    country,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as total_revenue,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM vw_hotel_bookings_clean WHERE country IS NOT NULL AND country != 'NULL'), 2) as booking_share_pct
FROM vw_hotel_bookings_clean
WHERE country IS NOT NULL AND country != 'NULL' AND country != ''
GROUP BY country
HAVING COUNT(*) >= 50
ORDER BY total_bookings DESC;

SELECT 
    season,
    hotel,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as seasonal_revenue
FROM vw_hotel_bookings_clean
GROUP BY season, hotel
ORDER BY 
    CASE season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Fall' THEN 3
        WHEN 'Winter' THEN 4
    END, hotel;

SELECT 
    stay_duration_category,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_nights,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as total_revenue,
    CASE stay_duration_category
        WHEN '1 night' THEN 1
        WHEN '2-3 nights' THEN 2
        WHEN '4-7 nights' THEN 3
        WHEN '1-2 weeks' THEN 4
        WHEN '2+ weeks' THEN 5
        ELSE 6
    END as sort_order
FROM vw_hotel_bookings_clean
WHERE total_nights > 0
GROUP BY stay_duration_category
ORDER BY sort_order;

SELECT 
    distribution_channel,
    market_segment,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as total_revenue,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 1) as avg_lead_time_days
FROM vw_hotel_bookings_clean
GROUP BY distribution_channel, market_segment
ORDER BY distribution_channel, total_bookings DESC;

SELECT 
    arrival_date_year,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 0) as annual_revenue,
    COUNT(DISTINCT country) as countries_served
FROM vw_hotel_bookings_clean
GROUP BY arrival_date_year
ORDER BY arrival_date_year;

SELECT TOP 1000
    booking_id,
    hotel,
    is_canceled,
    booking_status,
    arrival_date_year,
    arrival_date_month,
    season,
    lead_time,
    lead_time_category,
    total_nights,
    stay_duration_category,
    adults,
    children,
    babies,
    total_guests,
    country,
    market_segment,
    distribution_channel,
    customer_type,
    guest_segment,
    adr,
    total_revenue,
    meal,
    total_of_special_requests
FROM vw_hotel_bookings_clean
ORDER BY NEWID();
