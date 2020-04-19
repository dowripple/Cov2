
  DROP VIEW IF EXISTS staging_county_list;
  DROP VIEW IF EXISTS staging_state_list;
  DROP VIEW IF EXISTS staging_cases_list;
  DROP VIEW IF EXISTS staging_population;
  DROP VIEW IF EXISTS staging_deaths;
  DROP VIEW IF EXISTS county_list;
  DROP VIEW IF EXISTS confirmed_cases_daily;

  -- view to use when building county table
  CREATE VIEW staging_county_list
      AS
  SELECT county_fips,
  		 state_fips,
		 county_name
    FROM staging_confirmed_cases
GROUP BY county_fips,
		 state_fips,
		 county_name;

  -- view to use when building the state table
  CREATE VIEW staging_state_list
     AS
  SELECT state_fips,
  		 state_id
    FROM staging_confirmed_cases
GROUP BY state_fips,
		 state_id;

  --view to populate the confirmed_cases view
  CREATE VIEW staging_cases_list
      AS
  SELECT county_fips,
  		 test_date,
		 confirmed_cases
    FROM staging_confirmed_cases
   WHERE county_fips <> 0;

  -- view to populate population!
  CREATE VIEW staging_population
      AS
  SELECT county_fips,
  		 population
    FROM staging_county_population
   WHERE county_fips <> 0;

  -- view to populate county deaths
  CREATE VIEW staging_deaths
      AS
  SELECT county_fips,
  		 test_date,
		 covid_deaths
    FROM staging_county_deaths
   WHERE county_fips <> 0;
   
  -- county list (used for geo-coding)
  CREATE VIEW county_list
      AS
  SELECT cty.county_fips,
  		 cty.state_fips,
		 s.state_id,
		 cty.county_name,
		 cty.latitude,
		 cty.longitude
    FROM county cty INNER JOIN states s
	  ON cty.state_fips = s.state_fips;
	  
  -- plottin' views!
  CREATE VIEW confirmed_cases_daily
      AS
    WITH county_detail
	  AS
	   (
		  SELECT county_fips,
				 test_date,
				 RANK() OVER(PARTITION BY county_fips ORDER BY test_date) AS date_rank,
				 confirmed_cases
			FROM confirmed_cases
	   )
  SELECT cd1.county_fips,
  		 c.county_name,
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
   WHERE cd1.test_date <= '2020-04-16'
     AND c.county_name NOT LIKE '%Unallocated/Probable%'
	  
  