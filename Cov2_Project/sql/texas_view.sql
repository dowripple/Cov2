-- SELECT * FROM texas_moving_average
-- SELECT COUNT(*) FROM confirmed_cases

 DROP VIEW IF EXISTS texas_moving_average;
 
 
  CREATE VIEW texas_moving_average
      AS
    WITH county_detail
	  AS
	   (
		  SELECT cc.county_fips,
		   		 cty.state_fips,
				 cc.test_date,
				 RANK() OVER(PARTITION BY cc.county_fips ORDER BY cc.test_date) AS date_rank,
				 cc.confirmed_cases
			FROM confirmed_cases cc INNER JOIN county cty
		      ON cc.county_fips = cty.county_fips INNER JOIN states s
		      ON cty.state_fips = s.state_fips
		   WHERE s.state_id = 'TX'
	   ),
	     DailyDetail
      AS
	   (
		  SELECT cd1.county_fips,
				 c.county_name,
				 CONCAT(c.county_name,' (',s.state_id,')') AS county_desc,
		   	     RANK() OVER( PARTITION BY cd1.county_fips ORDER BY cd1.test_date) AS daily_rank,
				 c.latitude,
				 c.longitude,
				 s.state_id,
				 cp.population,
				 cd1.test_date,
				 cd1.confirmed_cases,
				 cd.covid_deaths,
				 cd2.test_date AS previous_date,
				 cd2.confirmed_cases AS previous_confirmed_cases,
				 (cd1.confirmed_cases - cd2.confirmed_cases) AS daily_change,
				 CASE WHEN cd2.confirmed_cases <> 0 
					THEN (cd1.confirmed_cases - cd2.confirmed_cases)/(cd2.confirmed_cases*1.0)
					ELSE NULL
				 END AS daily_change_percent
			FROM county_detail cd1 INNER JOIN county_detail cd2
			  ON cd1.county_fips = cd2.county_fips
			 AND cd1.date_rank = cd2.date_rank + 1 INNER JOIN county c
			  ON cd1.county_fips = c.county_fips INNER JOIN states s
			  ON c.state_fips = s.state_fips LEFT OUTER JOIN county_population cp
			  ON cd1.county_fips = cp.county_fips LEFT OUTER JOIN county_deaths cd
			  ON cd1.county_fips = cd.county_fips
			 AND cd1.test_date = cd.test_date
		   WHERE c.county_name NOT LIKE '%Unallocated/Probable%'
        ),
		 AvgData
	  AS
	   (
		  SELECT dd1.county_fips,
				 dd1.county_name,
				 dd1.county_desc,
				 dd1.daily_rank,
				 dd1.latitude,
				 dd1.longitude,
				 dd1.state_id,
				 dd1.population,
				 dd1.test_date,
				 dd1.confirmed_cases,
		         dd1.daily_change,
				 dd1.covid_deaths,
				 COUNT(*) AS observations,
				 MIN(dd2.test_date) AS avg_start_date,
				 MAX(dd2.test_date) AS avg_end_date,
				 AVG(dd2.daily_change) AS avg_daily_change,
		         SUM(dd2.daily_change) AS sum_daily_change,
				 AVG(dd2.daily_change_percent) AS avg_daily_change_percent
			FROM DailyDetail dd1 INNER JOIN DailyDetail dd2
			  ON dd1.county_fips = dd2.county_fips	  
		   WHERE dd2.daily_rank <= dd1.daily_rank
			 AND dd2.daily_rank > (dd1.daily_rank - 4)
		GROUP BY dd1.county_fips,
				 dd1.county_name,
				 dd1.county_desc,
				 dd1.daily_rank,
				 dd1.latitude,
				 dd1.longitude,
				 dd1.state_id,
				 dd1.population,
				 dd1.test_date,
				 dd1.confirmed_cases,
		         dd1.daily_change,		   
				 dd1.covid_deaths
	   )
  SELECT *,
  		 sum_daily_change / 4 AS rolling_sum_avg
    FROM AvgData 
   WHERE test_date < '2020-06-10'	


	 
