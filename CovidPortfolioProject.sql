--select *
--from PortfolioProject.dbo.CovidDeaths
--order by 3,4 

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4 

--Select data that we are going to be using 

--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject.dbo.CovidDeaths
--order by 1,2

--looking at total cases vs total deaths
------show likelehood of dying of your get infected with COVID-19 in Nigeria
--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject.dbo.CovidDeaths
--where location like '%nigeria%'
--order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got infected with Covid 19
--select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
--from PortfolioProject.dbo.CovidDeaths
----where location like '%states%'
--order by 1,2

--Looking at Countries with highest infection rate compared to population 
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
    PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


-- LET'S ANALYSE BY CONTINENT 
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
select date, SUM(new_cases) as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPerecentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

--USE CTE
WITH PopvsVac  (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
--Looking at Total vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

---Temp Table 

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

---Creating view to store later for data visualizations

create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated