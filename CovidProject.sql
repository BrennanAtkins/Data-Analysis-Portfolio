-- Select data that I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying to Covid within a specific country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looking at Total Cases vs Population
-- Shows percentage of country's population that contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate relative to population

SELECT location, MAX(total_cases) AS MaxInfectionCount, population, MAX((total_cases/population))*100 AS Percentage
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY Percentage DESC;

-- Looking at countries with highest death count

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Death count broken down by continent

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global death percentage

SELECT SUM(new_cases) AS NewCases, SUM(CAST(new_deaths as int)) AS NewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Broken down by date

SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths as int)) AS NewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Comparing total population with vaccinated population by date with rolling total

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
d.date) AS VaxToDate
FROM CovidProject..CovidDeaths AS d
JOIN CovidProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE

With VaxRate (continent, location, date, population, new_vaccinations, VaxToDate)
AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
d.date) AS VaxToDate
FROM CovidProject..CovidDeaths AS d
JOIN CovidProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL)

SELECT *, (VaxToDate/Population)*100
FROM VaxRate;

-- Creating view to store data for later visualization

CREATE VIEW VaxRate AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
d.date) AS VaxToDate
FROM CovidProject..CovidDeaths AS d
JOIN CovidProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL