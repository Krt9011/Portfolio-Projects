

select location, date, total_cases,new_cases, total_deaths, population
from ['Covid DEaths$']
order by 1,2

--Lookin at Total cases vs Total Deaths
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases*100) as Death_Percentage
from ['Covid DEaths$'] where location = 'India'
order by 1,2

-- looking at Total Cases VS Population
select location, date, total_cases, total_deaths, population, (total_cases/population*100) as Population_infected
from ['Covid DEaths$'] where location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, max(total_cases) as highest_infectioncount, population, max(total_cases/population*100) as Population_infected
from ['Covid DEaths$'] --where location = 'India'
group by location, population
order by Population_infected desc

--Countries with highest death count per population
select location, max(total_deaths) as highest_deathcount, population, max(total_deaths/population*100) as Death_percentage
from ['Covid DEaths$'] --where location = 'India'
group by location, population
order by Death_percentage desc

select location, Max (cast(Total_deaths as int)) as totalDeathCount
from ['Covid DEaths$']
where continent is null
group by location
order by TotalDeathcount desc

select continent, Max (cast(Total_deaths as int)) as totalDeathCount
from ['Covid DEaths$']
where continent is not null
group by continent
order by TotalDeathcount desc


-- Global Numbers
select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from ['Covid DEaths$'] 
where continent is not null
group by date
order by 1,2

-- Global Numbers
select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from ['Covid DEaths$'] 
where continent is not null
order by 1,2


Select *
from ['Covid DEaths$'] CD
Join ['Covid Vaccination$'] CV
  on CD.location = cv.location
  and CD.date= cv.date



Select CD.continent, CD.location, CD.date, CD.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as rollingvaccination
from ['Covid DEaths$'] CD
Join ['Covid Vaccination$'] CV
  on CD.location = cv.location
  and CD.date= cv.date
Where CD.continent is not null
order by 2,3

--CTE

With PopvsVAc (continent, location, date, population, New_vaccinations, rollingvaccination) as 
(
Select CD.continent, CD.location, CD.date, CD.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as rollingvaccination
from ['Covid DEaths$'] CD
Join ['Covid Vaccination$'] CV
  on CD.location = cv.location
  and CD.date= cv.date
Where CD.continent is not null
)
select *, (rollingvaccination/population*100)
from PopvsVAc

DROP table  if exists #percentpopulationVaccinated
Create table #percentpopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (225),
date datetime,
population numeric,
New_vaccinations numeric,
rollingvaccination numeric
)
Insert into #percentpopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as rollingvaccination
from ['Covid DEaths$'] CD
Join ['Covid Vaccination$'] CV
  on CD.location = cv.location
  and CD.date= cv.date
Where CD.continent is not null

select *, (rollingvaccination/population*100)
from #percentpopulationVaccinated


-- creating view

create view percentpopulationVaccinated as 
Select CD.continent, CD.location, CD.date, CD.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as rollingvaccination
from ['Covid DEaths$'] CD
Join ['Covid Vaccination$'] CV
  on CD.location = cv.location
  and CD.date= cv.date
Where CD.continent is not null


select *
from percentpopulationVaccinated