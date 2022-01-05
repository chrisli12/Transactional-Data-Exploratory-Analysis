--Case 1: If each customer can only belong to one segment, each transaction should belong to one segment only
WITH 
active_seg_customer AS (
   SELECT DISTINCT cust_id, seg_name FROM segments WHERE active_flag='Y'
),
rank AS (
    SELECT seg_name, category,
    SUM(t.item_qty*t.item_price) AS revenue
    FROM active_seg_customer a, transactions t, products p
    WHERE p.prod_id = t.prod_id AND a.cust_id=t.cust_id
    GROUP BY seg_name, category
)


-- Case 2: If each customer can belong to more than one segment, a transaction total might belong to more than one segment
-- WITH rank AS(
--    SELECT 
--       seg_name, 
--       category, 
--       SUM(t.item_qty*t.item_price) AS revenue 
--    FROM segments s, transactions t, products p 
--    WHERE p.prod_id = t.prod_id 
--       AND s.cust_id=t.cust_id 
--       AND active_flag='Y'
--    GROUP BY seg_name, category
--)


SELECT seg_name, category, ROUND(MAX(revenue),2) AS revenue FROM rank GROUP BY seg_name;