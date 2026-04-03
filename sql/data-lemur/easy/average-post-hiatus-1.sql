SELECT user_id,
       Max(post_date :: DATE) - Min(post_date :: DATE) AS days_between
FROM   posts
WHERE  Extract(year FROM post_date :: DATE) = 2021
GROUP  BY user_id
HAVING Count(post_id) > 1;
