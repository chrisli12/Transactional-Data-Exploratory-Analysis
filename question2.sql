SELECT t.prod_id, p.prod_name, count(DISTINCT t.trans_id) AS count 
FROM transactions t, products p 
WHERE p.prod_id = t.prod_id AND t.trans_dt BETWEEN '2016-01-01' AND '2016-05-31' 
GROUP BY t.prod_id;