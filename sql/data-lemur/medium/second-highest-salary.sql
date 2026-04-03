SELECT salary
FROM
(
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) as rank
    FROM employee
) t
WHERE rank = 2;
