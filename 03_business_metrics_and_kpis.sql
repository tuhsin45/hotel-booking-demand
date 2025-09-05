USE HotelBookingAnalysis;
GO

SELECT 
    'Hotel Booking KPIs' as report_section,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as total_cancellations,
    COUNT(*) - SUM(CAST(is_canceled AS INT)) as successful_bookings,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as total_revenue,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 2) as avg_lead_time_days,
    COUNT(DISTINCT country) as countries_served
FROM vw_hotel_bookings_clean;

SELECT 
    hotel,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as total_revenue,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 2) as avg_lead_time_days
FROM vw_hotel_bookings_clean
GROUP BY hotel
ORDER BY total_bookings DESC;

SELECT 
    arrival_date_year,
    arrival_month_num,
    arrival_date_month,
    season,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as monthly_revenue
FROM vw_hotel_bookings_clean
GROUP BY arrival_date_year, arrival_month_num, arrival_date_month, season
ORDER BY arrival_date_year, arrival_month_num;

SELECT 
    season,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as seasonal_revenue
FROM vw_hotel_bookings_clean
GROUP BY season
ORDER BY total_bookings DESC;

SELECT 
    lead_time_category,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 2) as avg_lead_time_days,
    ROUND(AVG(adr), 2) as avg_daily_rate
FROM vw_hotel_bookings_clean
GROUP BY lead_time_category
ORDER BY 
    CASE lead_time_category
        WHEN 'Same Day' THEN 1
        WHEN '1-7 days' THEN 2
        WHEN '1-4 weeks' THEN 3
        WHEN '1-3 months' THEN 4
        WHEN '3-6 months' THEN 5
        WHEN '6+ months' THEN 6
    END;

SELECT 
    stay_duration_category,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_nights,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as total_revenue
FROM vw_hotel_bookings_clean
WHERE total_nights > 0
GROUP BY stay_duration_category
ORDER BY 
    CASE stay_duration_category
        WHEN '1 night' THEN 1
        WHEN '2-3 nights' THEN 2
        WHEN '4-7 nights' THEN 3
        WHEN '1-2 weeks' THEN 4
        WHEN '2+ weeks' THEN 5
    END;

SELECT 
    customer_type,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as total_revenue
FROM vw_hotel_bookings_clean
GROUP BY customer_type
ORDER BY total_bookings DESC;

SELECT 
    market_segment,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as total_revenue
FROM vw_hotel_bookings_clean
GROUP BY market_segment
ORDER BY total_bookings DESC;

SELECT 
    distribution_channel,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as total_revenue
FROM vw_hotel_bookings_clean
GROUP BY distribution_channel
ORDER BY total_bookings DESC;

SELECT 
    country,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(CAST(total_nights AS FLOAT)), 2) as avg_length_of_stay,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(total_nights * adr), 2) as total_revenue
FROM vw_hotel_bookings_clean
WHERE country IS NOT NULL AND country != 'NULL'
GROUP BY country
HAVING COUNT(*) >= 100
ORDER BY total_bookings DESC;

SELECT 
    arrival_date_year,
    hotel,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(SUM(total_nights * adr), 2) as total_revenue,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(SUM(CASE WHEN is_canceled = 0 THEN total_nights * adr ELSE 0 END), 2) as realized_revenue
FROM vw_hotel_bookings_clean
GROUP BY arrival_date_year, hotel
ORDER BY arrival_date_year, hotel;

SELECT 
    guest_segment,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct,
    ROUND(AVG(adr), 2) as avg_daily_rate,
    ROUND(AVG(CAST(lead_time AS FLOAT)), 2) as avg_lead_time
FROM vw_hotel_bookings_clean
GROUP BY guest_segment;

SELECT 
    CASE 
        WHEN total_of_special_requests = 0 THEN '0 requests'
        WHEN total_of_special_requests = 1 THEN '1 request'
        WHEN total_of_special_requests BETWEEN 2 AND 3 THEN '2-3 requests'
        WHEN total_of_special_requests > 3 THEN '4+ requests'
    END as special_requests_category,
    COUNT(*) as total_bookings,
    SUM(CAST(is_canceled AS INT)) as cancellations,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) as cancellation_rate_pct
FROM vw_hotel_bookings_clean
GROUP BY 
    CASE 
        WHEN total_of_special_requests = 0 THEN '0 requests'
        WHEN total_of_special_requests = 1 THEN '1 request'
        WHEN total_of_special_requests BETWEEN 2 AND 3 THEN '2-3 requests'
        WHEN total_of_special_requests > 3 THEN '4+ requests'
    END
ORDER BY cancellation_rate_pct;

SELECT 
    'EXECUTIVE SUMMARY' as section,
    'Total Bookings: ' + CAST(COUNT(*) AS VARCHAR(10)) as metric1,
    'Cancellation Rate: ' + CAST(ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 1) AS VARCHAR(10)) + '%' as metric2,
    'Avg Length of Stay: ' + CAST(ROUND(AVG(CAST(total_nights AS FLOAT)), 1) AS VARCHAR(10)) + ' nights' as metric3,
    'Total Revenue: $' + CAST(ROUND(SUM(total_nights * adr), 0) AS VARCHAR(15)) as metric4,
    'Avg Daily Rate: $' + CAST(ROUND(AVG(adr), 2) AS VARCHAR(10)) as metric5
FROM vw_hotel_bookings_clean;
