
--Select * 
--From [Portfolioproject].[dbo].['CovidVaccination$']
--order by 3,4

select *
From [Portfolioproject].dbo.['CovidDeath$']
order by 3,4

Select location, date, total_cases,new_cases, total_deaths, population
From [Portfolioproject].[dbo].['CovidDeath$']
order by 1,2

--Total cases Vs Total death
Select location,date,total_cases,total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From [Portfolioproject].[dbo].['CovidDeath$']
where location like'%States%'
order by 1,2

--My country Total case Vs total death
Select location,date,total_cases,total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From [Portfolioproject].[dbo].['CovidDeath$']
where location like'%Ethiopia%'
order by 1,2

--Total case Vs Population
--total percentage of population affected by covid
Select location,date,total_cases,population,(CAST(total_cases as float)/CAST(population as float))*100 as DeathPercentage
From [Portfolioproject].[dbo].['CovidDeath$']
where location like'%Ethiopia%'
order by 1,2

Select location,date,total_cases,population,(CAST(total_cases as float)/CAST(population as float))*100 as DeathPercentage
From [Portfolioproject].[dbo].['CovidDeath$']
--where location like'%Ethiopia%'
order by 1,2


--Looking for Countries with highest infection rate compared to population 
Select location, Max(total_cases) as HightstInfRate,population,(MAX(CAST(total_cases as float))/Max(CAST(population as float)))*100 as HighestInfectionRate
From [Portfolioproject].[dbo].['CovidDeath$']
--where location like'%Ethiopia%'
Group by population, location
order by HighestInfectionRate desc
--order by 1,2

--Looking for highest death rate per population 
Select location,population, Max(total_deaths) as Maxdeaths, Max((Cast(total_deaths as float)/Cast(total_cases as float)))*100 as HighestDeathRate
From [Portfolioproject].[dbo].['CovidDeath$']
--where location like'%Ethiopia%'
Group by population, location 
order by HighestDeathRate desc


--Showing Contnets with the highest Death rate

Select location, Max(Cast(total_deaths as int)) as TotalDeathCount
From [Portfolioproject].[dbo].['CovidDeath$']
--where location like'%Ethiopia%'
Group by location 
order by TotalDeathCount desc

--Breaking in continents 
Select continent, Max(cast(total_deaths as int)) As TotalDeathCount
From [Portfolioproject].[dbo].['CovidDeath$']
Where continent is not null
Group by continent
order by TotalDeathCount

--Global numbers

Select location,date,total_cases,total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From [Portfolioproject].[dbo].['CovidDeath$']
--where location like'%States%'
Where continent is not null
order by 1,2

-- Total cases and total deaths from all global data
Select Sum(new_cases) as Total_Case,Sum(cast(new_deaths as int)) as Totaldeath, Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage
From [Portfolioproject].[dbo].['CovidDeath$']
--where location like'%States%'
Where continent is not null
--Group by date
order by 1,2


--Looking To Total vaccination Vs Total population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date)
From [Portfolioproject].[dbo].['CovidVaccination$'] vac
join [Portfolioproject].[dbo].['CovidDeath$'] dea
   on dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null and vac.new_vaccinations is not null
order by 1, 2, 3



with popvsvac( continent,location,date,population, new_Vaccinaation,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolioproject].[dbo].['CovidDeath$'] dea
join [Portfolioproject].[dbo].['CovidVaccination$'] vac
   on dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null --and vac.new_vaccinations is not null
--order by  2, 3
)
Select *
From popvsvac

--Select *, (RollingPeopleVaccinated/population)*100
--From popvsavc


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolioproject].[dbo].['CovidDeath$'] dea
join [Portfolioproject].[dbo].['CovidVaccination$'] vac
   on dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null --and vac.new_vaccinations is not null
--order by  2, 3
select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for visualization 
Drop View if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolioproject].[dbo].['CovidDeath$'] dea
join [Portfolioproject].[dbo].['CovidVaccination$'] vac
   on dea.location = vac.location
   and dea.date = vac.date 
where dea.continent is not null --and vac.new_vaccinations is not null
--order by  2, 3

Select * from PercentPopulationVaccinated