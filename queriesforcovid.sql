select *
from portfolioProject..['covid death$']
where continent is not null
order by 3,4

--select *
--from portfolioProject..[covid_vac$]
--order by 3,4

--select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..['covid death$']
order by 1, 2


--Looking at the total cases vs total deaths
--show the likelyhood of dying if you contracr covid in your country.
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from portfolioProject..['covid death$']
where location like '%states%'
order by 1, 2
-- looking at the total cases vs population

select Location, date, total_cases, population, (total_cases/population)*100 as percentPeopleInfected
from portfolioProject..['covid death$']
where location like '%states%'
order by 1, 2

--counties with highest infection rate compared to population

select Location, population, MAX(total_cases) as highestInfection, MAX((total_cases/population))*100 as percentPeopleInfected
from portfolioProject..['covid death$']
--where location like '%states%'
group by Location, population
order by percentPeopleInfected desc

-- this is showing the countries with the higest death count per population
select Location, MAX(cast(Total_deaths as int)) as DeathCountCount
from portfolioProject..['covid death$']
--where location like '%states%'
where continent is not null
group by Location
order by DeathCountCount desc

--lets break things down by continent--showing contients with highest death count

-- this is showing the countries with the higest death count per population
select continent, MAX(cast(Total_deaths as int)) as DeathCountCount
from portfolioProject..['covid death$']
--where location like '%states%'
where continent is not null
group by continent
order by DeathCountCount desc

--GLOBAL NUMBERS


select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
from portfolioProject..['covid death$']
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2

--looking at the total population vs vacctinations

with PopvsVac(continent, Location, Date, Population, New_Vaccinations, rollingPeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.Location Order by dea.location,
dea.Date) as rollingPeoplevaccinated
--, (rollingPeoplevaccinated/population)*100
from portfolioProject..['covid death$'] dea
Join portfolioProject..covid_vac$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 1,2,3
 )
 select *, (rollingPeoplevaccinated/Population)*100
 from PopvsVac
 --USE CTE

 --TEMP TABLE
 drop table if exists #PrecentPopulationVaccinated
 CREATE TABLE #PrecentPopulationVaccinated

 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 New_vaccinations numeric,
 rollingPeoplevaccinated numeric,
 )

 insert into #PrecentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.Location Order by dea.location,
dea.Date) as rollingPeoplevaccinated
--, (rollingPeoplevaccinated/population)*100
from portfolioProject..['covid death$'] dea
Join portfolioProject..covid_vac$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select *, (rollingPeoplevaccinated/population)*100
 from #PrecentPopulationVaccinated


 --view for future visualizations

 create view PrecentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.Location Order by dea.location,
dea.Date) as rollingPeoplevaccinated
--, (rollingPeoplevaccinated/population)*100
from portfolioProject..['covid death$'] dea
Join portfolioProject..covid_vac$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3