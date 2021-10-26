
-- All death data, sorted

Select *
From PortfolioProject..CovidDeaths
Order by 3,4



-- All confirmed death data, without full continents, sorted

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4



-- Looking at when confirmed deaths first started out per country

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null AND total_deaths is not null
order by 1,2



-- Iraq confirmed cases, deaths, and their related percentage

Select Location, Date, total_cases as TotalCases,total_deaths as TotalDeaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Iraq'
and continent is not null AND total_deaths is not null
order by 1,2



-- Infected people as percentage per country

Select Location, Date, Population, total_cases as TotalCases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2



-- Countries with highest infection percentage

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- Daily updated infected people as percentage for Iraq

Select Location, Date, Population, total_cases as TotalCases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like 'iraq'
group by location, date, population, total_cases
order by 1,2




-- Total death count by country, highest to lowest

Select Location, MAX(convert(int,Total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc



-- total death count per continent, highest to lowest

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Total cases vs Total deaths percentage

Select SUM(new_cases) as TotalCases, SUM(convert(int, new_deaths)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2



-- Population vs Daily New Vaccinations as a rolling count

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as float)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2,3



-- CTE: Population vs new vaccinations, rolling vaccinations, and rolling vaccination percentage

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From PopvsVac



-- Temp Table: Population vs new vaccinations, rolling vaccinations, and rolling vaccination percentage

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(float,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From #PercentPopulationVaccinated



-- create a view from a cte

use [PortfolioProject]

Go

Create View PopvsVacCTE as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null



-- create view from a temp table

Use PortfolioProject

Go

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
