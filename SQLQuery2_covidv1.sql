SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY location
SELECT *
FROM PortfolioProject.dbo.CovidVaccines
ORDER BY location

--We Query Data of interest

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
order by location, date


-- Total Death rate to Total Cases percentage for the UK
-- T0 AVOID a divide by zero error message a CASE STATEMENT WILL BE USED

SELECT location, date, total_cases, total_deaths,

ROUND(CASE 
     WHEN total_cases = 0 THEN NULL 
	  ELSE 100*(total_deaths/total_cases) END,2) AS death_rate_percentage
From PortfolioProject.dbo.CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY  location, date

--Total death toll

SELECT SUM(CAST(total_deaths AS INT)) AS uk_death_tol FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United Kingdom'

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in the UK

Select location, date, Population, total_cases, ROUND((total_cases/population)*100,3) as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
WHERE location like '%kingdom%'
order by location, date

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 AS percent_population_infected
From PortfolioProject.dbo.CovidDeaths
GROUP BY population, location
ORDER BY percent_population_infected DESC

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where location like '%kingdom%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 

--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

