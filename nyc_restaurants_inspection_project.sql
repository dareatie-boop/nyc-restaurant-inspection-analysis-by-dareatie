#PRE-QUESTION 1 WHICH VIOLATIONS ARE MOST COMMON
SELECT violation_description, COUNT(*) AS total
FROM restaurant_inspections
GROUP BY violation_description
ORDER BY total DESC;

#PRE-QUESTION 1B VIOLATIONS IN PERCENTAGE
SELECT violation_description, COUNT(*) AS total, ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM restaurant_inspections
GROUP BY violation_description
ORDER BY total DESC;

#PRE-QUESTION 1C TOP 10 VIOLATIONS IN PERCENTAGE
SELECT violation_description, total, 
ROUND((total/SUM(total) OVER ()) * 100, 2) AS percentage
FROM (SELECT violation_description, COUNT(*) AS total
FROM restaurant_inspections WHERE violation_description IS NOT NULL AND TRIM(violation_description) <> ''
GROUP BY violation_description) AS violations
ORDER BY total DESC
LIMIT 10;

#DETAILS QUESTION 1 WHICH VIOLATIONS ARE MOST COMMON, AND WHERE DO THEY OCCUR MOST FREQUENTLY
SELECT violation_description, boro,
COUNT(*) AS total_violations,
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM restaurant_inspections
WHERE violation_description IS NOT NULL AND TRIM(violation_description) <> ''
AND boro <> '0'
GROUP BY violation_description, boro
ORDER BY total_violations DESC
LIMIT 10;

#PRE-QUESTION 2 WHERE DO VIOLATIONS OCCUR MOST
SELECT boro,
COUNT(*) AS violations
FROM restaurant_inspections
WHERE boro <> '0'
GROUP BY boro
ORDER BY violations DESC;

#PRE-QUESTION 2B RENDER RESULT IN PERCENTAGE
SELECT boro,
COUNT(*) AS violations,
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS percentage
FROM restaurant_inspections
WHERE boro <> '0'
GROUP BY boro
ORDER BY violations DESC;

#DETAILS QUESTION 2 WHICH CUISINES AND NEIGHBOURHOODS HAVE THE LOWEST FOOD SAFETY PERFORMANCE
WITH cuisine_borough AS (SELECT cuisine_description, boro, COUNT(*) AS inspections,
ROUND(AVG(score), 2) AS average_score
FROM restaurant_inspections
WHERE cuisine_description IS NOT NULL
AND TRIM(cuisine_description) <> ''
AND boro IS NOT NULL
AND boro <> '0'
AND score IS NOT NULL
GROUP BY cuisine_description, boro)
SELECT cuisine_description, boro, inspections, average_score
FROM cuisine_borough
WHERE inspections >= 10
ORDER BY average_score DESC
LIMIT 10;

#SPLITTING THE ANSWERS TO QUESTION 2
#QUESTION 2A CUISINES WITH THE LOWEST FOOD-SAFETY PERFORMANCE
SELECT cuisine_description, COUNT(*) AS inspections,
ROUND(AVG(score), 2) AS average_score
FROM restaurant_inspections
WHERE cuisine_description IS NOT NULL
AND TRIM(cuisine_description) <> ''
AND score IS NOT NULL
AND score <> '0'
GROUP BY cuisine_description
HAVING COUNT(*) >= 10
ORDER BY average_score DESC
LIMIT 10;

#QUESTION 2B BOROUGHS WITH THE LOWEST FOOD SAFETY PERFORMANCE
SELECT boro, 
COUNT(*) AS inspections,
ROUND(AVG(score), 2) AS average_score
FROM restaurant_inspections
WHERE boro IS NOT NULL
AND boro <> '0'
AND score IS NOT NULL
GROUP BY boro
ORDER BY average_score DESC;

#DETAILS QUESTION 3 WHICH CUISINES PERFORM WORST
SELECT cuisine_description,
AVG(score) AS avgscore, boro
FROM restaurant_inspections
WHERE cuisine_description IS NOT NULL 
AND cuisine_description <> '' 
AND score > 0
AND boro <> '0'
GROUP BY cuisine_description, boro
ORDER BY avgscore DESC;

#QUESTION 4 NEIGHBOURHOODS WITH POOR FOOD SAFETY
SELECT boro, AVG(score) AS avgscore
FROM restaurant_inspections
WHERE boro IS NOT NULL AND boro <> '0'
GROUP BY boro
ORDER BY avgscore DESC;

#DETAILS QUESTION 3 HOW DO RESTAURANT GRADES AND VIOLATIONS VARY ACROSS BOROUGHS AND OVER TIME
SELECT boro, YEAR(inspection_date) AS inspection_year,
COUNT(*) AS total_inspections, 
COUNT(violation_description) AS total_violations,
SUM(CASE WHEN grade = 'A' THEN 1 ELSE 0 END) AS grade_A, 
SUM(CASE WHEN grade = 'B' THEN 1 ELSE 0 END) AS grade_B,
SUM(CASE WHEN grade = 'C' THEN 1 ELSE 0 END) AS grade_C,
SUM(CASE WHEN grade = 'N' THEN 1 ELSE 0 END) AS grade_N,
SUM(CASE WHEN grade = 'P' THEN 1 ELSE 0 END) AS grade_P,
SUM(CASE WHEN grade = 'Z' THEN 1 ELSE 0 END) AS grade_Z,
SUM(CASE WHEN critical_flag = 'critical' THEN 1 ELSE 0 END) AS critical_violations,
ROUND(AVG(score), 2) AS average_score
FROM restaurant_inspections
WHERE boro <> '0' 
AND inspection_date <> 0
GROUP BY boro, inspection_year
ORDER BY inspection_year, average_score DESC;

SELECT inspection_date, COUNT(*) AS total
FROM restaurant_inspections
GROUP BY inspection_date
ORDER BY inspection_date;

SELECT MIN(inspection_date) AS earliest_date,
MAX(inspection_date) AS latest_date
FROM restaurant_inspections;

DESCRIBE restaurant_inspections;

#PART 2
#QUESTION 1: COUNT THE TOTAL NUMBER OF INSPECTIONS BY BOROUGH.
SELECT boro, 
COUNT(*) AS total_inspections,
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS percentage
FROM restaurant_inspections
WHERE boro IS NOT NULL
AND TRIM(boro) <> '0'
GROUP BY boro
ORDER BY total_inspections DESC;

#QUESTION 1 ALTERNATIVELY
SELECT boro, 
COUNT(inspection_type) AS total_inspections
FROM restaurant_inspections
WHERE boro IS NOT NULL
AND TRIM(boro) <> '0'
GROUP BY boro
ORDER BY total_inspections DESC;

#PART 2, QUESTION 2 CALCULATE THE DISTRIBUTION OF GRADES (A,B,C, N,P,Z) across NYC
SELECT grade,
COUNT(*) total, 
ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER (), 2) AS percentage
FROM restaurant_inspections
WHERE grade IN ('A','B','C','N','P','Z')
GROUP BY grade
ORDER BY percentage DESC;

#CLASS ALTERNATIVE Q2
SELECT grade,
COUNT(*) total_number_grades, 
ROUND((COUNT(*)*100)/(SELECT COUNT(*) FROM restaurant_inspections WHERE grade IN ('A', 'B','C','N','P','Z')), 2) AS percentage
FROM restaurant_inspections
WHERE grade IN ('A','B','C','N','P','Z')
GROUP BY grade
ORDER BY percentage DESC;

#Q2 REFINED
WITH grade_counts AS 
(SELECT boro, grade,
COUNT(*) total_number_grades
FROM restaurant_inspections
WHERE grade IN ('A','B','C','N','P','Z')
GROUP BY boro, grade)
SELECT boro, grade,
total_number_grades, 
ROUND(
(total_number_grades*100)/
SUM(total_number_grades) OVER (PARTITION BY boro), 2) AS percentage
FROM grade_counts
ORDER BY boro, percentage DESC;

#PART 2, PRE-QUESTION 3 IDENTIFY THE MOST COMMON INSPECTION TYPES
SELECT inspection_type,
COUNT(*) AS total_inspections
FROM restaurant_inspections
WHERE inspection_type IS NOT NULL
AND TRIM(inspection_type) <> ''
GROUP BY inspection_type
ORDER BY total_inspections DESC;

#PART 2, QUESTION 3 IDENTIFY THE MOST COMMON INSPECTION TYPES
#(INITIAL INSPECTION, RE-INSPECTION, & PRE-PERMIT)
SELECT inspection_category, 
COUNT(*) AS total_inspections
FROM(SELECT CASE 
WHEN inspection_type LIKE '%Initial inspection%' THEN 'Initial inspection'
WHEN inspection_type LIKE '%Re-inspection%' THEN 'Re-inspection'
WHEN inspection_type LIKE '%Pre-permit%' THEN 'Pre-permit'
END AS inspection_category
FROM restaurant_inspections)t
WHERE inspection_category IS NOT NULL
GROUP BY inspection_category
ORDER BY total_inspections DESC;

#(COMPLIANCE INSPECTION, INITIAL INSPECTION, RE-INSPECTION, SECOND COMPLIANCE INSPECTION, REOPENING INSPECTION)
SELECT inspection_category, 
COUNT(*) AS total_inspections
FROM(SELECT CASE 
WHEN inspection_type LIKE '%Second Compliance Inspection%' THEN 'Second Compliance Inspection'
WHEN inspection_type LIKE '%Compliance Inspection%' THEN 'Compliance Inspection'
WHEN inspection_type LIKE '%Initial inspection%' THEN 'Initial inspection'
WHEN inspection_type LIKE '%Re-inspection%' THEN 'Re-inspection'
WHEN inspection_type LIKE '%Reopening inspection%' THEN 'Reopening inspection'
END AS inspection_category
FROM restaurant_inspections)t
WHERE inspection_category IS NOT NULL
GROUP BY inspection_category
ORDER BY total_inspections DESC;

#PART 3 QUESTION 1 FIND THE TOP 10 MOST FREQUENT VIOLATIONS
SELECT violation_description,
COUNT(*) AS total_violations
FROM restaurant_inspections
WHERE violation_description IS NOT NULL AND TRIM(violation_description) <> ''
GROUP BY violation_description
ORDER BY total_violations DESC
LIMIT 10;

#PART 3 QUESTION 2 COMPARE CRITICAL VS NON-CRITICAL VIOLATIONS
SELECT critical_flag, 
COUNT(*) AS total_violations,
ROUND(COUNT(*) * 100/(SELECT COUNT(*) 
FROM restaurant_inspections
WHERE critical_flag IS NOT NULL
AND TRIM(critical_flag) <> ''), 2) AS percentage
FROM restaurant_inspections
WHERE critical_flag IS NOT NULL
AND TRIM(critical_flag) <> ''
GROUP BY critical_flag
ORDER BY total_violations DESC;

#PART 3 QUESTION 2 COMPARE CRITICAL VS NON-CRITICAL VIOLATIONS #TEAM SOLUTION
SELECT critical_flag, 
COUNT(*) AS total_violations
FROM restaurant_inspections
WHERE critical_flag IS NOT NULL
AND TRIM(critical_flag) <> ''
GROUP BY critical_flag
ORDER BY total_violations DESC;

#PART 3 QUESTION 3 WHICH BORO HAVE THE HIGHEST RATE OF CRITICAL VIOLATIONS
SELECT boro,
COUNT(*) AS total_inspections,
SUM(CASE WHEN TRIM(critical_flag) = 'Critical' THEN 1 ELSE 0 END) AS critical_violations,
ROUND(SUM(CASE WHEN TRIM(critical_flag) = 'Critical' THEN 1 ELSE 0 END)* 100/COUNT(*), 2) AS critical_violation_rate 
FROM restaurant_inspections
WHERE critical_flag IS NOT NULL
AND TRIM(critical_flag) <> ''
AND boro IS NOT NULL
AND TRIM(boro) <> ''
AND TRIM(boro) <> '0'
GROUP BY boro
ORDER BY critical_violation_rate DESC;

#PART 4, QUESTION 1 COMPARE GRADES BY CUISINE TYPE 
SELECT cuisine_description, grade,
COUNT(*) AS total_inspections,
ROUND(COUNT(*) * 100/SUM(COUNT(*)) OVER (PARTITION BY cuisine_description), 2) AS percentage
FROM restaurant_inspections
WHERE cuisine_description IS NOT NULL
AND TRIM(cuisine_description) <> ''
AND grade IN ('A','B','C','N','P','Z')
GROUP BY cuisine_description, grade
ORDER BY cuisine_description, grade;

#PART 4, QUESTION 2 FIND THE TOP 5 CUISINES WITH THE LOWEST AVERAGE SCORE
SELECT cuisine_description,
ROUND(AVG(score), 2) AS avg_score
FROM restaurant_inspections
WHERE cuisine_description IS NOT NULL
AND cuisine_description <> ''
AND cuisine_description <> 'Not Listed and Not Applicable'
AND score IS NOT NULL
GROUP BY cuisine_description
ORDER BY avg_score ASC
LIMIT 5;

#PART 4, QUESTION 3 IDENTIFY CUISINES WITH THE HIGHEST PROPORTION OF CRITICAL VIOLATIONS
SELECT cuisine_description,
COUNT(*) AS total_violations,
SUM(CASE WHEN critical_flag = 'Critical' THEN 1 ELSE 0 END) AS critical_violations,
ROUND(SUM(CASE WHEN critical_flag = 'Critical' THEN 1 ELSE 0 END) * 100/COUNT(*), 2) AS critical_violation_percentage
FROM restaurant_inspections
WHERE cuisine_description IS NOT NULL
AND cuisine_description <> ''
AND critical_flag IS NOT NULL
GROUP BY cuisine_description
ORDER BY critical_violation_percentage DESC;