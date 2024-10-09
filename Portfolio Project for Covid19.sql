SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not Null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--Order by 3,4

SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM PortfolioProject..CovidDeaths
Where continent is not Null
 Order by 1,2

 -- total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where Location like '%nigeria%'
 Order by 1,2

 -- total cases vs Population

 SELECT location, date,  Population, total_cases, (CONVERT(float, total_cases)/NULLIF(CONVERT(float, Population),0))*100 as PesentPopulationInfectioned
FROM PortfolioProject..CovidDeaths
Where Location like '%nigeria%'
 Order by 1,2


 --Countries with Highest infection Rates vs Population

  SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(float, Population),0))*100 as PesentPopulationInfectioned
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Group by location, Population
 Order by PesentPopulationInfectioned desc

 -- Showing countries with highest death count per population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Where continent is not Null
Group by location
 Order by TotalDeathCount desc


 -- BREAKING THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Where continent is Null
Group by location
Order by TotalDeathCount desc


 --Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Where continent is not Null
Group by continent
 Order by TotalDeathCount desc


-- BREAKING GLOBAL NUMBERS


SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, Nullif(SUM(new_deaths),0)/Nullif(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Where continent is not null
Group by date
 Order by 1,2

 -- WORLD TOTAL

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, Nullif(SUM(new_deaths),0)/Nullif(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Where continent is not null
--Group by date
 Order by 1,2

 -- Looking at Total Population vs Vaccinatio

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 FROM PortfolioProject..CovidVaccination vac
   join PortfolioProject..CovidDeaths dea
   on vac.location = dea.location
   and vac.date = dea.date
   Where dea.continent is not null
   order by 2,3

   --Getting the RollingPeoplevaccinated

   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
 FROM PortfolioProject..CovidVaccination vac
   join PortfolioProject..CovidDeaths dea
   on vac.location = dea.location
   and vac.date = dea.date
   Where dea.continent is not null
   order by 2,3

   -- Pop/Roll Using CTE

   With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeoplevaccinated)
   as
   (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
 FROM PortfolioProject..CovidVaccination vac
   join PortfolioProject..CovidDeaths dea
   on vac.location = dea.location
   and vac.date = dea.date
   Where dea.continent is not null
   --order by 2,3
   )
   SELECT *, (RollingPeoplevaccinated/population)*100 as PercentagePeopleVacPerDay
   FROM PopvsVac



   --Temp Table

 DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
   (
   continent nvarchar(255),
   location nvarchar(255),
   Date datetime,
   Population numeric,
   New_vaccination numeric,
   RollingPeopleVaccinated numeric
   )

   insert into #PercentPopulationVaccinated
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
 FROM PortfolioProject..CovidVaccination vac
   join PortfolioProject..CovidDeaths dea
   on vac.location = dea.location
   and vac.date = dea.date
   Where dea.continent is not null
   --order by 2,3

   SELECT *, (RollingPeoplevaccinated/population)*100 as PercentagePeopleVacPerDay
   FROM #PercentPopulationVaccinated


   --MY VIEWS 

   CREATE VIEW PercentPopulationVaccinated as
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
 FROM PortfolioProject..CovidVaccination vac
   join PortfolioProject..CovidDeaths dea
   on vac.location = dea.location
   and vac.date = dea.date
   Where dea.continent is not null
   --order by 2,3

CREATE VIEW TotalDeathCount as
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Where continent is not Null
Group by continent
 --Order by TotalDeathCount desc


 CREATE VIEW PesentPopulationInfectioned as
 SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(float, Population),0))*100 as PesentPopulationInfectioned
FROM PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Group by location, Population
 --Order by PesentPopulationInfectioned desc