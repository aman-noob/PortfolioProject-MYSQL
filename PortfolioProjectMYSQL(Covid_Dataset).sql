-- DATASET- Covid 19 Data Exploration 
-- Skills used: CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    projectportfolio.coviddata
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

-- Total cases vs Total Deaths
-- Deathpercentage shows the likelihood of dying with Covid-19 infection

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    projectportfolio.coviddata
WHERE
    location LIKE '%India'  -- (looking for India's data)
ORDER BY 1 , 2;

-- Total cases vs Population
-- InfectedPercentage shows percent of population infected with Covid-19

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    population,
    (total_cases / population) * 100 AS InfectedPercentage
FROM
    projectportfolio.coviddata
WHERE
    location LIKE '%India'
ORDER BY 1 , 2;

-- Countries with Heighest Infection rate compared to Population (%)

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / population) * 100 AS InfectedPercentage
FROM
    projectportfolio.coviddata
GROUP BY location , population
ORDER BY InfectedPercentage DESC;

-- Countries with Heighest Death Count over Population

SELECT 
    location, 
    MAX(total_deaths) AS TotalDeathCount
FROM
    projectportfolio.coviddata
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's look at things at Continent level
-- Continent with Highest Death count

SELECT 
    continent, 
    MAX(total_deaths) AS TotalDeathCount
FROM
    projectportfolio.coviddata
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Total cases ATW (Around the World)

SELECT 
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathPercentage
FROM
    projectportfolio.coviddata
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

-- Total Population vaccinated ATW(Around The World)
-- Using CTE(Common Table Expression) 1st method

WITH populationVSvaccination (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
AS
(
SELECT 
    continent, 
    location, 
    date, 
    population, 
    new_vaccinations, SUM(new_vaccinations) over (partition by location order by location, date) as RollingVaccinationCount
FROM
    projectportfolio.coviddata
WHERE
    date and continent IS NOT NULL
)
SELECT *, (RollingVaccinationCount/Population)*100 as PercentagePopulationVaccinated
FROM populationVSvaccination;
			
-- OR Using Temp Table 2nd Method

DROP temporary Table if exists TbPercentPopulationVaccinated;

Create temporary Table TbPercentPopulationVaccinated
Select 
	Continent, 
    Location, 
    Date, 
    Population, 
    New_vaccinations, 
    SUM(New_vaccinations) OVER (Partition by Location Order by Location, Date) as RollingVaccinationCount 
FROM 
	projectportfolio.coviddata
WHERE 
	continent is not null
ORDER BY 2,3 ;

SELECT 
    *,
    (RollingVaccinationCount / Population) * 100 AS PercentagePopulationVaccinated
FROM
    TbPercentPopulationVaccinated;

-- Creating View to store data for later visualizations in Tableau

CREATE VIEW TbPercentPopulationVaccinated as
SELECT 
	Continent, 
    Location, 
    Date, 
    Population, 
    New_vaccinations, 
    SUM(New_vaccinations) OVER (Partition by Location Order by Location, Date) as RollingVaccinationCount 
FROM 
	projectportfolio.coviddata
WHERE 
	continent is not null
ORDER BY 2,3 ;

SELECT 
    *
FROM
    TbPercentPopulationVaccinated
WHERE
    date AND continent IS NOT NULL;










