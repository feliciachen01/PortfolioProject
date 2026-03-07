SELECT * FROM covid_deaths;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent != ''
ORDER BY 1, 2;

-- Looking at Total Cases vs. Total Deaths
-- the likelihood of death after contracting COVID in Canada
-- increased then decreased
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location = 'Canada' AND continent != ''
ORDER BY 1, 2;

-- Looking at Total Cases vs. Population
-- % of population that got COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
FROM covid_deaths
WHERE location = 'Canada' AND continent != ''
ORDER BY 1, 2;


-- Countries w/ Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as highest_infection_count, max(total_cases/population)*100 as percent_population_infected
FROM covid_deaths
WHERE continent != ''
GROUP BY location, population
ORDER BY percent_population_infected desc;


-- showing countries with highest death count per population
-- shows 'World' , continents instead of just countries
-- went back and placed condition continent != ''
SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent != ''
GROUP BY location
ORDER BY total_death_count desc;


-- By continent:
SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent = ''
GROUP BY location
ORDER BY total_death_count desc;


-- Globally
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as totalDeathPercent
FROM covid_deaths
WHERE continent != ''
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as totalDeathPercent
FROM covid_deaths
WHERE continent != ''
ORDER BY 1, 2;


-- LOOKING AT VACCINATIONS NOW
SELECT * 
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date;
    
-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPplVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent != '';

-- using CTE
WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPplVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPplVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent != ''
)
SELECT *, (RollingPplVaccinated/Population)*100
FROM PopvsVac;

-- or temp table

DROP TEMPORARY TABLE IF EXISTS Percent_Population_Vaccinated;

CREATE TEMPORARY TABLE Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPplVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date;
    
SELECT * FROM Percent_Population_Vaccinated;



-- Views
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPplVaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent != '';