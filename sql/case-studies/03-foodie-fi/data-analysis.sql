-- CREATE TABLE foodie_fi.plans (
--     plan_id INTEGER,
--     plan_name VARCHAR(13),
--     price DECIMAL(5, 2)
-- )

-- CREATE TABLE foodie_fi.subscriptions (
--     customer_id INTEGER,
--     plan_id INTEGER,
--     start_date DATE
-- )

-- INSERT INTO foodie_fi.plans
--   (plan_id, plan_name, price)
-- VALUES
--   ('0', 'trial', '0'),
--   ('1', 'basic monthly', '9.90'),
--   ('2', 'pro monthly', '19.90'),
--   ('3', 'pro annual', '199'),
--   ('4', 'churn', null);

-- BULK INSERT foodie_fi.subscriptions
-- FROM 'Z:\myfile.csv'
-- WITH (
--     FIRSTROW = 2,
--     FIELDTERMINATOR = ',',
--     TABLOCK
-- );

-- SELECT * FROM foodie_fi.subscriptions;
-- SELECT * FROM foodie_fi.plans;

-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT
    DATEPART(month, s.start_date) AS month,
    COUNT(s.customer_id)
FROM foodie_fi.subscriptions s
    LEFT JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATEPART(month, s.start_date)
ORDER BY COUNT(s.customer_id) DESC;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT
    p.plan_name,
    COUNT(s.customer_id) AS number_of_customers
FROM foodie_fi.subscriptions s
    LEFT JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
WHERE DATEPART(year, s.start_date) > 2020
GROUP BY p.plan_name
ORDER BY COUNT(s.customer_id);

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

WITH
    churned_customer_cte
    AS
    (
        SELECT
            COUNT(DISTINCT customer_id) AS churned_customers,
            (SELECT COUNT(DISTINCT s.customer_id)
            FROM foodie_fi.subscriptions s) AS total_customers
        FROM foodie_fi.subscriptions s
            LEFT JOIN foodie_fi.plans p
            ON s.plan_id = p.plan_id
        WHERE p.plan_name = 'Churn'
    )

SELECT
    churned_customers,
    total_customers,
    ROUND((churned_customers * 100.0) / total_customers, 1) AS percentage_count
FROM churned_customer_cte;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH
    churned_trial_cte
    AS
    (
        SELECT
            s.customer_id,
            p.plan_name,
            s.start_date,
            LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS next_plan
        FROM foodie_fi.subscriptions s
            LEFT JOIN foodie_fi.plans p
            ON s.plan_id = p.plan_id
    ),

    churned_after_trial_cte
    AS
    (
        SELECT
            customer_id, plan_name, next_plan
        FROM churned_trial_cte
        WHERE plan_name = 'trial' AND next_plan = 'churn'
    )

SELECT
    COUNT(customer_id) AS churned_customers,
    FLOOR(COUNT(customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id)
    FROM foodie_fi.subscriptions)) AS churn_percentage
FROM churned_after_trial_cte;

-- 6. What is the number and percentage of customer plans after their initial free trial?

SELECT
    p.plan_name,
    COUNT(DISTINCT customer_id) as total_customers,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id)
    FROM foodie_fi.subscriptions), 2) AS percent_count
FROM foodie_fi.subscriptions s LEFT JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
WHERE p.plan_name <> 'trial'
GROUP BY p.plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH
    latest_subscription_cte
    AS
    (
        SELECT
            s.plan_id,
            s.customer_id,
            p.plan_name,
            s.start_date,
            ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date DESC) AS latest_sub
        FROM foodie_fi.subscriptions s LEFT JOIN foodie_fi.plans p
            ON s.plan_id = p.plan_id
        WHERE s.start_date <= '2020-12-31'
    )

SELECT
    plan_name,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id)
    FROM foodie_fi.subscriptions), 2) AS percent_count
FROM latest_subscription_cte
WHERE latest_sub = 1
GROUP BY plan_name
ORDER BY COUNT(customer_id);

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT
    COUNT(DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions s
    LEFT JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
WHERE DATEPART(year, s.start_date) = 2020 AND plan_name = 'pro annual';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH
    trial_to_annual_cte
    AS
    (
        SELECT
            s.customer_id,
            p.plan_name,
            s.start_date,
            LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS annual_plan_date,
            DATEDIFF(day, s.start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)) AS days
        FROM foodie_fi.subscriptions s
            LEFT JOIN foodie_fi.plans p
            ON s.plan_id = p.plan_id
        WHERE p.plan_name = 'trial' OR p.plan_name = 'pro annual'
    )

SELECT
    ROUND(AVG(days), 2) AS average_days_to_upgrade
FROM trial_to_annual_cte
WHERE days IS NOT NULL;

-- WIP: 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH
    trial_to_annual_cte
    AS
    (
        SELECT
            s.customer_id,
            p.plan_name,
            s.start_date,
            LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS annual_plan_date,
            DATEDIFF(day, s.start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)) AS days
        FROM foodie_fi.subscriptions s
            LEFT JOIN foodie_fi.plans p
            ON s.plan_id = p.plan_id
        WHERE p.plan_name = 'trial' OR p.plan_name = 'pro annual'
    )

SELECT
    MIN(days),
    MAX(days)
FROM trial_to_annual_cte
WHERE days IS NOT NULL

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH
    downgraded_customer
    AS
    (
        SELECT
            s.customer_id,
            p.plan_name,
            LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS downgraded_plan
        FROM foodie_fi.subscriptions s
            LEFT JOIN foodie_fi.plans p
            ON s.plan_id = p.plan_id
        WHERE DATEPART(year, s.start_date) = 2020 AND (p.plan_name = 'pro monthly' OR p.plan_name = 'basic monthly')
    )

SELECT COUNT(customer_id) AS downgraded_customer_count
FROM downgraded_customer
WHERE plan_name = 'pro monthly' AND downgraded_plan = 'basic monthly';
