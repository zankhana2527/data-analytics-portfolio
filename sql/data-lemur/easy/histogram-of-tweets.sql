SELECT tweet_count_per_user as tweet_count_bucket,
       count(user_id) as tweet_count_per_user
from
(
    SELECT user_id,
           count(tweet_id) as tweet_count_per_user
    from tweets
    where tweet_date
    between '2022-01-01' AND '2022-12-31'
    group by user_id
) t
group by tweet_count_per_user;
