SELECT *
FROM CovidDeaths1
Order By 3

SELECT*
FROM CovidVaccinations2
Order By 3

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths1
Order By 1,2

-- Look at Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as Deathspercentage
from CovidDeaths1
Where location like '%states%'
Order By 1

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

Select continent, location, date, total_cases,population,(total_cases*1.0/population)*100 as DeathsPercentage
from CovidDeaths1
Where location like '%states%'
Order By 1

-- Looking at countries with highest infection rate compare to population

Select continent, location, population, MAX(total_cases) as HighestInfectionCount,
MAX ((total_cases*1.0/population))*100 as PercentpopulationInfected
from CovidDeaths1
--Where location like '%states%'
Group by location, population, continent
Order By PercentpopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select continent location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths1
--Where location like '%states%'
Where continent is not null
Group by continent
Order By TotalDeathCount desc

-- Let's Break Things Down By Continent 
-- Showing Continents With the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths1
--Where location like '%states%'
Where continent is not null
Group by continent
Order By TotalDeathCount desc

-- Global Nembers By Date

Select date, SUM(New_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(New_deaths*1.0)/SUM(New_cases)*100 as Deathspercentage
from CovidDeaths1
--Where location like '%states%'
Where continent is not null
Group by date
Order By 1

-- Global Number

Select SUM(New_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(New_deaths*1.0)/SUM(New_cases)*100 as Deathspercentage
from CovidDeaths1
--Where location like '%states%'
Where continent is not null
--Group by date
Order By 1

-- CovidVaccination Scripts 

SELECT* 
From CovidDeaths1 dea
Join CovidVaccinations2 vac
    On dea.location = vac.location
	and dea.date = vac.date
	Order by 1

-- Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated,
--, (RollingPoepleVaccinated/Population)*100
From CovidDeaths1 dea
Join CovidVaccinations2 vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2

-- USE CTE POPvsVAC

With PopvsVac (continent, location, Date, Population, new_vaccination, RollingPeopleVaccinated) 
as
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPoepleVaccinated/Population)*100
From CovidDeaths1 dea
Join CovidVaccinations2 vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2
)
Select *, (RollingPeopleVaccinated*1.0/Population)*100
From PopvsVac


-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population int, New_vaccination int, 
RollingPeopleVaccinated int)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPoepleVaccinated/Population)*100
From CovidDeaths1 dea
Join CovidVaccinations2 vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2

Select *, (RollingPeopleVaccinated*1.0/Population)*100
From #PercentPopulationVaccinated

-- Create View to store data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPoepleVaccinated/Population)*100
From CovidDeaths1 dea
Join CovidVaccinations2 vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2

Select*
From PercentPopulationVaccinated
