/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Entity]
      ,[Code]
      ,[Year]
      ,[Life expectancy]
  FROM [Project1].[dbo].[life_expectancy]




--1. Looking at the average life expectancy by  country  between 2000 and 2017 so as to create TOP 10 Country that possesses the highest life expectancy by using CTE
--1. a) Create Common Table Expression to define the average life expectancy for country between 2000 and 2017
WITH TheAverageLifeExpectancy AS
(
  SELECT DISTINCT Entity as Country,
  CAST(AVG(life_expectancy) OVER(PARTITION BY Entity) AS DECIMAL(4,2)) AS [Average Life Expectancy]
  FROM Project1.dbo.life_expectancy
  WHERE YEAR BETWEEN 2000 and 2019 and Code != '' and Entity != 'World'
  GROUP BY Entity,life_expectancy
 )
 --1.b) TOP 10 Countries possess the highest life expectancy
 SELECT TOP 10 *
 FROM TheAverageLifeExpectancy
 ORDER BY [Average Life Expectancy] DESC
 ---


--2. Looking at The ranking of countries, which possess the highest life expectancy  in 2017.
--2.a) Creating a virtaul table based on the result set of an SQL statement to show the ranking of the country with life expectancy in 2017
CREATE VIEW RankingOfCountriesLifeExpectancy2017 AS
  SELECT 
  DENSE_RANK() OVER (ORDER BY life_expectancy DESC) as [Ranking],
  Entity as Country ,Year, life_expectancy as [Life Expectancy],
  FIRST_VALUE(Entity) OVER (ORDER BY life_expectancy DESC) as [Country with the highest life expectancy],
  LAST_VALUE(Entity) OVER (ORDER BY life_expectancy DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest life expectancy]
  FROM Project1.dbo.life_expectancy
  WHERE YEAR IN ('2017') and Code != '' and Entity != 'World'
--2.b)--The country with the highest and the lowest life expectancy in 2017
SELECT DISTINCT [Country with the highest life expectancy],  [Country with the lowest life expectancy]
FROM RankingOfCountriesLifeExpectancy2017
---


-- 3. The statistical description of the data in 2017 by Country using CTE
WITH TheSummaryOfDataIn2017 as
(
	SELECT 
		CAST(AVG(Life_expectancy) as NUMERIC(38,0)) as 'Average of Life Expectancy',
		COUNT(DISTINCT Entity) as 'Quantity of Countries',
		MAX(Life_expectancy) as 'The maximum Life Expectancy',
		MIN(Life_expectancy) as 'The minimum Life Expectancy'
	FROM Project1.dbo.life_expectancy
	WHERE (Year = 2017 and code != '' and Entity != 'World')
	
)
Select *
FROM TheSummaryOfDataIn2017
--3. a) Median of Life Expectancy in 2017 using CTE
WITH Median2017 AS
(
	SELECT Entity as Country, Year, life_expectancy as [Life Expectancy],
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY life_expectancy ) OVER (PARTITION BY Year) as [MedianCont],
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY life_expectancy ) OVER (PARTITION BY Year) as [MedianDisc]
  FROM Project1.dbo.life_expectancy
  WHERE YEAR IN('2017') and Code != '' and Entity != 'World'
  
)
SELECT MedianCont, MedianDisc
FROM Median2017
GROUP BY MedianCont, MedianDisc
---


--4. The classification of countries according to the level of the average Life Expectancy in 2017
--4.a) Declaring variable to obtain the average of the life expectancy from Table
DECLARE @AvgLifeExpectancy2017 INT
SET @AvgLifeExpectancy2017 = (SELECT CAST(AVG([Life_expectancy]) AS INT) FROM Project1.dbo.life_expectancy WHERE YEAR IN ('2017') and Code != '' and Entity != 'World')
PRINT @AvgLifeExpectancy2017
--4.b)The final classification of the countries as two groups (greater than average life expectancy and lower than average life expectancy) 
SELECT Entity as Country,
	CASE 
		WHEN life_expectancy >= @AvgLifeExpectancy2017 THEN 'Greater or equal to Average'
		ELSE 'Lower than Average'
		END AS 'Life Expectancy'
FROM Project1.dbo.life_expectancy
WHERE YEAR IN ('2017') and Code != '' and Entity != 'World' 
---


--5. The classification of countries according to three groups of the level of the Life Expectancy in 2017 using CTE
WITH ClassificationOfCountries AS
(
 SELECT Entity as Country, life_expectancy as [Life Expectancy],
	NTILE(3) OVER(ORDER BY life_expectancy DESC) as Buckets
  FROM Project1.dbo.life_expectancy
  WHERE YEAR IN ('2017') and Code != '' and Entity != 'World'
)
SELECT Country,
CASE
	WHEN Buckets = 1 THEN 'High Life Expectancy'
	WHEN Buckets = 2 THEN 'Mid Life Expectancy'
	WHEN Buckets = 3 THEN 'Low Life Expectancy'
END AS [Life Expectancy]
FROM ClassificationOfCountries
---


--6. The life expectancy in 2017 by Contitent
SELECT Entity as Country,Year, life_expectancy as [Life Expectancy]
  FROM Project1.dbo.life_expectancy
  WHERE YEAR IN ('2017')  and Code = '' and Entity != 'Saint Barthlemy'
---


--7. The average life expectancy by Continent between 2000 and 2017 
SELECT DISTINCT Entity as Country, 
	CAST(AVG(life_expectancy) OVER (PARTITION BY Entity) AS NUMERIC(6,2)) as [Life Expectancy]
  FROM Project1.dbo.life_expectancy
  WHERE YEAR BETWEEN 2000 and 2019 and Code = '' and Entity != 'Saint Barthlemy'
  