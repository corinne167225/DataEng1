# Term1 Project Documentation
## Data Collection
I used a dataset from Kaggle.com called 'Crop Yield Prediction Dataset' that took various
countries and predicted the crop yield of the top 10 most consumed crops in the world.
The dataset was downloaded on Kaggle from FAO (Food and Agriculture Organization) and World Bank Data.
I created the 'cropyield' schema and then uploaded the files.
There were 5 data tables in the set:
+ `pesticides.csv`: amount of pesticides used
+ `rainfall.csv`: amount of rainfall 
+ `temp.csv`: avgerage temperature (Celsius) 
    + The above csv was not loading properly into MySQL Workbench due to an encoding 
    problem, so I convereted the csv into a JSON file using a converter: `temp_csv_to_json.json`
+ `yield.csv`: amount of crops yielded 
+ `yield_df.csv`: (not relevant for my project, but a join of all previous tables)
## EER Diagram
I created the EER diagram by declaring each tables' primary key and foreign keys (if
any existed). I used the 'reverse engineer' option in the Database tab as I had already uploaded
the data files.
## Queries
### Use schema
Used the cropyield schema
### Procedues
#### Procedure 1: GetTopCrop
Created a procedure for getting a country's top yielded crop (in hectograms per hectare).
Made sure to drop the procedure if exists before writing procedure. Input: country name, Output: country's crop
Called the procedure with 'Belgium' as the input to test
#### Procedure 2: TempAndYield
Created a procedure to see relationship between temperature and yield by merging 2 data tables. *Also built an ETL pipeline. 
It should also be noted that all years of the data table was too much for the server to take (
kept disconnecting), so I narrowed the years down to 2007-2013.
- Extract: selected variables from other existing data tables
- Transform: created a variable for AvgTempFahrenheit rather than just having Celsius
- Load: created the new table by joining two tables.   
I then called the procedure to test it and selected * from the newly created table, 'TempxYield'.
### Trigger: after_temp_insert
Created a trigger where inserting new observation on temp table, creates a new insertion 
on the TempxYield table. Dropped trigger if exists. To test it, I activated the trigger by 
inputting values of year 2008, country 'Austria', and avgTemp 999 degrees Celsius, into the temp table. 
I then selected * from the TempxYield table and searched for Austria's input with 999 degrees.
### Trigger: Views as data mart
#### View 1: PotatoesATxBE
Created a view to see the potato yielded (as well as avgTemp) in Austria versus Belgium for years 2007-2013.
Made sure to drop the view if existed. To test, selected * from the new view.
#### View 2: MaizeATxBE
Created a view to see the maize yielded (as well as avgTemp) in Austria versus Belgium for years 2007-2013.
Made sure to drop the view if existed. To test, selected * from the new view.

