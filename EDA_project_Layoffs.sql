-- Exploratory Data Analysis

-- Work quite a bit with total_laid_off, the percentage_laid_off not as usefull as dont have an actual start number of employees
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- 1 equals 100% therefore total company closed
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1 
ORDER BY total_laid_off DESC;

-- find start and end date of data (2020-03-11 to 2023-03-06)
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Group by company name and sum the layoffs and show in desc order
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'OLX%';

-- Group by industry and sum the layoffs and show in desc order
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Group by country and sum the layoffs and show in desc order
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Look at layoffs over years by country
SELECT YEAR(`date`), country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 2, 1
ORDER BY 2 ;

-- Only 3 months in 2023 data yet already so high
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

-- Rolling SUM of layoffs based off month
WITH Rolling_Total AS (
	SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
	GROUP BY `MONTH`
	ORDER BY 1 ASC
)
SELECT `MONTH`,
	total_off,
    SUM(total_off) OVER(
	ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Rolling total with company per year - top 5 ranking

WITH Company_Year (company, years, total_laid_off) AS (
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
),
	Company_Year_Rank AS (
    	SELECT *, DENSE_RANK() OVER (
		PARTITION BY years
		ORDER BY total_laid_off DESC
	) AS Ranking
	FROM Company_Year
	WHERE years IS NOT NULL
    )
    SELECT *
    FROM Company_Year_Rank
    WHERE Ranking <= 5;
;

SELECT *
FROM layoffs_staging2;
