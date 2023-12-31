/*
1. The "mart__dim_bike_stations" table comprises a comprehensive list of unique station IDs, along with their 
   respective name,latitude and longitude coordinates.
2. Some station IDs have multiple records with slightly varying latitude values represented in decimal points.
3. To maintain data consistency, we have decided to retain only one record per station ID.
4. To accomplish this, we utilize the "row_number" function, partitioned by station ID and ordered by 
   station latitude, ensuring that only one representative record for each station is preserved.
*/

WITH station_details AS
(
	SELECT
		DISTINCT
		 start_station_id AS station_id,
		 start_station_name AS station_name,
		 start_lat AS station_lat,
		 start_lng AS station_lng
	FROM {{ ref('stg__bike_data') }}
	UNION
	SELECT
		DISTINCT
		 end_station_id AS station_id,
		 end_station_name AS station_name,
		 end_lat AS station_lat,
		 end_lng AS station_lng
	FROM {{ ref('stg__bike_data') }}
),
station_details_with_rank AS
(
	SELECT 
		station_id, 
		station_name,
		station_lat,
		station_lng,
		ROW_NUMBER() OVER(PARTITION BY station_id ORDER BY station_lat) AS Row_Num
	FROM station_details
)

SELECT 
	station_id, 
	station_name,
	station_lat,
	station_lng
FROM station_details_with_rank
WHERE Row_Num = 1
