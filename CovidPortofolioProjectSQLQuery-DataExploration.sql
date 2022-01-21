select * from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

-- select data that we're going to use
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at Total Cases Vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, 
(convert(float,total_deaths) / convert(float,total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%indonesia%'
order by 1,2

-- looking at Total Cases Vs Population
-- shows what percentage of population got covid
select location, date, population, total_cases, (convert(float,total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((convert(float,total_cases)/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%indonesia%'
group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population
select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Break things down by continent

select location, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

-- showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select date, SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, 
	SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, 
	SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2




select *
from PortfolioProject..CovidVaccinations$


select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population Vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac




-- Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




-- Creating view to store data for later visualizations
drop view if exists PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated