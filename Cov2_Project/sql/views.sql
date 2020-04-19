
  DROP VIEW IF EXISTS staging_county_list;
  DROP VIEW IF EXISTS staging_state_list;
  DROP VIEW IF EXISTS county_list;

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
  		 state_name
    FROM staging_confirmed_cases
GROUP BY state_fips,
		 state_name;
		 

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