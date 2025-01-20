select * from layoffs1;

-- creating another table as staging to do all the cleaning process on this table instead main table
CREATE TABLE layoff_staging
like layoffs1;
INSERT layoff_staging
select *
from  layoffs1;

-- 1.Remove Duplicates 
select * from layoff_staging;

select *,
	row_number() over(
	partition by company,industry,total_laid_off,percentage_laid_off,`date`) as row_num
from layoff_staging;
-- there are the ones we want to delete which  row_num greater than 2
with duplicate_cte as 
(
	select *,
	row_number() over(
	partition by company,location,total_laid_off,percentage_laid_off,funds_raised_millions,`date`,stage,country) as row_num
	from layoff_staging
)
select *
from duplicate_cte
where row_num>1;

select * from layoff_staging
where company='Casper';


-- we one solution that we can delete the rows which is over 2 by crreating new column and row numbers in .
-- create another table for duplicate deletion
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` Int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO layoff_staging2
select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoff_staging;

select * from layoff_staging2 
where row_num>1;

DELETE
from layoff_staging2 
where row_num>1;

SET SQL_SAFE_UPDATES=1;

-- 2.Standardizing data
-- if we look at some individuals we have some null and empty rows
select * from layoff_staging2;

select company, TRIM(company) 
from layoff_staging2;

UPDATE layoff_staging2
set company=TRIM(company);


-- check the industry column
select distinct industry from layoff_staging2
order by 1;

-- I observed that crypto has different variations so we need to standardize it.
select * from layoff_staging2
where industry LIKE 'crypto';

update layoff_staging2
set industry='crypto'
where industry like 'crypto%';

-- And standardize united states into similar format.
select country from layoff_staging2
where country = 'united states';

update layoff_staging2
set country=trim(trailing ',' from country)
where country like 'united states%';


-- change data type of date and change into similar date formates. used 'str_to_date' to change the datatype.
select `date` from layoff_staging2;

select `date`,
STR_TO_DATE(`date`, '%m-%d-%Y')
from layoff_staging2;
-- observed that in date columns dates are in different formates so changing them into  similar formate.
update layoff_staging2
set `date`= date_format(str_to_date(`date`, '%m/%d/%Y'), '%m-%d-%Y')
where `date` Like '%/%';

select `date`
from layoff_staging2
where `date` like '%/%' and str_to_date(`date`, '%m/%d/%Y') is null;

UPDATE layoff_staging2
SET `date`=str_to_date(`date`, '%m-%d-%Y');

ALTER TABLE layoff_staging2
MODIFY column `date` DATE;

-- check empty space or nulls
select * 
from layoff_staging2
where total_laid_off is NULL and
percentage_laid_off is NUll ;

select * from layoff_staging2
where industry is NUll
or industry='';

select * from layoff_staging2
where company='Airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all
select t1.industry,t2.industry
from layoff_staging2 t1
join layoff_staging2 t2 on t1.company =t2.company
where (t1.industry is null or t2.industry='')
and t2.industry is not null;

-- change all empty rows into nulls
update layoff_staging2
set industry=null 
where industry='';

select * from layoff_staging2 t1
join layoff_staging2 t2 on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t2.industry is not null;

update layoff_staging2 t1
join layoff_staging2 t2 on 
t1.company=t2.companyS
set t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null;

select * from layoff_staging2
where company='Airbnb';

-- 3.check and delete nulls in laid offs
select * 
from layoff_staging2
where total_laid_off is NULL and
percentage_laid_off is NUll ;

DELETE
from layoff_staging2
where total_laid_off is NULL and
percentage_laid_off is NUll ;

select * from layoff_staging2;

-- 4.delete unwanted columns
ALTER TABLE layoff_staging2
DROP column row_num;











 




