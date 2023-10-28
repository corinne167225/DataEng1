-- use the 'cropyield' database
use cropyield;
###########################################################
-- Procedure 1
-- Procedure for getting a country's top crop yielded (in Hectograms per Hectare) regardless of year
DROP PROCEDURE IF EXISTS GetTopCrop;

DELIMITER //

CREATE PROCEDURE GetTopCrop(
	IN country VARCHAR(255)
)
BEGIN
	SELECT area as Country, item as Crop, max(value) as MaxCropYield
 		FROM yield
			WHERE country = area
				GROUP BY area, item
					ORDER by max(value)
						DESC limit 1;
END //
DELIMITER ;
-- call the procedure by inputting a country name
call GetTopCrop('Belgium');

################################################################
-- Procedure 2
-- Procedure to see relationship between tempurature and yield (merging 2 data tables)//ETL
DROP PROCEDURE IF EXISTS TempAndYield;

DELIMITER //

CREATE PROCEDURE TempAndYield()
BEGIN

	DROP TABLE IF EXISTS TempxYield;

	CREATE TABLE TempxYield AS #represents the LOAD part (ETL)
	SELECT #represents the EXTRACT part (ETL)
	   t2.country AS Country, 
       t2.year AS Year,
	   t1.item As Crop,   
       t1.Value As CropYielded, 
	   t1.unit As Unit,
       t2.avgTemp AS AvgTempCelsius, 
       (t2.avgTemp * 9/5) + 32 AS AvgTempFahrenheit #represents the TRANSFORM part (ETL)
	FROM
		yield as t1
	INNER JOIN
		temp as t2
	on
		t1.area = t2.country
	WHERE
		t2.Year >= 2007 AND t2.year <= 2013
	ORDER BY 
		Country, 
		Year,
        Crop,
        AvgTempCelsius;

END //
DELIMITER ;

-- call the procedure (creates new table ' TempxYield')
CALL TempAndYield();
Select * from TempxYield;
############################################################
-- Create a trigger where inserting new observation on temp table, creates a new insertion on 
-- table TempxYield

DROP TRIGGER IF EXISTS after_temp_insert; 

DELIMITER $$

CREATE TRIGGER after_temp_insert
AFTER INSERT
ON temp FOR EACH ROW
BEGIN

	-- archive the temperature and assosiated table entries to TempxYield
  	INSERT INTO TempxYield
	SELECT 
	   t2.country AS Country, 
	   t2.year AS Year, 
	   t1.item AS Crop,
	   t1.value As CropYielded,
	   t1.unit As Unit,
	   t2.avgTemp As AvgTempCelsius,   
       (t2.avgTemp * 9/5) + 32 AS AvgTempFahrenheit
	FROM
		yield as t1
	INNER JOIN
		temp as t2
	on
		t1.area = t2.country
	WHERE
		t2.Year >= 2007 AND t2.year <= 2013
        and
	    avgTemp = NEW.avgTemp
    
	ORDER BY 
		Country, 
		Year,
        Crop;
        
        
END $$

DELIMITER ;

-- activating the trigger 
SELECT * from TempxYield;

INSERT INTO temp VALUES(2008, 'Austria', 999);

SELECT * from TempxYield;
############################################################
-- View as data mart (2007-2013 Potato Yields in Austria and Belgium)
DROP VIEW IF EXISTS PotatoesATxBE;

CREATE VIEW `PotatoesATxBE` AS
SELECT * FROM TempXYield WHERE crop = 'Potatoes' and country in ("Austria", "Belgium");

SELECT * FROM cropyield.`PotatoesATxBE`;
############################################################
-- View as data mart (2007-2013 Maize Yields in Austria and Belgium)
DROP VIEW IF EXISTS MaizeATxBE;

CREATE VIEW `MaizeATxBE` AS
SELECT * FROM TempXYield WHERE crop = 'Maize' and country in ("Austria", "Belgium");

SELECT * FROM cropyield.`MaizeATxBE`;
############################################################