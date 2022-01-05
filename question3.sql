WITH rank AS (
   SELECT *,
   ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY update_at DESC) AS rank
   FROM segments
   WHERE update_at < '2016-03-02'
)
SELECT cust_id, seg_name, update_at 
FROM rank 
WHERE rank=1 
ORDER BY cust_id;