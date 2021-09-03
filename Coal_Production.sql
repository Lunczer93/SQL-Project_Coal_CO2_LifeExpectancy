SELECT *
FROM Project1.dbo.coal_production_by_country

--The annual Coal Production by country and year. 
-- The indication of the highest coal production by country and year between 2000 and 2019
SELECT DISTINCT Entity as Country,Year, Coal_production_TWh as [Coal production (TWh)],
	MAX(Coal_production_TWh) OVER (Partition BY Entity) as [The highest coal production (TWh)],
	FIRST_VALUE(YEAR) OVER (Partition by Entity ORDER BY Coal_production_TWh DESC) AS [The year of the highest coal production (TWh)]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
ORDER BY Entity ASC

--The total coal production by TOP 10 country between 2000 and 2019.
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

-- The ranking of countries, which produced the highest amount of Coal in 2016.
--The country with the highest and the lowest production in 2016
SELECT 
	RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
	Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
	FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
	LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR IN (2016) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0

-- The ranking of countries, which produced the highest amount of Coal in 2017.
--The country with the highest and the lowest production in 2017
SELECT 
	RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
	Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
	FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
	LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR IN (2017) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0

-- The ranking of countries, which produced the highest amount of Coal in 2018.
--The country with the highest and the lowest production in 2018

SELECT 
	RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
	Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
	FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
	LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR IN (2018) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0

-- The ranking of countries, which produced the highest amount of Coal in 2019.
--The country with the highest and the lowest production in 2019
SELECT 
	RANK() OVER(ORDER BY Coal_production_TWh DESC) as [Ranking],
	Entity as Country, Year, Coal_production_TWh as [Coal Production (TWh)],
	FIRST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC) as [Country with the highest Coal Production],
	LAST_VALUE(Entity) OVER (ORDER BY Coal_production_TWh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest Coal Production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR IN (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
		

-- The statistical description of the data between 2000 and 2019 by Country
SELECT  
	SUM(Coal_production_TWh) as [The total Coal Production (TWh)],
	CAST(AVG(Coal_production_TWh) AS DECIMAL(38,2)) AS [The total average of coal production (TWh)],
	COUNT(DISTINCT Entity) as [Quantity of Countries],
	MAX(Coal_production_TWh) AS [The maximum amount of Coal production (TWh)],
	MIN(Coal_production_TWh) AS [The minimum amount of Coal production (TWh)]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR BETWEEN 2000 AND 2019 AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
--Median of Coal Production by Country between 2000 and 2019
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



-- The classification of countries according to the level of the average coal production TWh in 2019
SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
CASE	
	WHEN Coal_production_TWh >= 891 THEN 'Greater or equal than Average'
	WHEN Coal_production_TWh < 891 THEN 'Lower than Average'
END AS [The level of the coal production]
FROM Project1.dbo.coal_production_by_country
WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
ORDER BY Coal_production_TWh DESC


--The classification of countries according to three groups of the level of the Coal consumption TWh in 2019
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


--The cumulative distribution of the Coal Production by Country.
--The Top 45 % of countries which produced the most Coal in the world in 2019.
WITH CumDistr AS 
(
	SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
		CAST(cume_dist() OVER (ORDER BY Coal_production_TWh DESC) * 100 AS DECIMAL(6,2)) as [Cumulative Distribution (%)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
	
)

SELECT Country, [Cumulative Distribution (%)]
FROM CumDistr
WHERE [Cumulative Distribution (%)] < 45


--Finding the percentaile ranks of countries by their Coal Production 
--for Poland, Slovakia, Czech Republic, Ukraine, Hungary, Estonia, Latvia and Lithuania
-- in comparison to all countries in 2019
WITH PercentageRanking AS 
(
	SELECT Entity as Country, Year, Coal_production_TWh as [Coal production (TWh)],
		CAST(PERCENT_RANK() OVER (ORDER BY Coal_production_TWh) * 100 AS DECIMAL(6,2)) as [Percentage Rank (%)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR in (2019) AND Code != '' and Entity != 'World' and Coal_production_TWh != 0
)
SELECT Country, [Percentage Rank (%)]
FROM PercentageRanking
WHERE Country IN ('Poland', 'Slovakia', 'Czechia', 'Ukraine' , 'Hungary', 'Romania', 'Estonia', 'Latvia' , 'Lithuania')

-- The running total of the coal production by 8th most-industrialized Country between 2000 and 2019 
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


-- The Growth of Coal Production by  Country between 2000 and 2020
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

SELECT Country, YEAR,
	ISNULL(CAST([The growth of the coal production] / [Coal production previous year (TWh)] * 100 AS DECIMAL(6,2)),0) as [YoY Percentage Growth of Coal Production (%)]
FROM TheGrowthOfTheProduction
WHERE YEAR != 2000 


-- Total Coal production by  Continent between 2000 and 2019
SELECT DISTINCT  Entity as Continent,
	SUM(Coal_production_TWh) OVER (PARTITION BY Entity) as  [Coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh, Code
	ORDER BY Entity


--The total Coal Production (TWh) by Country between 2000 and 2019. 
--The indication of the amount of the highest coal production and year by Country between 2000 and 2019
SELECT DISTINCT  Entity as Continent,Year,
	Coal_production_TWh  as  [Coal production (TWh)],
	SUM(Coal_production_TWh) OVER (PARTITION BY Entity ORDER BY Year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  as  [The running total of coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh, Code, Year
	ORDER BY Entity, Year


--The coal production in 2019 by  Contitent
SELECT DISTINCT  Entity as Continent,Year,
	Coal_production_TWh  as  [Coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR IN (2019) AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh, Code, Year
	ORDER BY Coal_production_TWh DESC


--The average coal production  between 2000 and 2017 by Continent
SELECT DISTINCT  Entity as Continent,
	CAST(AVG(Coal_production_TWh) OVER (Partition by Entity) AS NUMERIC(38,2))  as  [The average coal production (TWh)]
	FROM Project1.dbo.coal_production_by_country
	WHERE YEAR BETWEEN 2000 AND 2019 AND Code = '' and Entity != 'World' and Entity != 'Burma' and Coal_production_TWh != 0
	GROUP BY Entity,Coal_production_TWh
	ORDER BY [The average coal production (TWh)] DESC
