/* #1. What are the top-paying data analyst jobs?**

- Identify the top 10 highest-paying Data Analyst roles that are available 
remotely.
- Focuses on job postings with specified salaries.
- Why? Aims to highlight the top-paying opportunities for Data Analysts, 
offering insights into employment options and location flexibility. */

--Top 10 highest paying data analyst roles that are either remote or local
SELECT 
    job_id,
    job_title_short,
    job_location,
    salary_year_avg,
    name AS company_name
FROM 
    job_postings_fact
JOIN 
    company_dim
ON 
    job_postings_fact.company_id = company_dim.company_id
WHERE 
    job_title_short = 'Data Analyst'  
AND 
    job_location = 'Anywhere'
AND 
    salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC
LIMIT 10;

/* #2. What are the top-paying data analyst jobs, and what skills are 
required?** 
- Identify the top 10 highest-paying Data Analyst jobs and the specific skills
required for these roles.
- Filters for roles with specified salaries that are remote.
- Why? It provides a detailed look at which high-paying jobs demand certain 
skills, helping job seekers understand which skills to develop that align with
top salaries. */ 

-- Gets the top 10 paying Data Analyst jobs 

WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg
    FROM
        job_postings_fact
    WHERE
        job_title_short = 'Data Analyst'
				AND salary_year_avg IS NOT NULL
        AND job_location = 'Anywhere'
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)
-- Skills required for data analyst jobs
SELECT
    top_paying_jobs.job_id,
    job_title,
    salary_year_avg,
    skills
FROM
    top_paying_jobs
	INNER JOIN
    skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
	INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC


/* #3. What are the most in-demand skills for data analysts?**

- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, 
providing insights into the most valuable skills for job seekers. */


-- Identifies the top 5 most demanded skills for Data Analyst job postings
SELECT
  skills_dim.skills,
  COUNT(skills_job_dim.job_id) AS demand_count
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  -- Filters job titles for 'Data Analyst' roles
  job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;

/* #4 What are the top skills based on salary?** 

- Look at the average salary associated with each skill for Data Analyst 
positions.
- Focuses on roles with specified salaries, regardless of location.
- Why? It reveals how different skills impact salary levels for Data Analysts 
and helps identify the most financially rewarding skills to acquire or improve. */

-- Finds average salary per skill for Data Analyst jobs

SELECT 
   AVG(job_postings_fact.salary_year_avg) AS avg_salary, -- average salary for the skill
   skills_dim.skills 
FROM 
   job_postings_fact
INNER JOIN 
   skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN 
   skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
   job_postings_fact.job_title_short = 'Data Analyst'
AND 
   job_postings_fact.salary_year_avg IS NOT NULL
GROUP BY 
   skills_dim.skills
ORDER BY 
   avg_salary DESC




** #5 What are the most optimal skills to learn (aka it’s in high 
demand and a high-paying skill) for a data analyst?** 

- Identify skills in high demand and associated with high average 
salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security (high demand) and 
financial benefits (high salaries), offering strategic insights for 
career development in data analysis */

-- CTE: Count how many remote Data Analyst jobs require each skill

WITH skills_demand AS (
  SELECT 
    COUNT(job_postings_fact.job_id) AS total_jobs,
    skills_dim.skill_id,
    skills_dim.skills         
  FROM 
    skills_dim
  JOIN 
   skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
  JOIN 
   job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
  WHERE 
   job_title_short = 'Data Analyst'
  AND 
   job_work_from_home IS TRUE 
  GROUP BY 
   skills_dim.skill_id
)
,
-- CTE: Find the average salary associated with each skill
highest_avg_salary AS (
  SELECT 
    skills_dim.skill_id,
    AVG(salary_year_avg) AS average_salary
  FROM 
    job_postings_fact
  JOIN 
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  JOIN 
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
  WHERE 
    job_title_short = 'Data Analyst'
  GROUP BY 
    skills_dim.skill_id

)
-- Combine demand + salary to identify "optimal" skills

  SELECT  
    skills_demand.skill_id,
    skills_demand.skills,
    skills_demand.total_jobs,
    highest_avg_salary.average_salary
  FROM 
    skills_demand
  JOIN 
    highest_avg_salary ON skills_demand.skill_id = highest_avg_salary.skill_id
