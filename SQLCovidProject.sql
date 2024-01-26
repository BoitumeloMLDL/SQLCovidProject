  Select *
  from PortfolioProject..covidDeaths
  where continent is not null
  order by 3,4

  -- Death percentage in Africa

  Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  from PortfolioProject..covidDeaths
  where location like '%africa%'
  order by 1,2

  -- Infection rate in Africa

  Select continent, location, date, population, total_cases, total_deaths, (total_cases/population)*100 as InfectionRate
  from PortfolioProject..covidDeaths
  where location like '%africa%' and continent like '%africa%'
  order by 1,2
  
  -- Infection rate in Africa showing Highest Infection Count per location (country) in descending order

  Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectionRate
  from PortfolioProject..covidDeaths
  where location like '%africa%' and continent like '%africa%'
  GROUP BY location, population
  order by InfectionRate DESC

  -- Maximum total deaths per location (country)

  Select location, MAX(total_deaths) as TotalDeathCount
  from PortfolioProject..covidDeaths
  where continent is not null
  GROUP BY location
  order by TotalDeathCount DESC

   -- Maximum total deaths per continent

  Select continent, MAX(total_deaths) as TotalDeathCount
  from PortfolioProject..covidDeaths
  where continent is not null 
  GROUP BY continent
  order by TotalDeathCount DESC

  -- Death percentage as per the date  

  Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, 
  SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
  from PortfolioProject..covidDeaths
  where continent is not null 
  GROUP BY date
  order by 1,2 

  --Join covidDeaths with covidVaccines Tables on Location and Date
  
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) as VaccinationCount
  from PortfolioProject..covidDeaths dea
  Join PortfolioProject..covidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3


  --USE Common Table Expression

  WITH PopvsVac (continent, location, date, population, new_vaccinations, VaccinationCount)
  as
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) as VaccinationCount
  from PortfolioProject..covidDeaths dea
  Join PortfolioProject..covidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  Select *, (VaccinationCount/population)*100 as VacCountvsPopulation
  from PopvsVac


  --Create a Temporary Table

  DROP TABLE IF EXISTS #PercentagePopulationVaccinated
  Create Table #PercentagePopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric, 
  New_vaccinations numeric, 
  VaccinationCount numeric
  )

  Insert into #PercentagePopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) as VaccinationCount
  from PortfolioProject..covidDeaths dea
  Join PortfolioProject..covidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

  Select *, (VaccinationCount/population)*100 as VaccinationRate
  from #PercentagePopulationVaccinated


  --CREATE VIEW TO STORE DATA FOR VISUALISATIONS 

  CREATE VIEW PercentagePopulationVaccinated AS
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) as VaccinationCount
  from PortfolioProject..covidDeaths dea
  Join PortfolioProject..covidVaccines vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

   CREATE VIEW DeathPercentage AS
  Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, 
  SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
  from PortfolioProject..covidDeaths
  where continent is not null 
  GROUP BY date
  --order by 1,2 
 
 CREATE VIEW InfectionPercentage AS
 Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as InfectionPercentage
  from PortfolioProject..covidDeaths
  --where location like '%africa%' and continent like '%africa%'
  GROUP BY location, population
  --order by InfectionPercentage DESC

  CREATE VIEW TotalDeathCount AS
  Select continent, sum(convert(float,new_deaths)) as TotalDeathCount
  from PortfolioProject..covidDeaths
  where continent is not null 
  GROUP BY continent
  --order by TotalDeathCount DESC

  CREATE VIEW PercentageDiedPerContinent AS
  SELECT continent, sum(convert(float,new_cases)) as New_Cases, sum(convert(float, new_deaths)) as New_Deaths, 
  (sum(convert(float,new_deaths))/sum(convert(float, new_cases)))*100 as PercentageDiedPerContinent
  from PortfolioProject..covidDeaths
  where continent is not null
  GROUP BY continent