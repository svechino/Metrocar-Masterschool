WITH downloads AS (
  	SELECT 
  			app_download_key
  	FROM app_downloads
  	GROUP BY app_download_key
), 
sign_ups AS (
  	SELECT 
  		user_id
  	FROM signups
), 
user_ride_status AS (
    SELECT
        user_id, 
  		  CASE WHEN dropoff_ts IS NOT NULL THEN user_id END AS completed_ride
    FROM ride_requests
),
payments AS (
  	SELECT 
  			CASE WHEN t.transaction_id IS NOT NULL THEN rr.user_id END AS payed_rides
    FROM ride_requests AS rr
  	LEFT JOIN transactions AS t on rr.ride_id = t.ride_id
),
reviews AS (
  	SELECT
  			user_id
  	FROM reviews
),
funnel_stages AS (
    SELECT
        1 AS funnel_step,
        'downloads' AS funnel_name,
        COUNT(DISTINCT app_download_key) AS value
    FROM downloads

    UNION

    SELECT
        2 AS funnel_step,
        'signups' AS funnel_name,
        COUNT(DISTINCT user_id) AS value
    FROM sign_ups
  
  	UNION
  
  	SELECT 
  			3 AS funnel_step, 
  			'requested_ride' AS funnel_name, 
  			COUNT(DISTINCT user_id) AS value
  	FROM user_ride_status
  
  	UNION
  
  	SELECT 
  			4 AS funnel_step, 
  			'completed_ride' AS funnel_name, 
  			COUNT(DISTINCT completed_ride) AS value
  	FROM user_ride_status
  
  	UNION
  	
  	SELECT 
  			5 AS funnel_step, 
  			'payments' AS funnel_name, 
  			COUNT(DISTINCT payed_rides) AS value
  	FROM payments
  
  	UNION
  	
  	SELECT 
  			6 AS funnel_step, 
  			'reviews' AS funnel_name, 
  			COUNT(DISTINCT user_id) AS value
  	FROM reviews  	
)
SELECT *,
		LAG(value) OVER (ORDER BY funnel_step) AS previous_stage,
    ROUND(1 - value::numeric / LAG(value) OVER (
        ORDER BY funnel_step
    ), 3) AS dropoff_from_previous_stage
FROM funnel_stages
ORDER BY funnel_step;