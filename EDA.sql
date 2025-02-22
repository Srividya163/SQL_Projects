-- Exploratory Data Analysis
select * from layoffs_staging2;

select max(total_laid_off)
from layoffs_staging2;

select max(percentage_laid_off)
from layoffs_staging2;

-- check the which country got more layoffs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- check by date
select YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by YEAR(`date`)
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

select * from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc;

select * from layoffs_staging2
where percentage_laid_off=1
order by funds_raised_millions desc;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- check date range lower to higher
select MiN(`date`), max(`date`)
from layoffs_staging2;

-- check the layoffs count by industry
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select company,avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select substring(`date`,6,2) as `month` , sum(total_laid_off)
from layoffs_staging2
where substring(`date`,6,2) is not null
group by `month`
order by 2 desc;

select substring(`date`,1,7) as `month` , sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

with Rolling_total as
(
select substring(`date`,1,7) as `month` , sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month` ,total_off, sum(total_off) over(order by `month`) as rolling_total
from Rolling_Total;

select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

with Company_year (company, years, total_laid_off) 
as(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
)
,Company_year_rank as(select *,
dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
)
select * from Company_year_rank
where Ranking <=5;
