SELECT *
FROM Project1.dbo.coal_production_by_country

--1. The annual Coal Production by country and year. 
--1.a) Create a virtual table to show the highest coal production by country and year between 2000 and 2019
CREATE VIEW CoalProductionCountries20002019 AS 
	SELECT DISTINCT Entity as Country,Year, Coal_production_TWh as [Coal production (TWh)],
		MAX(Coal_production_TWh) OVER (Partition BY Entity) as [The highest coal production (TWh)],
		FIRST_VALUE(YEAR) OVER (Partition by Entity ORDER BY Coal_production_TWh DESC) AS [The year of the highest coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
	ORDER BY Entity ASC
--1.b) The indiciation of Countries with the highest coal production according to year
SELECT DISTINCT [Country], [The highest coal production (TWh)], [The year of the highest coal production (TWh)]
FROM CoalProductionCountries20002019
---


--2. The total coal production by TOP 10 country between 2000 and 2019 by using CTE.
WITH ProductionOfCoal AS
(
	SELECT DISTINCT Entity as Country,
		SUM(Coal_production_TWh) OVER(Partition By Entity) as [Coal Production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
	GROUP BY Entity, Coal_production_TWh	
)
SELECT TOP 10 *
FROM ProductionOfCoal
ORDER BY [Coal Production (TWh)] DESC
---


--3.The ranking of countries, which produced the highest amount of Coal in 2016.
--3.a) Creating a virtual table based on the ranking of countires which produced the highest amount of Coal in 2016.
CREATE VIEW RankingOfCountries2016 AS 
	SELECT 
		RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
		Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
		FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
		LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR IN (2016) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
--3.b) The country with the highest and the lowest production in 2016
SELECT DISTINCT [Country with the highest Coal Production],[Country with the lowest Coal Production], [Year]
FROM RankingOfCountries2016
---


--4.The ranking of countries, which produced the highest amount of Coal in 2017.
--4.a) Creating a virtual table based on the ranking of countires which produced the highest amount of Coal in 2017.
CREATE VIEW RankingOfCountries2017 AS 
SELECT 
	RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
	Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
	FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
	LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR IN (2017) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
--4.b) The country with the highest and the lowest production in 2017
SELECT DISTINCT [Country with the highest Coal Production],[Country with the lowest Coal Production], [Year]
FROM RankingOfCountries2017
---


--5.The ranking of countries, which produced the highest amount of Coal in 2018.
--5.a) Creating a virtual table based on the ranking of countires which produced the highest amount of Coal in 2018.
CREATE VIEW RankingOfCountries2018 AS 
SELECT 
	RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
	Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
	FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
	LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR IN (2018) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
--5.b) The country with the highest and the lowest production in 2018
SELECT DISTINCT [Country with the highest Coal Production],[Country with the lowest Coal Production], [Year]
FROM RankingOfCountries2018
---


--5.The ranking of countries, which produced the highest amount of Coal in 2019.
--5.a) Creating a virtual table based on the ranking of countires which produced the highest amount of Coal in 2019.
CREATE VIEW RankingOfCountries2019 AS 
SELECT 
		RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
		Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
		FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
		LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR IN (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
--5.b) The country with the highest and the lowest production in 2018
SELECT DISTINCT [Country with the highest Coal Production],[Country with the lowest Coal Production], [Year]
FROM RankingOfCountries2019	
---


--6. The statistical description of the data between 2000 and 2019 by Country
SELECT  
	SUM(Coal_production_TWh) as [The total Coal Production (TWh)],
	CAST(AVG(Coal_production_TWh) AS DECIMAL(38,2)) AS [The total average of coal production (TWh)],
	COUNT(DISTINCT Entity) as [Quantity of Countries],
	MAX(Coal_production_TWh) AS [The maximum amount of Coal production (TWh)],
	MIN(Coal_production_TWh) AS [The minimum amount of Coal production (TWh)]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
--6a)Median of Coal Production by Country between 2000 and 2019 by using CTE
With MedianCoalProduction20002019 AS
(
	SELECT *,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Coal_production_TWh) OVER (PARTITION BY Year) as [MedianCont (TWh)],
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Coal_production_TWh) OVER (PARTITION BY Year) as [MedianDisc (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
)
SELECT Year, [MedianCont (TWh)], [MedianDisc (TWh)]
FROM MedianCoalProduction20002019
GROUP BY Year, [MedianCont (TWh)], [MedianDisc (TWh)]
---


-- 7. The classification of countries according to the level of the average coal production TWh in 2019
--7.a) Declaring variable to obtain the average of Coal Production in 2019 from Table
DECLARE @AvgCoalProd2019 int
SET @AvgCoalProd2019 = (SELECT AVG([Coal_production_TWh]) FROM Project1.dbo.coal_production_by_country WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0)
PRINT @AvgCoalProd2019 
--7.b)The final classification of the countries as two groups according to the coal production (greater or equal than average and lower than average)
SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
CASE	
	WHEN Coal_production_TWh >= @AvgCoalProd2019 THEN 'Greater or equal than Average'
	ELSE  'Lower than Average'
END AS [The level of the coal production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
ORDER BY Coal_production_TWh DESC
---


--8. The classification of countries according to three groups of the level of the Coal consumption TWh in 2019 by using CTE
WITH GroupOfCountries AS
(
	SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
		NTILE(3) OVER (ORDER BY Coal_production_TWh DESC) as Buckets
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
)
SELECT Country,
CASE
	WHEN Buckets = 1 THEN 'High Production'
	WHEN Buckets = 2 THEN 'Mid Production'
	WHEN Buckets = 3 THEN 'Low Production'
END AS 'The level of the coal production'
FROM GroupOfCountries
---


--9. The cumulative distribution of the Coal Production by Country by using CTE
WITH CumDistr AS 
(
	SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
		CAST(cume_dist() OVER (ORDER BY Coal_production_TWh DESC) * 100 AS DECIMAL(6,2)) as [Cumulative Distribution (%)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
)
--9.a) The Top 45 % of countries which produced the most Coal in the world in 2019.
SELECT Country, [Cumulative Distribution (%)]
FROM CumDistr
WHERE [Cumulative Distribution (%)] < 45
---


--10. Finding the percentaile ranks of countries by their Coal Production 
--for Poland, Slovakia, Czech Republic, Ukraine, Hungary, Estonia, Latvia and Lithuania
-- in comparison to all countries in 2019
WITH PercentageRanking AS 
(
	SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
		CAST(PERCENT_RANK() OVER (ORDER BY Coal_production_TWh) * 100 AS DECIMAL(6,2)) as [Percentage Rank (%)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
)
-- 10. a) The final percentaile ranks of selected countries in comparison to all countries in 2017
SELECT Country, [Percentage Rank (%)]
FROM PercentageRanking
WHERE Country IN ('Poland', 'Slovakia', 'Czechia', 'Ukraine' , 'Hungary', 'Romania', 'Estonia', 'Latvia' , 'Lithuania')
---


-- 11. The running total of the coal production by 8th most-industrialized Country between 2000 and 2019 by using CTE 
With RunningTotalOfCoalProduction AS 
(
	SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
		SUM(Coal_production_TWh) OVER(Partition By Entity ORDER BY YEAR ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as [The running total of the coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
)
SELECT Country, Year, [The running total of the coal production (TWh)]
FROM RunningTotalOfCoalProduction
WHERE Country IN ('United States', 'China' ,'Japan', 'Germany', 'France', 'India', 'Italy','Brazil')
---


-- 12. The Growth of Coal Production by  Country between 2000 and 2020 by using CTE
WITH TheGrowthOfTheProduction AS
(
SELECT  Entity as Country, Year, 
	Coal_production_TWh as  [Coal production (TWh)],
	LAG(Coal_production_TWh) OVER (PARTITION BY Entity ORDER BY YEAR) AS [Coal production previous year (TWh)],
	Coal_production_TWh-LAG(Coal_production_TWh) OVER (PARTITION BY Entity ORDER BY YEAR) as [The growth of the coal production]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh, Year
	--ORDER BY Entity, YEAR
)
-- 12.a) The final of the percentage Growth of Coal Production by  Country between 2000 and 2020
SELECT Country, YEAR,
	ISNULL(CAST([The growth of the coal production] / [Coal production previous year (TWh)] * 100 AS DECIMAL(6,2)),0) as [YoY Percentage Growth of Coal Production (%)]
FROM TheGrowthOfTheProduction
WHERE YEAR != 2000 
---


-- 13. Total Coal production by  Continent between 2000 and 2019
SELECT DISTINCT  Entity as Continent,
	SUM(Coal_production_TWh) OVER (PARTITION BY Entity) as  [Coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh, Code
	ORDER BY Entity
---


--16. The total Coal Production (TWh) by Country between 2000 and 2019. 
--16.a) The indication of the amount of the highest coal production and year by Country between 2000 and 2019
SELECT DISTINCT  Entity as Continent,Year,
	Coal_production_TWh  as  [Coal production (TWh)],
	SUM(Coal_production_TWh) OVER (PARTITION BY Entity ORDER BY Year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  as  [The running total of coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh, Code, Year
	ORDER BY Entity, Year
---


--17. The coal production in 2019 by  Contitent
SELECT DISTINCT  Entity as Continent,Year,
	Coal_production_TWh  as  [Coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR IN (2019) AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh, Code, Year
	ORDER BY Coal_production_TWh DESC
---


--18. The average coal production  between 2000 and 2017 by Continent
SELECT DISTINCT  Entity as Continent,
	CAST(AVG(Coal_production_TWh) OVER (Partition by Entity) AS NUMERIC(38,2))  as  [The average coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh
	ORDER BY [The average coal production (TWh)] DESC
