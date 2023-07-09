WITH total_data AS (
 	 SELECT
	 		 ad.app_download_key AS downloads,
 	  	 ad.platform,
 		   date_trunc('day', ad.download_ts) AS download_date,
  		 si.user_id AS user_signed_up, 
    	 si.age_range,
    	 rr.user_id AS user_requested_ride,
    	 rr.ride_id AS ride_requested, 
    	 CASE WHEN rr.accept_ts IS NOT NULL THEN rr.user_id END AS user_accepted,
    	 CASE WHEN rr.accept_ts IS NOT NULL THEN rr.ride_id END AS rides_accepted,
    	 CASE WHEN rr.dropoff_ts IS NOT NULL THEN rr.user_id END AS user_completed,
    	 CASE WHEN rr.dropoff_ts IS NOT NULL THEN rr.ride_id END AS rides_completed, 
    	 CASE WHEN tr.charge_status = 'Approved' THEN rr.user_id END AS user_paid, 
    	 CASE WHEN tr.charge_status = 'Approved' THEN tr.ride_id END AS rides_paid, 
       re.ride_id AS ride_reviewed, 
  	   re.user_id AS user_reviwed
		FROM app_downloads AS ad 
		LEFT JOIN signups AS si ON ad.app_download_key = si.session_id
		LEFT JOIN ride_requests AS rr ON si.user_id = rr.user_id
		LEFT JOIN transactions AS tr ON rr.ride_id = tr.ride_id
		LEFT JOIN reviews AS re ON rr.ride_id = re.ride_id)
 SELECT 
 		0 AS funnel_step, 
    'downloands' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT downloads) AS user_count, 
    0 AS ride_count
FROM total_data
GROUP BY platform, age_range, download_date
	UNION 
 SELECT 
 		1 AS funnel_step, 
    'sign_ups' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT user_signed_up) AS user_count, 
    0 AS ride_count
FROM total_data 
GROUP BY platform, age_range, download_date
	UNION
 SELECT 
 		2 AS funnel_step, 
    'ride_requested' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT user_completed) AS user_count, 
    COUNT(DISTINCT ride_requested) AS ride_count
FROM total_data 
GROUP BY platform, age_range, download_date
	UNION
SELECT 
 		3 AS funnel_step, 
    'ride_accepted' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT user_accepted) AS user_count, 
    COUNT(DISTINCT rides_accepted) AS ride_count
FROM total_data 
GROUP BY platform, age_range, download_date
	UNION 
SELECT 
 		4 AS funnel_step, 
    'ride_completed' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT user_accepted) AS user_count, 
    COUNT(DISTINCT rides_completed) AS ride_count
FROM total_data 
GROUP BY platform, age_range, download_date
	UNION
SELECT 
 		5 AS funnel_step, 
    'ride_completed' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT user_completed) AS user_count, 
    COUNT(DISTINCT rides_completed) AS ride_count
FROM total_data 
GROUP BY platform, age_range, download_date
	UNION
SELECT 
 		6 AS funnel_step, 
    'payment' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT user_paid) AS user_count, 
    COUNT(DISTINCT rides_paid) AS ride_count
FROM total_data 
GROUP BY platform, age_range, download_date
	UNION
SELECT 
 		7 AS funnel_step, 
    'review' AS funnel_name, 
    platform, 
    age_range, 
    download_date, 
    COUNT(DISTINCT user_reviwed) AS user_count, 
    COUNT(DISTINCT ride_reviewed) AS ride_count
FROM total_data 
GROUP BY platform, age_range, download_date;