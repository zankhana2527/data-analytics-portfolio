SELECT user_id,
       spend,
       transaction_date
FROM
(
    SELECT user_id,
           spend,
           transaction_date,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) as row_number
    FROM transactions
) t
WHERE row_number = 3;
