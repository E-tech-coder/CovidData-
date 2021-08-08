-- Looking at total cases and total deaths
-- Shows the liklihood of dying if infected in your country

SELECT location,date, population, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidData..CovidDeaths
Where location like '%china%'
Order by 1, 2 DESC

-- Looking at Total cases and Population

SELECT location,date, population, total_cases, total_deaths, (total_deaths/population)*100 AS ContractedPercentage
FROM CovidData..CovidDeaths
Where location like '%states%'
Order by 1, 2 DESC

-- Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestIfectionCount, 
	MAX((total_deaths/population)*100) AS InfectionPercentage
FROM CovidData..CovidDeaths
-- Where location like '%states%'
Group by location, population
Order by InfectionPercentage DESC

-- Looking at countries with the highest Death Count per population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidData..CovidDeaths
-- Where location like '%states%'
WHERE continent is not null
Group by location
Order by TotalDeathCount DESC

-- Now break things down by continent

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidData..CovidDeaths
-- Where location like '%states%'
WHERE continent is null
Group by location
Order by TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidData..CovidDeaths
-- Where location like '%states%'
WHERE continent is not null
Group by continent
Order by TotalDeathCount DESC

-- global numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths , 
		(SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidData..CovidDeaths
-- Where location like '%states%'
Where  continent is not null
Group by date
Order by date DESC

-- join the two tables

select *
from CovidData..CovidVaccinations vac
Join CovidData..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at the total population and Vacciations

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
from CovidData..CovidVaccinations vac
Join CovidData..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by continent, dea.date DESC

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, CAST(dea.Date AS date)) AS RollingPeopleVaccinated
from CovidData..CovidVaccinations vac
Join CovidData..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	AND vac.new_vaccinations is not null

-- Use CTE

with PopvsVac AS 
(
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, CAST(dea.Date AS date)) AS RollingPeopleVaccinated
from CovidData..CovidVaccinations vac
Join CovidData..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	AND vac.new_vaccinations is not null 
)
select *, (RollingPeopleVaccinated/population)*100 AS VaccinationRate
From PopvsVac
Order by date DESC

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercetagePopulationVaccinated
Create Table #PercetagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercetagePopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, CAST(dea.Date AS date)) AS RollingPeopleVaccinated
from CovidData..CovidVaccinations vac
Join CovidData..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	AND vac.new_vaccinations is not null 

select *, (RollingPeopleVaccinated/population)*100 AS VaccinationRate
From #PercetagePopulationVaccinated
Order by date DESC


-- Creating View to store data for later visualizations

 Create View PercentagePeopleVaccinated as
select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, CAST(dea.Date AS date)) AS RollingPeopleVaccinated
from CovidData..CovidVaccinations vac
Join CovidData..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	AND vac.new_vaccinations is not null 
