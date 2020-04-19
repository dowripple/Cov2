
  -- drop the tables if they exist
  DROP TABLE IF EXISTS staging_confirmed_cases;
  DROP TABLE IF EXISTS county;
  DROP TABLE IF EXISTS states;
  
  -- staging table for confirmed cases
  CREATE TABLE staging_confirmed_cases
  		(county_fips INT,
		 county_name VARCHAR,
		 state_name VARCHAR,
		 state_fips INT,
		 test_date DATE,
		 confirmed_cases BIGINT
		);

  -- table for county
  CREATE TABLE county
  		(county_fips INT,
		 state_fips INT,
		 county_name VARCHAR,
		 latitude FLOAT,
		 longitude FLOAT);

  -- table for state
  CREATE TABLE states
  		(state_fips INT,
		 state_id VARCHAR);
		 

		
		