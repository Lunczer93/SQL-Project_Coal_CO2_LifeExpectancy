
--1. Verifying if the increase of the average emission of CO2 affects the average life expectancy between 2000 and 2017 in Countries by using CTE
WITH AVGEmissionCO2AndLifeExpectancy0007 AS
(
	SELECT DISTINCT  E.Entity as Country,
	--E.Year,
	--e.Annual_CO2_Tonnes as [Annual Emission CO2] , 
	--LE.Life_expectancy as [Life Expectancy],
	CAST(AVG(e.Annual_CO2_Tonnes) OVER (PARTITION BY E.Entity)/1000000 AS DECIMAL(32,2)) as [Avg Emission CO2 (MT)],
	CAST(AVG(LE.Life_expectancy) OVER (PARTITION BY E.Entity) AS INT) as [Avg Life Expectancy]
	FROM Project1.dbo.co2_emission E
	JOIN  Project1.dbo.life_expectancy LE
		ON (E.Year = LE.Year) AND (E.Entity = LE.Entity) 
	WHERE (E.Year BETWEEN 2000 and 2017 and E.Code != '' and E.Entity != 'World')
	GROUP BY E.Entity, E.Year,LE.Life_expectancy,e.Annual_CO2_Tonnes
)
SELECT *
FROM AVGEmissionCO2AndLifeExpectancy0007
ORDER BY [Avg Emission CO2 (MT)] DESC
---


-- 2. Verify if the level of the emission of CO2 affects the life expectancy for top 8 most industrialised country in 2017 by using CTE
WITH LifeExpectancyAndAnnualEmmission2017 AS
(
	SELECT E.Entity as Country, E.Year, 
	CAST(E.Annual_CO2_Tonnes/1000000 AS DECIMAL(32,2)) as [Annual Emission CO2 (MT)], 
	LE.Life_expectancy as [Life Expectancy]
	FROM Project1.dbo.co2_emission E
	JOIN Project1.dbo.life_expectancy LE
		ON (E.Year = LE.Year) AND (E.Entity = LE.Entity)
		WHERE E.Year IN ('2017') and E.Code != '' and E.Entity != 'World'
		--ORDER BY E.Annual_CO2_Tonnes DESC
)
-- The tendency for  top 8 most industrialised country in 2017 by the emission of CO2 and the life expectancy
SELECT  RANK() OVER (ORDER BY [Annual Emission CO2 (MT)] DESC) as [Ranking of Emission], *
FROM LifeExpectancyAndAnnualEmmission2017
WHERE Country IN ('United States', 'China', 'Japan', 'Germany', 'France', 'India', 'Italy', 'Brazil' )
ORDER BY [Annual Emission CO2 (MT)] DESC
---


-- 3. Verifying if Country produced enough amount of Coal in comparison to consumption between 2000 and 2019 by using CTE
WITH ConsumptionAndProductionOfCoal AS (

	SELECT C.Entity as [Country], C.Year,P.Coal_production_TWh as [Coal Production (TWh)], C.Coal_Consumption_TWh as [Coal Consumption (TWh)], 
		(P.Coal_production_TWh - C.Coal_Consumption_TWh) as [Difference]
	FROM Project1.dbo.coal_consumption_by_country_twh C
	JOIN Project1.dbo.coal_production_by_country P
		ON (C.Year = P.Year) AND (C.Entity = P.Entity) 
	WHERE (C.Year BETWEEN 2000 and 2019 and C.Code != '' and C.Entity != 'World')
)
SELECT Country, Year,
CASE
	WHEN Difference > 1 THEN 'The excess of Coal'
	WHEN Difference < -1 THEN 'The shortage of Coal'
	WHEN Difference = 0 THEN 'Balance'
END AS 'The usage of Coal'
FROM ConsumptionAndProductionOfCoal 
---


-- 4. The Summary of  Coal Production & Consumption  and Emission of CO2 and Life Expectancy in 2017 by combing rows Tables, based on a related column between them
SELECT E.Entity as Country, E.Year,
	CAST((e.Annual_CO2_Tonnes/1000000) as DECIMAL(32,2)) as [Annual Emission CO2 (MT)], 
	LE.Life_expectancy as [Life Expectancy],
	C.Coal_Consumption_TWh as [Coal Consumption (TWh)], 
	P.Coal_production_TWh as [Coal Production (TWh)] 
FROM Project1.dbo.co2_emission E
JOIN  Project1.dbo.life_expectancy LE
	ON (E.Year = LE.Year) AND (E.Entity = LE.Entity)
JOIN  Project1.dbo.coal_consumption_by_country_twh C
	ON (E.Year = C.Year) AND (E.Entity = C.Entity)
JOIN Project1.dbo.coal_production_by_country P
	ON (E.Year = P.Year) AND (E.Entity = P.Entity)
WHERE (E.Year IN ('2017') and E.Code != '' and E.Entity != 'World')
ORDER BY E.Annual_CO2_Tonnes DESC;
---


--5. Comparison between SUM of Coal Consumption & Production with CO2 Emission  between 2000 and 2019 by Country by using CTE
With SUMCoalConsumpProduandEmissionCO2 AS 
(
	SELECT DISTINCT C.Entity as [Country],
	--C.Year,
	--P.Coal_production_TWh as [Coal Production TWH], 
	--C.Coal_Consumption_TWh as [Coal Consumption TWh],
	CAST(SUM(E.Annual_CO2_Tonnes) OVER (PARTITION By C.Entity)/1000000 AS DECIMAL(32,2)) as [Total Emission CO2 (MT)],
	SUM(P.Coal_production_TWh) OVER (PARTITION By C.Entity) as [Total Coal Production (TWh)], 
	SUM(C.Coal_Consumption_TWh) OVER (PARTITION BY C.Entity) as [Total Coal Consumption (TWh)]
		FROM Project1.dbo.coal_consumption_by_country_twh C
		JOIN Project1.dbo.coal_production_by_country P
			ON (C.Year = P.Year) AND (C.Entity = P.Entity) 
		JOIN Project1.dbo.co2_emission E
			ON (C.Year = E.Year) AND (C.Entity = E.Entity) 
		WHERE (C.Year BETWEEN 2000 and 2019 and C.Code != '' and C.Entity != 'World' )
		GROUP BY C.Entity, P.Coal_production_TWh,C.Coal_Consumption_TWh,E.Annual_CO2_Tonnes
)
SELECT *
FROM SUMCoalConsumpProduandEmissionCO2
ORDER BY [Total Emission CO2 (MT)] DESC
---


--6. Comparison between the average of Coal Consumption & Production with CO2 Emission  between 2000 and 2019 by Country by using CTE
WITH AVGCoalConsumpProduandEmissionCO2 as
(
SELECT DISTINCT C.Entity as [Country],
--C.Year,
--P.Coal_production_TWh as [Coal Production TWH], 
--C.Coal_Consumption_TWh as [Coal Consumption TWh],
CAST(AVG(E.Annual_CO2_Tonnes) OVER (PARTITION By C.Entity)/1000000 AS DECIMAL(32,2)) as [Avgerage Emission CO2 (MT)],
CAST(AVG(P.Coal_production_TWh) OVER (PARTITION By C.Entity) AS DECIMAL(32,2)) as [Avgerage Coal Production (TWh)], 
CAST(AVG(C.Coal_Consumption_TWh) OVER (PARTITION BY C.Entity) AS DECIMAL(32,2)) as [Average Coal Consumption (TWh)]
	FROM Project1.dbo.coal_consumption_by_country_twh C
	JOIN Project1.dbo.coal_production_by_country P
		ON (C.Year = P.Year) AND (C.Entity = P.Entity) 
	JOIN Project1.dbo.co2_emission E
		ON (C.Year = E.Year) AND (C.Entity = E.Entity) 
	WHERE (C.Year BETWEEN 2000 and 2019 and C.Code != '' and C.Entity != 'World' )
	GROUP BY C.Entity, P.Coal_production_TWh,C.Coal_Consumption_TWh,E.Annual_CO2_Tonnes
)
SELECT *
FROM AVGCoalConsumpProduandEmissionCO2
ORDER BY [Avgerage Emission CO2 (MT)] DESC



