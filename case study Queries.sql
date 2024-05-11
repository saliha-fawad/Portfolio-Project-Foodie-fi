CASE STUDY PROBLEMS ANALYSIS:
  # Problem 1:
## How many customers has Foodie-Fi ever had?  
## Solution: 
#QUERY:
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions; 

# Problem 2 :
## What is the monthly distribution of trial plan start_date values for our dataset. 
## Solution:
  First of all we try Date_Format data type and then try to use and apply group by function to solve our problem.Here is the query 
  attached below: */
SELECT DATE_FORMAT(start_date, '%Y-%m-01') AS start_of_month, COUNT(*) AS total_plan
FROM subscriptions
GROUP BY DATE_FORMAT(start_date, '%Y-%m-01');

/* Problem 3: What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name */
/* Solution: According to my logic we  should first count the  plan_name and then we evaluate and analyze the problem bu using/trying different 
functions. Here now i use join,where clause and group by functions to solve and evaluate this problem. Here is the query attached below: */
SELECT p.plan_name, COUNT(*) AS total_events
FROM plans p
JOIN subscriptions s ON p.plan_id = s.plan_id
WHERE s.start_date > '2020-01-01'
GROUP BY p.plan_name; 
/*Problem 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place? */
/* Solution: 
SELECT 
    COUNT(DISTINCT s.customer_id) AS total_customers,
ROUND((COUNT(DISTINCT CASE WHEN s.start_date < '2020-01-01' THEN s.customer_id END) / COUNT(DISTINCT s.customer_id) * 100), 1) AS churn_percent
FROM subscriptions s; 
/* 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH trial_end_dates AS (
    SELECT 
        s.customer_id,
        MIN(s.start_date) AS trial_start_date,
        MIN(s.start_date) + INTERVAL 30 DAY AS trial_end_date
    FROM subscriptions s
    GROUP BY s.customer_id
)
SELECT 
    COUNT(*) AS churned_after_trial_count,
    ROUND((COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM trial_end_dates) * 100)) AS churned_after_trial_percentage
FROM trial_end_dates ted
JOIN subscriptions s ON ted.customer_id = s.customer_id
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.start_date = ted.trial_end_date
AND p.price = 0; */
/* 6. What is the number and percentage of customer plans after their initial free trial? 
WITH trial_end_dates AS (
    SELECT 
        s.customer_id,
        MIN(s.start_date) AS trial_start_date,
        MIN(s.start_date) + INTERVAL 30 DAY AS trial_end_date
    FROM subscriptions s
    GROUP BY s.customer_id
)
SELECT 
    COUNT(*) AS total_customers,
    COUNT(DISTINCT s.plan_id) AS total_plans,
    ROUND((COUNT(DISTINCT s.plan_id) / COUNT(*) * 100), 1) AS plan_percentage
FROM trial_end_dates ted
JOIN subscriptions s ON ted.customer_id = s.customer_id
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.start_date > ted.trial_end_date
AND p.price > 0; */
/* 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31? 
WITH active_plans AS (
    SELECT 
        s.customer_id,
        p.plan_name
    FROM subscriptions s
    JOIN plans p ON s.plan_id = p.plan_id
    WHERE s.start_date <= '2020-12-31'
    AND s.customer_id NOT IN (
        SELECT customer_id
        FROM subscriptions
        WHERE start_date > '2020-12-31'
    )
)
SELECT 
    plan_name,
    COUNT(customer_id) AS customer_count,
    ROUND((COUNT(customer_id) / (SELECT COUNT(*) FROM active_plans) * 100), 2) AS percentage
FROM active_plans
GROUP BY plan_name; */
/* 8. How many customers have upgraded to an annual plan in 2020? 
SELECT COUNT(DISTINCT customer_id) AS upgraded_customers
FROM subscriptions
WHERE plan_id IN (
    SELECT plan_id
    FROM plans
    WHERE plan_name = 'annual'
)
AND start_date >= '2020-01-01'
AND start_date <= '2020-12-31'; */
/* 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi? 
WITH customer_upgrade_dates AS (
    SELECT
        s.customer_id,
        MIN(s.start_date) AS join_date,
        MIN(CASE WHEN p.plan_name = 'annual' THEN s.start_date END) AS upgrade_date
    FROM subscriptions s
    JOIN plans p ON s.plan_id = p.plan_id
    GROUP BY s.customer_id
)
SELECT 
    AVG(DATEDIFF(upgrade_date, join_date)) AS average_days_to_upgrade
FROM customer_upgrade_dates
WHERE upgrade_date IS NOT NULL; */
/* 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc) 
WITH customer_upgrade_dates AS (
    SELECT
        s.customer_id,
        DATEDIFF(MIN(s.start_date), MIN(CASE WHEN p.plan_name = 'annual' THEN s.start_date END)) AS days_to_upgrade
    FROM subscriptions s
    JOIN plans p ON s.plan_id = p.plan_id
    GROUP BY s.customer_id
)
SELECT 
    CASE 
        WHEN days_to_upgrade BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN days_to_upgrade BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN days_to_upgrade BETWEEN 61 AND 90 THEN '61-90 days'
        ELSE 'More than 90 days'
    END AS period,
    COUNT(customer_id) AS customer_count
FROM customer_upgrade_dates
GROUP BY period; */
/* 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? 
SELECT COUNT(DISTINCT customer_id) AS downgraded_customers
FROM subscriptions
WHERE plan_id IN (
    SELECT plan_id
    FROM plans
    WHERE plan_name = 'Pro Monthly'
)
AND customer_id IN (
    SELECT customer_id
    FROM subscriptions
    WHERE plan_id IN (
        SELECT plan_id
        FROM plans
        WHERE plan_name = 'Basic Monthly'
    )
    AND start_date >= '2020-01-01'
    AND start_date <= '2020-12-31'
)
AND start_date >= '2020-01-01'
AND start_date <= '2020-12-31';  */

