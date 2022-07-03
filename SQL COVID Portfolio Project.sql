Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeath
order by 1,2

--Looking at total cases bs total death

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From CovidDeath
Where location like '%Finland%'
order by 1,2


--Looking at total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 PopulationInfected
From CovidDeath
Where location like '%Finland%'
order by 1,2

--Looking at countries with heighest infection rates compared to population

Select location, population, Max(total_cases) HighInfectionCount, Max((total_cases/population))*100 PopulationInfected
From CovidDeath
Where continent is not Null
Group by location, population
Order by PopulationInfected desc


--Showing countries with the hghest DeathCount per Population

Select location, MAX(cast(total_deaths as int)) TotalDeathCount
From CovidDeath
Where continent is not Null
Group by location
Order by TotalDeathCount desc

--Break down by continent


Select continent, MAX(cast(total_deaths as int)) TotalDeathCount
From CovidDeath
Where continent is not Null
Group by continent
Order by TotalDeathCount desc


/* Global Numbers*/

Select date, SUM(new_cases) as totalcases, SUM(cast (new_deaths as int)) as totaldeath
,SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathGlobal
From CovidDeath
--Where location like '%Finland%'
where continent is not null
Group by date

-- Looking at Total Population vs Vaccinations

Select cd.location, cd.continent, cd.date, cd.population, vc.new_vaccinations,
SUM(convert(bigint, vc.new_vaccinations)) over (Partition by cd.location      ---SUM(cast(vc.new_vaccinations as bigint)) over (Partition by cd.location) 
order by cd.date) as RollingCountVaccinations     
From [Portfolio Project]..CovidDeath cd
Join [Portfolio Project]..Vaccinations vc
	ON cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null
order by 1,3

--USE CTE


WITh PopulationVsVaccinations(Location, Continent, Date, Population, New_Vaccinations, RollingCountVaccinations)
as
(
Select cd.location, cd.continent, cd.date, cd.population, vc.new_vaccinations,
SUM(convert(bigint, vc.new_vaccinations)) over (Partition by cd.location      ---SUM(cast(vc.new_vaccinations as bigint)) over (Partition by cd.location) 
order by cd.date) as RollingCountVaccinations     
From [Portfolio Project]..CovidDeath cd
Join [Portfolio Project]..Vaccinations vc
	ON cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null
--order by 1,3
)
Select *, (RollingCountVaccinations/Population)*100 Vaccination
From PopulationVsVaccinations

--TEMP TABLE


--Drop Table if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
Select cd.location, cd.continent, cd.date, cd.population, vc.new_vaccinations,
SUM(convert(bigint, vc.new_vaccinations)) over (Partition by cd.location      ---SUM(cast(vc.new_vaccinations as bigint)) over (Partition by cd.location) 
order by cd.date) as RollingCountVaccinations     
From [Portfolio Project]..CovidDeath cd
Join [Portfolio Project]..Vaccinations vc
	ON cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null
--order by 1,3
Select *, (RollingCountVaccinations/Population)*100
From #PercentPopulationVaccinated

---Creating a view to store data for later visualization

Create View PercentPopulationVaccinated as
Select cd.location, cd.continent, cd.date, cd.population, vc.new_vaccinations,
SUM(convert(bigint, vc.new_vaccinations)) over (Partition by cd.location     
order by cd.date) as RollingCountVaccinations     
From [Portfolio Project]..CovidDeath cd
Join [Portfolio Project]..Vaccinations vc
	ON cd.location = vc.location
	and cd.date = vc.date
where cd.continent is not null
--order by 1,3

  Select *
  From PercentPopulationVaccinated