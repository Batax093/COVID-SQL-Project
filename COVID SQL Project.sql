SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

-- Select Data that we are going to be starting with
	
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2

-- Total Cases vs Total Deaths, example Indonesia
	
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indo%' and continent is not NULL
ORDER BY date

-- Total Cases vs Population, example Indonesia
	
SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indo%' and continent is not NULL
ORDER BY 1, 2

-- Countries with Highest Infection Rate compared to Population
	
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing contintents with the highest death count per population
	
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT date, SUM(new_cases) as TotalNewCases, 
	SUM(CAST(new_deaths as int)) TotalNewDeaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1, 2

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query
	
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PopulationVaccinated
FROM PopvsVac

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE location like '%Indo%'
ORDER BY 3, 4

-- Shows Percentage of Population that has tested for Covid using temp table
	
DROP TABLE IF EXISTS #PercentPopulationTested
CREATE TABLE #PercentPopulationTested
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_tests numeric,
PercentPopulationTested numeric
)

INSERT INTO #PercentPopulationTested
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_tests
, SUM(CAST(vac.new_tests as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleTest
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL and dea.location like '%Indonesia%'

SELECT *, (PercentPopulationTested/population)*100 as PopulationTested
FROM #PercentPopulationTested

-- Creating View to store data for later visualizations
	
CREATE VIEW PercentPopulationTested
as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_tests
, SUM(CAST(vac.new_tests as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleTest
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

CREATE VIEW PopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationTested

SELECT *
FROM PopulationVaccinated
