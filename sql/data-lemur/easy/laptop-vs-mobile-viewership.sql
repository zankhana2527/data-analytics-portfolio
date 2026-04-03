SELECT SUM(laptop_views) AS laptop_views,
       SUM(mobile_views) AS mobile_views
FROM
(
    SELECT CASE
               WHEN device_type IN ( 'tablet', 'phone' ) THEN
                   1
               ELSE
                   0
           END AS mobile_views,
           CASE
               WHEN device_type IN ( 'laptop' ) THEN
                   1
               ELSE
                   0
           END AS laptop_views
    FROM viewership
) t;
