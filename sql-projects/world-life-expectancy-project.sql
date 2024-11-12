# Life Expectancy Data Cleaning Script

SELECT *
FROM worldlifexpectancy;

# Removing Duplicates
SELECT Country, Year, COUNT(CONCAT(Country, Year))
FROM worldlifexpectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

SELECT *
FROM (
	SELECT Row_ID, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM worldlifexpectancy
) AS Row_table
WHERE Row_Num > 1
;

# Delete rows 1251, 2264, 2929 because they are duplicates

DELETE FROM worldlifexpectancy
WHERE Row_ID IN (
	SELECT Row_ID
	FROM (
		SELECT Row_ID, CONCAT(Country, Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
		FROM worldlifexpectancy
	) AS Row_table
	WHERE Row_Num > 1
)
;

# Handle blank values
SELECT DISTINCT(Country)
FROM worldlifexpectancy
WHERE Status = 'Developing'
;

UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2 ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developing'
;

UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2 ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developed'
;

SELECT *
FROM worldlifexpectancy
WHERE Lifeexpectancy = ''
;

SELECT t1.Country, t1.Year, t1.Lifeexpectancy,
t2.Country, t2.Year, t2.Lifeexpectancy,
t3.Country, t3.Year, t3.Lifeexpectancy,
ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy) / 2, 1) AS new_life
FROM worldlifexpectancy t1
JOIN worldlifexpectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN worldlifexpectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
WHERE t1.Lifeexpectancy = ''
;

UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN worldlifexpectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
SET t1.Lifeexpectancy = ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy) / 2, 1)
WHERE t1.Lifeexpectancy = '';



# DATA ANALYSIS

# Min Max and Growth in life expectancy
SELECT Country, MIN(Lifeexpectancy), MAX(Lifeexpectancy), ROUND(MAX(Lifeexpectancy) - MIN(Lifeexpectancy),1) AS life_increase_15_years
FROM worldlifexpectancy
GROUP BY Country
HAVING MIN(Lifeexpectancy) <> 0
AND MAX(Lifeexpectancy) <> 0
ORDER BY life_increase_15_years DESC;


# Avg life expectancy per year
SELECT Year, ROUND(AVG(Lifeexpectancy), 2) AS avg_life_expectancy_year
FROM worldlifexpectancy
WHERE Lifeexpectancy <> 0
GROUP BY Year
ORDER BY Year;

# Correlation between life expectancy and other attributes
SELECT Country, ROUND(AVG(Lifeexpectancy), 2) AS Life_Exp, ROUND(AVG(GDP),2) AS Avg_GDP
FROM worldlifexpectancy
GROUP BY Country
HAVING Life_Exp > 0 AND Avg_GDP > 0
ORDER BY Avg_GDP ASC;

SELECT
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN Lifeexpectancy ELSE NULL END) High_Avg_Life_Exp,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN Lifeexpectancy ELSE NULL END) Low_Avg_Life_Exp
FROM worldlifexpectancy
;

SELECT Status, ROUND(AVG(lifeexpectancy),1), COUNT(DISTINCT Country)
FROM worldlifexpectancy
GROUP BY Status




 