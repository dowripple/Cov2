
  -- remove the views if they exist
  DROP VIEW IF EXISTS staging_county_list;
  DROP VIEW IF EXISTS staging_state_list;
  DROP VIEW IF EXISTS staging_cases_list;
  DROP VIEW IF EXISTS staging_population;
  DROP VIEW IF EXISTS staging_deaths;
  DROP VIEW IF EXISTS county_list;
  DROP VIEW IF EXISTS confirmed_cases_daily;

  -- remove any foreign key references if they exist
  ALTER TABLE county DROP CONSTRAINT IF EXISTS fk_county_state_id;
  ALTER TABLE confirmed_cases DROP CONSTRAINT IF EXISTS fk_confirmed_cases_county_fips;
  ALTER TABLE confirmed_cases DROP CONSTRAINT IF EXISTS fk_confirmed_cases_test_date;
  ALTER TABLE county_population DROP CONSTRAINT IF EXISTS fk_county_population_county_fips;
  ALTER TABLE county_deaths DROP CONSTRAINT IF EXISTS fk_county_deaths_county_fips;

  -- drop the tables if they exist
  DROP TABLE IF EXISTS staging_confirmed_cases;
  DROP TABLE IF EXISTS county;
  DROP TABLE IF EXISTS states;
  DROP TABLE IF EXISTS test_dates;
  DROP TABLE IF EXISTS confirmed_cases;
  DROP TABLE IF EXISTS staging_county_population;
  DROP TABLE IF EXISTS county_population;
  DROP TABLE IF EXISTS staging_county_deaths;
  DROP TABLE IF EXISTS county_deaths;
  DROP TABLE IF EXISTS staging_test_dates;
  
  -- staging table for test dates
  CREATE TABLE staging_test_dates
  		(test_date DATE);
  
  -- staging table for confirmed cases
  CREATE TABLE staging_confirmed_cases
  		(county_fips INT,
		 county_name VARCHAR,
		 state_id VARCHAR,
		 state_fips INT,
		 test_date DATE,
		 confirmed_cases BIGINT
		);

  -- table for county
  CREATE TABLE county
  		(county_fips INT NOT NULL PRIMARY KEY,
		 state_fips INT,
		 county_name VARCHAR,
		 latitude FLOAT,
		 longitude FLOAT);

  -- table for state
  CREATE TABLE states
  		(state_fips INT NOT NULL PRIMARY KEY,
		 state_id VARCHAR);

  -- create the table for dates
  CREATE TABLE test_dates
  		(test_date DATE NOT NULL PRIMARY KEY);

  -- table to store the confirmed case counts by county and date
  CREATE TABLE confirmed_cases
  		(test_date DATE NOT NULL,
		 county_fips INT NOT NULL,
		 confirmed_cases BIGINT,
		 CONSTRAINT "pk_confirmed_cases" PRIMARY KEY (
         		test_date,
			    county_fips
		 	)	
		  );

  -- table for staging
  CREATE TABLE staging_county_deaths
  		(county_fips INT,
		 test_date DATE,
		 covid_deaths BIGINT);
		 
  -- table to store county deaths
  CREATE TABLE county_deaths
  		(county_fips INT NOT NULL,
		 test_date DATE NOT NULL,
		 covid_deaths BIGINT,
		 CONSTRAINT "pk_county_deaths" PRIMARY KEY (
				county_fips,
				test_date
		 	)
		 );
		 
  -- table to store the staging population data
  CREATE TABLE staging_county_population
  		(county_fips INT,
		 county_name VARCHAR,
		 state_id VARCHAR,
		 population BIGINT);

  -- table for population
  CREATE TABLE county_population
  		(county_fips INT NOT NULL PRIMARY KEY,
		 population BIGINT
		);
		
  -- adding foreign key constraints
  -- county referencing state
  ALTER TABLE county ADD CONSTRAINT "fk_county_state_fips" FOREIGN KEY(state_fips)
	REFERENCES states (state_fips);
  -- confirmed cases referencing county
  ALTER TABLE confirmed_cases ADD CONSTRAINT "fk_confirmed_cases_county_fips" FOREIGN KEY (county_fips)
  	REFERENCES county (county_fips);
  -- confirmed cases referencing dates
  ALTER TABLE confirmed_cases ADD CONSTRAINT "fk_confirmed_cases_test_date" FOREIGN KEY (test_date)
  	REFERENCES test_dates (test_date);
  -- county population referencing county
  ALTER TABLE county_population ADD CONSTRAINT "fk_county_population_county_fips" FOREIGN KEY (county_fips)
  	REFERENCES county (county_fips);
  -- county deaths referencing county
  ALTER TABLE county_deaths ADD CONSTRAINT "fk_county_deaths_county_fips" FOREIGN KEY (county_fips)
  	REFERENCES county (county_fips);
	
  
		
		