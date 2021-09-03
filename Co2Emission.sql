
-- The annual emission of CO2 of Million Tonnes [MT] per Country and year. The highest emission of C02 and year for each country between 2000 and 2017
SELECT Entity as Country, Year, CAST((Annual_CO2_Tonnes/1000000) AS DECIMAL(32,2)) as [Annual Emission CO2 (MT)],
	CAST(MAX(Annual_CO2_Tonnes) OVER (Partition BY Entity)/1000000 AS DECIMAL(32,2)) as [The highest emission of CO2 MT],
	FIRST_VALUE(YEAR) OVER (Partition BY Entity ORDER BY Annual_CO2_Tonnes DESC) as [The year of the highest emission of CO2]
	FROM Project1.dbo.co2_emission
	WHERE Year BETWEEN 2000 and 2017 and Code != '' and Entity != 'World'
	ORDER BY Country ASC


--The sum of emission CO2 for TOP 10 countries with the highest emission of CO2 in Million Tonnes [MT] between 2000 and 2017. 
WITH EmissionBetween20002017 as 
(
	SELECT DISTINCT Entity as Country,
	CAST(SUM(Annual_CO2_Tonnes) OVER(Partition by Entity)/1000000 as DECIMAL(32,2)) as [Emission CO2 between 2000 and 2017 (MT)]
	FROM Project1.dbo.co2_emission
	WHERE Year BETWEEN 2000 and 2017 and Code != '' and Entity != 'World'
	GROUP BY Entity, Annual_CO2_Tonnes
)

SELECT TOP 10 *
FROM EmissionBetween20002017
ORDER BY [Emission CO2 between 2000 and 2017 (MT)] DESC

-- The ranking of countries, which emitted the highest amount of CO2 in Million Tonnes [MT] in 2017. 
--The indication of the country with the highest and the lowest emission of CO2 [MT] in 2017

SELECT DISTINCT
	RANK() OVER (order by Annual_CO2_Tonnes DESC) as Ranking,
	Entity as Country, 
	Year, 
	CAST((Annual_CO2_Tonnes)/1000000 as DECIMAL(32,2)) as [Emission Of CO2 (MT)],
	FIRST_VALUE(Entity) OVER (ORDER BY Annual_CO2_Tonnes DESC) as [Country with the highest emission],
	LAST_VALUE(Entity) OVER (ORDER BY Annual_CO2_Tonnes DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Country with the lowest emission]
	FROM Project1.dbo.co2_emission
	WHERE Year = 2017 and code != '' and Entity != 'World'
		

-- The statistical description of the data in 2017
WITH TheStatisticalDescriptionOfDataIn2017 as
(
	SELECT 
		CAST(SUM(Annual_CO2_Tonnes)/1000000 AS DECIMAL(32,2))  AS [The sum of the emission of CO2 (MT)],
		CAST(AVG(annual_CO2_Tonnes)/1000000 as DECIMAL(32,2)) as [The average of the emission of CO2 (MT)],
		COUNT(Entity) as 'Quantity of Countries',
		CAST(MAX(annual_CO2_Tonnes)/1000000 AS DECIMAL(32,2)) as [The maximum emission of CO2 (MT)],
		MIN(annual_CO2_Tonnes) as [The minimum emission of CO2 (T)]
	FROM Project1.dbo.co2_emission
	WHERE (Year IN (2017) and code != '' and Entity != 'World')
)

Select *
FROM TheStatisticalDescriptionOfDataIn2017

-- Median of Emission of CO2 Ton in 2017 for countries
With MedianCo2Emision2017 AS
(
	SELECT *,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Annual_CO2_Tonnes) OVER (PARTITION BY Year) as [MedianCont (T)],
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Annual_CO2_Tonnes) OVER (PARTITION BY Year) as [MedianDisc (T)]
	FROM Project1.dbo.co2_emission
	WHERE Year IN (2017) and code != '' and Entity != 'World'
)

SELECT [MedianCont (T)], [MedianDisc (T)]
FROM MedianCo2Emision2017
GROUP BY [MedianCont (T)], [MedianDisc (T)]

-- The classification of countries according to the level of the average emission of CO2 Million Tonnes in 2017

SELECT Entity as Country,
CASE
	WHEN Annual_CO2_Tonnes >= 163873823 THEN 'Greater than or equal to Average'
	WHEN Annual_CO2_Tonnes < 163873823 THEN 'Lower than Average'
END AS [The level of the emission of CO2 (MT)]
FROM Project1.dbo.co2_emission
WHERE (Year = 2017 and code != '' and Entity != 'World')
ORDER BY Annual_CO2_Tonnes DESC

--The classification of countries according to three groups of the level of the emission of CO2 MT
WITH GroupOfEmission2017 as 
(
	SELECT Entity,
	ntile(3) over (order by Annual_CO2_Tonnes DESC) as buckets
	FROM Project1.dbo.co2_emission
	WHERE Year = 2017 and Code != '' and Entity != 'World'
	GROUP BY Entity, Annual_CO2_Tonnes
)
SELECT Entity,
	CASE
		WHEN buckets = 1 Then 'High Emission'
		WHEN buckets = 2 Then 'Mid Emission'
		WHEN buckets = 3 Then 'High Emission'
	END AS [The clevel of the emission]
FROM GroupOfEmission2017


--The cumulative distribution of the emission of CO2 MT by countries. The Top 45 % of countries which emitted the most CO2 in the world in 2017.

WITH CUM_DISTRI_2017_COUNTRIES AS
(
	SELECT Entity as [Country], 
	CAST((Annual_CO2_Tonnes/1000000) AS DECIMAL(32,2)) as [Annual Emission CO2 (MT)],
	CAST(CUME_DIST() OVER (ORDER BY Annual_CO2_Tonnes DESC) * 100 AS DECIMAL(6,2)) AS [Cumulative Distribution (%)]
	FROM Project1.dbo.co2_emission
	WHERE Year = 2017 and Code != '' and Entity != 'World'
)

SELECT *
FROM CUM_DISTRI_2017_COUNTRIES
WHERE [Cumulative Distribution (%)] <= 45


-- Finding the percentaile ranks of countries by their Emission of CO2 
-- in particular Poland, Slovakia, Czech Republic, Ukraine, Hungary, Romania, Estonia, Latvia and Lithuania
-- in comparison to all countries in 2017
With PercentRankforSelectedCountries AS
(
	SELECT Entity as [Country], 
	CAST((Annual_CO2_Tonnes/1000000) AS DECIMAL(32,2))  as [Annual Emission CO2 (MT)],
	CAST(PERCENT_RANK() OVER(ORDER BY Annual_CO2_Tonnes) AS DECIMAL(6,2)) AS [Percentage Rank %]
	FROM Project1.dbo.co2_emission
	WHERE Year IN (2017) and Code != '' and Entity != 'World'
)
SELECT *
FROM PercentRankforSelectedCountries
WHERE Country IN ('Poland','Slovakia','Czech','Ukraine','Hungary','Romania','Estonia','Latvia','Lithuania')

-- The running total of the emission of CO2 MT between 2000 and 2017 for 8th most-industrialized Country
With RunningTotalOfEmissionOfCO2 AS
(
	SELECT Entity as Country, Year,
	CAST((Annual_CO2_Tonnes/1000000) AS DECIMAL(32,2)) as [Annual Emission CO2 (MT)],
	CAST(SUM(Annual_CO2_Tonnes) OVER (PARTITION BY Entity ORDER BY Year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/1000000 AS DECIMAL(32,2)) As [Running total of emission of CO2 (MT)] 
	FROM Project1.dbo.co2_emission
	WHERE Year BETWEEN 2000 and 2017 and Code!= '' and Entity != 'World'
)

SELECT Country, Year, [Running total of emission of CO2 (MT)]
FROM RunningTotalOfEmissionOfCO2
WHERE Country IN ('United States', 'China', 'Japan', 'Germany', 'France', 'India', 'Italy', 'Brazil' )

-- The percentage growth of the emission of CO2 MT for countries between 2000 and 2017
WITH TheGrowthOfEmission AS
(
	SELECT Entity as Country, Year,
	CAST((Annual_CO2_Tonnes/1000000) AS DECIMAL(32,2)) as [Annual Emission CO2 (MT)],
	CAST(LAG(Annual_CO2_Tonnes/1000000) OVER (PARTITION BY Entity ORDER BY Year) AS DECIMAL(32,2)) AS [Emission of CO2 previous year (MT)],
	CAST((Annual_CO2_Tonnes-LAG(Annual_CO2_Tonnes) OVER (PARTITION BY Entity ORDER BY Year))/1000000  AS DECIMAL(32,2))  As [Growth of emission of CO2 (MT)] 
	FROM Project1.dbo.co2_emission
	WHERE Year BETWEEN 2000 and 2017 and Code!= '' and Entity != 'World'
)

SELECT Country,YEAR, CAST(([Growth of emission of CO2 (MT)] / NULLIF([Emission of CO2 previous year (MT)],0)) * 100 AS DECIMAL(6,2)) as [YoY Growth of Emission %]
FROM TheGrowthOfEmission
WHERE YEAR != 2000

-- Total Emission of CO2 MT for Continent between 2000 and 2017
SELECT DISTINCT   Entity as Continent, 
	CAST((SUM(Annual_CO2_Tonnes) OVER (Partition BY Entity ORDER BY Entity))/1000000 AS DECIMAL(32,2)) as [The total emission of CO2 MT between 2000 and 2017 (MT)]
FROM Project1.dbo.co2_emission
WHERE Year BETWEEN 2000 and  2017 and code = '' and Entity != 'Statistical differences'
GROUP BY Entity, Annual_CO2_Tonnes
HAVING SUM(Annual_CO2_Tonnes) > 0
ORDER BY [The total emission of CO2 MT between 2000 and 2017 (MT)] DESC

--The running total of the emission of CO2 MT for Contitnent between 2000 and 2017
SELECT DISTINCT Entity as Continent, Year,
	CAST((Annual_CO2_Tonnes/1000000) AS DECIMAL(32,2))  as  [Emission Of CO2 (MT)],
	CAST(SUM(Annual_CO2_Tonnes) OVER (PARTITION BY Entity ORDER BY YEAR ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)/1000000 AS DECIMAL(32,2)) as [Running Total Emission of CO2 (MT)]
FROM Project1.dbo.co2_emission
WHERE Year BETWEEN 2000 and  2017 and code = '' and Entity != 'Statistical differences'
GROUP BY Entity, Annual_CO2_Tonnes,Year
HAVING SUM(Annual_CO2_Tonnes) >= 0


--The emission of CO2 MT in 2017 for Contitent
SELECT 
	row_number() over (order by Annual_CO2_Tonnes DESC) as Ranking,
	Entity as Continent,
	Year, 
	CAST(Annual_CO2_Tonnes/1000000 AS DECIMAL(32,2)) as [Annual Emission CO2 (MT)]
FROM Project1.dbo.co2_emission
WHERE Year = 2017 and code = '' and Entity !='Statistical differences'

--The Average Emission of CO2 MT between 2000 and 2017 for Continent
SELECT DISTINCT Entity as Continent, 
	CAST(AVG(Annual_CO2_Tonnes/1000000) OVER (Partition BY Entity) AS NUMERIC(38,2)) as [Average of Emission CO2 between 2000 and 2017 (MT)]
FROM Project1.dbo.co2_emission
WHERE Year BETWEEN 2000 and  2017 and code = '' and Entity != 'Statistical differences'
GROUP BY Entity, Annual_CO2_Tonnes
HAVING AVG(Annual_CO2_Tonnes) >= 0
ORDER BY [Average of Emission CO2 between 2000 and 2017 (MT)] DESC
--

