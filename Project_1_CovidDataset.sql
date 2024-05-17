SELECT * 
FROM CovidDeath
WHERE continent IS NOT NULL;

--Selecting the data  we are going to work with

SELECT location,"date",total_cases,new_cases,total_deaths,population
FROM CovidDeath 
WHERE continent IS NOT NULL
ORDER BY location, "date";

--looking at total cases vs total deaths
--total possiblilty of dying in India
SELECT location,"date",total_cases,total_deaths,ifnull(((total_deaths/total_cases)*100),0) AS DeathPercentage
FROM CovidDeath 
WHERE location = "India" AND continent IS NOT NULL
ORDER BY location, "date";

--looking at total cases vs population
--total possibility of getting covid
SELECT location,"date",population,total_cases,ifnull(((total_cases/population)*100),0) AS AffectedPercentage
FROM CovidDeath 
WHERE location = "India" AND continent IS NOT NULL
ORDER BY location, "date";

--countries with highest infect rate compared with population
SELECT location,population,max(total_cases) AS HighestInfected ,(total_cases/population)*100 AS AffectedRate
FROM CovidDeath 
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY affectedrate DESC,location,population;

--showing highest  highest death count for countries
SELECT location,max(total_deaths) AS HighestDeath,
FROM CovidDeath 
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestDeath DESC;


--showwing the death count for continents
SELECT location,max(total_deaths) AS HighestDeath
FROM CovidDeath 
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeath DESC;

--Global Data
SELECT "date", sum(new_cases_smoothed) AS Cases,sum(new_deaths_smoothed) AS Deaths,(sum(new_deaths_smoothed)/sum(new_cases_smoothed))*100 AS DeathPercentage
FROM CovidDeath 
WHERE continent IS NOT NULL
GROUP BY "date"
ORDER BY "date";

--looking at the total population vs vaccination

SELECT death.continent,death.location,"death"."date",death.population,vaccine.new_vaccinations
,sum( vaccine.new_vaccinations ) over (partion BY death.location ORDER BY death.location, "death"."date") AS RollingcountofPeopleVaccinations
FROM CovidDeath death
JOIN CovidVaccine vaccine 
ON death.location = vaccine.location
AND "death"."date" = "vaccine"."date"
WHERE continent IS NOT NULL
ORDER BY death.location,"death"."date";



--Use CTE

with popuvaci(continent,location,"date",population,new_vaccinations,RollingcountofPeopleVaccinations)

AS
(
SELECT death.continent,death.location,"death"."date",death.population,vaccine.new_vaccinations
,sum( vaccine.new_vaccinations ) over (partion BY death.location ORDER BY death.location, "death"."date") AS RollingcountofPeopleVaccinations
FROM CovidDeath death
JOIN CovidVaccine vaccine 
ON death.location = vaccine.location
AND "death"."date" = "vaccine"."date"
WHERE continent IS NOT NULL;
)
SELECT *, (RollingcountofPeopleVaccinations/population)*100
FROM popuvaci;


---TEMP TABLE 
DROP TABLE IF EXISTS #PercentagePopulationVaccinated;
CREATE TABLE #PercentagePopulationVaccinated
(
continent VARCHAR(255),
location VARCHAR(255),
"date" datetime,
population NUMBER,
new_vaccinations NUMBER,
RollingcountofPeopleVaccinations NUMBER


INSERT INTO #PercentagePopulationVaccinated
SELECT death.continent,death.location,"death"."date",death.population,vaccine.new_vaccinations
,sum( vaccine.new_vaccinations ) over (partion BY death.location ORDER BY death.location, "death"."date") AS RollingcountofPeopleVaccinations
FROM CovidDeath death
JOIN CovidVaccine vaccine 
ON death.location = vaccine.location
AND "death"."date" = "vaccine"."date";
--where continent is not NULL
--order by death.location,"death"."date";

)
SELECT *, (RollingcountofPeopleVaccinations/population)*100
FROM #PercentagePopulationVaccinated; 

---Creating view  to store data for later visulization

CREATE VIEW DeathCountByContinents AS
SELECT location,max(total_deaths) AS HighestDeath
FROM CovidDeath 
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeath DESC;

SELECT * FROM DeathCountByContinents;

CREATE VIEW PercentagePeopleVaccination AS
SELECT death.continent,death.location,"death"."date",death.population,vaccine.new_vaccinations
--,sum( vaccine.new_vaccinations ) over (partion BY death.location ORDER BY death.location, "death"."date") As RollingcountofPeopleVaccinations
FROM CovidDeath death
JOIN CovidVaccine vaccine 
ON death.location = vaccine.location
AND "death"."date" = "vaccine"."date"
--where continent is not NULL;
--order by death.location,"death"."date";























