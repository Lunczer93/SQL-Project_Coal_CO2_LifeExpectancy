SELECT *
FROM Project1.dbo.coal_consumption_by_country_twh 

--The total Coal consumption by Continent between 2000 and 2020

SELECT  DISTINCT  
	Entity as Continent,
	SUM(Coal_Consumption_Twh) OVER(Partition BY Entity) as [Total Coal Consumption (TWh) between 2000 and 2020]
FROM Project1.dbo.coal_consumption_by_country_twh 
WHERE code = '' and YEAR BETWEEN 2000 and 2020
GROUP BY Entity,Coal_Consumption_Twh
ORDER BY [Total Coal Consumption (TWh) between 2000 and 2020] DESC

--The total Coal consumption (TWh) by Country between 2000 and 2020. 
--The indication of the amount of the highest consumption of Coal and year by Country between 2000 and 2020
SELECT DISTINCT
	Entity as [Country],
	YEAR as [Year],
	Coal_Consumption_TWh as [Total Coal Consumption (TWh)],
	MAX(Coal_Consumption_Twh) OVER (Partition BY Entity) as [The highest coal consumption (TWh)],
	FIRST_VALUE(YEAR) OVER (Partition BY Entity ORDER BY Coal_Consumption_TWh DESC) as [The year of the highest consumption of Coal]
FROM Project1.dbo.coal_consumption_by_country_twh
WHERE Code != '' and YEAR BETWEEN 2000 and 2020 and Coal_Consumption_Twh != 0 and Entity !='World'
ORDER BY Entity


--The statistical description of the data between 2000 and 2020 by Country
SELECT 
	SUM(Coal_Consumption_Twh) as [Total Coal Consumption (TWh)],
	CAST(AVG(Coal_Consumption_Twh) AS DECIMAL(38,2)) as [Average of Coal Consumption (TWh)],
	COUNT(DISTINCT Entity) as [Quantity of Countries],
	MAX(Coal_Consumption_Twh) as [The maximum amount of Coal Consumption (TWh)],
	MIN(Coal_Consumption_Twh) as [The minimum amout of Coal Consumption (TWh)]
FROM Project1.dbo.coal_consumption_by_country_twh
WHERE Code != '' and YEAR between 2000 and 2020 and Coal_Consumption_Twh != 0 and Entity !='World';
--Median of Coal Consumption by Country between 2000 and 2020
With MedianCoalConsumption20002020 AS
(
	SELECT *,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Coal_Consumption_Twh) OVER (PARTITION BY Year) as [MedianCont (TWh)],
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Coal_Consumption_Twh) OVER (PARTITION BY Year) as [MedianDisc (TWh)]
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR between 2000 and 2020 and Coal_Consumption_Twh != 0 and Entity !='World'
)

SELECT Year, [MedianCont (TWh)], [MedianDisc (TWh)]
FROM MedianCoalConsumption20002020
GROUP BY Year, [MedianCont (TWh)], [MedianDisc (TWh)]

--The statistical description of the data in 2017 by Country
SELECT 
	SUM(Coal_Consumption_Twh) as [Total Coal Consumption (TWh)],
	CAST(AVG(Coal_Consumption_Twh) AS DECIMAL(38,2)) as [Average of Coal Consumption (TWh)],
	COUNT(Entity) as [Quantity of Countries],
	MAX(Coal_Consumption_Twh) as [The maximum amount of Coal Consumption (TWh)],
	MIN(Coal_Consumption_Twh) as [The minimum amount of Coal Consumption (TWh)]
FROM Project1.dbo.coal_consumption_by_country_twh
WHERE Code != '' and YEAR = 2017 and Coal_Consumption_Twh != 0 and Entity !='World';
--Median of Coal Consumption by Country in 2017
With MedianCoalConsumption2017 AS
(
	SELECT *,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Coal_Consumption_Twh) OVER (PARTITION BY Year) as [MedianCont (TWh)],
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Coal_Consumption_Twh) OVER (PARTITION BY Year) as [MedianDisc (TWh)]
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR = 2017 and Coal_Consumption_Twh != 0 and Entity !='World'
)

SELECT [MedianCont (TWh)], [MedianDisc (TWh)]
FROM MedianCoalConsumption2017
GROUP BY [MedianCont (TWh)], [MedianDisc (TWh)]



-- The running total of Coal Consumption by Country between 2000 and 2020
WITH RunningTotalOfConsumption AS 
(
	SELECT Entity as [Country], Year, Coal_Consumption_Twh as [Coal Consumption (TWh)],
		SUM(Coal_Consumption_Twh) OVER(PARTITION BY Entity ORDER BY YEAR ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Running Total of Coal Consumption (TWh)]
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR between 2000 and 2020 and Entity != 'World'
)
-- The running total of consumption of Coal between 2000 and 2020 for selected countries
SELECT *
FROM RunningTotalOfConsumption
WHERE Country in('United States', 'China', 'Japan', 'Germany', 'France', 'India', 'Italy', 'Brazil')


-- The Growth of Coal Consumption by most-industrialized Country between 2000 and 2020
WITH GrowthOfCoalConsumption20002020 AS
(
	SELECT Entity as [Country], Year,Coal_Consumption_Twh as [Coal Consumption (TWh)],
			LAG(Coal_Consumption_Twh) OVER(PARTITION BY Entity ORDER BY YEAR) AS [Consumption Coal (TWh) by Prevous year],
			Coal_Consumption_Twh - LAG(Coal_Consumption_Twh) OVER(PARTITION BY Entity ORDER BY YEAR) AS [Growth of Coal Consumption (TWh)]
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR between 2000 and 2020 and Entity != 'World' 
	AND Entity in('United States', 'China', 'Japan', 'Germany', 'France', 'India', 'Italy', 'Brazil')

)
-- The percentage growth of the Consumption of Goal by selected countries
SELECT Country, Year,
	CAST([Growth of Coal Consumption (TWh)]/NULLIF([Consumption Coal (TWh) by Prevous year],0) * 100 AS DECIMAL(6,2)) AS [YoY Growth of Coal Consumption (%)]
FROM GrowthOfCoalConsumption20002020
WHERE YEAR != 2000


--Looking for country with the highest Coal consumption between 2000 and 2020
SELECT Entity as Country,Coal_Consumption_Twh as [Coal Consumption (TWh)]
FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Coal_Consumption_Twh in(
					SELECT MAX(Coal_Consumption_Twh) as 'MAX  of Coal Consumption Twh'
					FROM Project1.dbo.coal_consumption_by_country_twh
					WHERE Code != '' and YEAR between 2000 and 2020 and Coal_Consumption_Twh != 0 and Entity !='World')
--Looking for country with the lowest Coal consumption between 2000 and 2020
SELECT DISTINCT Entity as Country,Coal_Consumption_Twh as [Coal Consumption (TWh)]
FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Coal_Consumption_Twh in(
					SELECT MIN(Coal_Consumption_Twh) as 'MAX  of Coal Consumption Twh'
					FROM Project1.dbo.coal_consumption_by_country_twh
					WHERE Code != '' and YEAR between 2000 and 2020 and Coal_Consumption_Twh != 0 and Entity !='World'
					)
-- The classification of countries according to three groups of the level of the Coal Consumption TWh between 2000 and 2020
WITH GroupOfCountries AS
(
	SELECT DISTINCT Entity as Country,
	SUM(Coal_Consumption_Twh) OVER(PARTITION BY Entity) as [Total Coal Consumption (TWh) between 2000 and 2020],
		NTILE(3) OVER (ORDER BY Coal_Consumption_Twh DESC) as Buckets
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR between 2000 and 2020 and Coal_Consumption_Twh != 0 and Entity !='World'
	GROUP BY Entity, Coal_Consumption_Twh
)

SELECT Country,
	CASE 
		WHEN Buckets = 1 THEN 'High Consumption'
		WHEN Buckets = 2 THEN 'Mid Consumption'
		WHEN Buckets = 3 THEN 'Low Consumption'
	END AS 'The level of Coal Consumption'
FROM GroupOfCountries
ORDER BY Buckets ASC


-- TOP 10 Countries  consumed the highest amount of Coal between 2000 and 2020
WITH TOP10Consumption AS
(
	SELECT DISTINCT Entity as Country,
	SUM(Coal_Consumption_Twh) OVER(PARTITION BY Entity) as [Total Coal Consumption (TWh)]
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR between 2000 and 2020 and Coal_Consumption_Twh != 0 and Entity !='World'
	GROUP BY Entity, Coal_Consumption_Twh
)

SELECT TOP 10 *
FROM TOP10Consumption
ORDER BY [Total Coal Consumption (TWh)] DESC

-- The classification of the country according to the level of the average of Coal Consumption (TWh) in 2020
SELECT DISTINCT
	RANK() OVER (ORDER BY Coal_Consumption_TWh DESC) as Ranking,
	Entity as [Country],
	Coal_Consumption_TWh as [Total Goal Consumption (TWh)],
	CASE
		WHEN Coal_Consumption_TWh >= 609 THEN 'Greater or equal to Average'
		ELSE 'Lower Than Average'
	END AS 'The Average Coal Consumption'
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR = 2020 and Coal_Consumption_Twh != 0 and Entity !='World'
	ORDER BY Ranking
--The classification of the country according to the level of the average of Coal Consumption (TWh) in 2017

SELECT DISTINCT
	RANK() OVER (ORDER BY Coal_Consumption_TWh DESC) as Ranking,
	Entity as [Country],
	Coal_Consumption_TWh as [Total Goal Consumption (TWh)],
	CASE
		WHEN Coal_Consumption_TWh >= 609 THEN 'Greater or equal to Average'
		ELSE 'Lower Than Average'
	END AS 'The Average Coal Consumption'
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR = 2017 and Coal_Consumption_Twh != 0 and Entity !='World'
	ORDER BY Ranking



--The cumulative distribution of the Coal Consumption by Country. The Top 45 % of countries which consumed the most coal in the world in 2017.
WITH CumDistrCons AS 
(
	SELECT Entity as [Country], Coal_Consumption_Twh as [Coal Consumption (TWh)],
		CAST(CUME_DIST() OVER(ORDER BY Coal_Consumption_Twh DESC) * 100 AS DECIMAL(6,2)) as [Cumulative Distribution (%)]
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR = 2017 and Coal_Consumption_Twh != 0 and Entity !='World'
)

SELECT Country, [Cumulative Distribution (%)]
FROM CumDistrCons
WHERE [Cumulative Distribution (%)] <= 45

--Finding the percentaile ranks of countries by their Coal Consumption 
--for Poland, Slovakia, Czech Republic, Ukraine, Hungary, Estonia, Latvia and Lithuania
-- in comparison to all countries in 2017
WITH PercentRank AS 
(
	SELECT Entity as [Country], Coal_Consumption_Twh as [Coal Consumption (TWh)],
		CAST(Percent_rank() OVER(ORDER BY Coal_Consumption_Twh) * 100 AS DECIMAL(6,2)) as [Percantage Rank (%)]
	FROM Project1.dbo.coal_consumption_by_country_twh
	WHERE Code != '' and YEAR = 2017 and Coal_Consumption_Twh != 0 and Entity !='World'
)
SELECT Country,[Percantage Rank (%)]
FROM PercentRank
WHERE Country IN ('Poland', 'Slovakia', 'Czech Republic', 'Ukraine', 'Hungary', 'Estonia', 'Latvia', 'Lithuania')

--The ranking of countries, which consumed the highest amount of Coal in 2017.
--The country with the highest and the lowest consumption in 2017
SELECT Entity as [Country], Coal_Consumption_Twh as [Coal Consumption (TWh)],
	FIRST_VALUE(Entity) OVER (ORDER BY Coal_Consumption_Twh DESC) As [Country with the highest consumption],
	LAST_VALUE(Entity) OVER (ORDER BY Coal_Consumption_Twh DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) As [Country with the lowest consumption]
FROM Project1.dbo.coal_consumption_by_country_twh
WHERE Code != '' and YEAR = 2017 and Coal_Consumption_Twh != 0 and Entity !='World'