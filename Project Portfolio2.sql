SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are using

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2;

-- Looking at the total cases vs total deaths
-- Shows the likelihood of dying if you get covid in your country

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT 
	location, 
	date, 
	population,
	total_cases,
	(total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population

SELECT 
	location,  
	population,
	MAX(total_cases) AS HighestInfectionCount,
	Max((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY CasePercentage DESC

--Showing countries with Highest Death Count per Population

SELECT 
	location,  
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Now to break it down by continent
SELECT 
	continent,  
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT 
	--date,  
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths AS int)) AS TotalDeaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

-- Let's look at the covid vaccinations table

SELECT *
FROM PortfolioProject..CovidVaccinations

--Joining the two tables
SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Looking at Total Population vs Vaccinations

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3 DESC

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
AS
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3 DESC
)
SELECT *,
	(RollingVaccinations/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3 DESC

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3 DESC

SELECT *
FROM PercentPopulationVaccinated