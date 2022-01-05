# SQL Problem

This question will test some basic knowledge of SQL. The first four questions should
not take more than an hour to complete.

## Description of Tables

There are three tables involved in this question: `transactions`, `segments` and
`products`, which simulate a simplified retail data schema.  Here is a semantic
description of the tables:

1. `transactions`: contains detailed information about each product a customer
   has purchased.  A transaction consists of one or more products purchased by
   a customer indexed by a unique transaction id.
   * `trans_id`: the transaction id
   * `trans_dt`: transaction date
   * `cust_id`: the customer id
   * `prod_id`: the product id
   * `item_qty`: the quantity of the product that is being purchased
   * `item_price`: the per unit price of the product (NOTE: the total revenue
     for a product is `item_qty * item_price`)
2. `products`: contains detailed attributes about each product.
   * `prod_id`: the product id (same meaning as in `transactions`)
   * `prod_name`: the product name
   * `brand`: the brand of the product
   * `category`: the category of the product
3. `segments`: contains a history of customer segmentation labelling for each
   customer.  Segments are computed periodically for all current customers and
   appended to the table after each computation.  The current (most up to date)
   active segment for each customer is specified by `active_flag = 'Y'` column.
   * `cust_id`: the customer id (same meaning as in `transactions`)
   * `seg_name`: the segment of this customer
   * `update_at`: the date when this segment was updated
   * `active_flag`: whether or not this segment is the active segment for this customer

## Sample Database

Included is a sample SQLite3 database for the above tables named `sample.db`.
Please refer to https://www.sqlite.org/download.html to download command-line
tools so you can run your queries against the sample data.

## Problems

Please provide the SQL for each one of these questions.  If there is not enough
information given, please make a reasonable assumption and we can discuss it in
the in-person interview. Please document any assumptions you’ve made in the comments 
of each solution and include any additional queries you ran to validate that they 
are reasonable.

1. Find the current active segment for each customer sorted by the segment
   update date.  The output should contain three columns: `cust_id`,
   `seg_name`, `update_at`.  Here is some sample output:

        cust_id     seg_name        update_at
        4402        ONE-OFFS        2016-02-01 00:00:00
        11248       ONE-OFFS        2015-10-01 00:00:00
        
      SELECT cust_id, seg_name, update_at 
      FROM segments 
      WHERE active_flag='Y' 
      GROUP BY cust_id 
      ORDER BY update_at DESC;

      I assume that each customer should only belongs to one segmentation group base on the sematic meaning of seg_name (a customer cannot be loyal and one-offs at the same one), hence only the last update on each customer should be labeled with active_flag='Y'. I take the lastest updated segment on each customer as the msot current active segment when a customer has multiple active segment labelled as active.

2. For each product purchased between Jan 2016 and May 2016 (inclusive), find
   the number of distinct transactions.  The output should contain `prod_id`,
   `prod_name` and distinct transaction columns.  Here is some sample output:

        prod_id     prod_name       count
        199922      Product 199922  1
        207344      Product 207344  1
        209732      Product 209732  1

   SELECT t.prod_id, p.prod_name, count(DISTINCT t.trans_id) AS count 
   FROM transactions t, products p 
   WHERE p.prod_id = t.prod_id AND t.trans_dt BETWEEN '2016-01-01' AND '2016-05-31' 
   GROUP BY t.prod_id;

3. Find the most recent segment of each customer as of 2016-03-01.
   *Hint*: You cannot simply use `active_flag` since that is as of the current
   date *not* 2016-03-01.  The output should contain the `cust_id`, `seg_name`
   and `update_at`  columns and should have at most one row per customer.  Here
   is some sample output:

       cust_id  seg_name    update_at
       4402     ONE-OFFS    2016-02-01 00:00:00
       11248    LOYAL       2016-02-01 00:00:00
       126169   ONE-OFFS    2015-03-01 00:00:00


   WITH asofdate AS (
      SELECT *,
      ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY update_at DESC) AS rank
      FROM segments
      WHERE update_at < '2016-03-02'
   )
   SELECT cust_id, seg_name, update_at 
   FROM asofdate 
   WHERE rank=1 
   ORDER BY cust_id;


4. Find the most popular category (by revenue) for each active segment.
   *Hint*: The current (most up to date) active segment is specified by `active_flag = 'Y'` column in the segments table.
   Here is the some sample output:
	
  	seg_name    category    revenue
	INFREQUENT  Women       20264.39
 
Case 1: If each customer can only belong to one segment, each transaction should belong to one segment only
   <!-- WITH 
   active_seg_customer AS (
      SELECT DISTINCT cust_id, seg_name FROM segments WHERE active_flag='Y'
   ),
   rank AS (
     SELECT seg_name, category,
     SUM(t.item_qty*t.item_price) AS revenue
     FROM active_seg_customer a, transactions t, products p
    WHERE p.prod_id = t.prod_id AND a.cust_id=t.cust_id
     GROUP BY seg_name, category
   ) -->

   SELECT seg_name, category, ROUND(MAX(revenue),2) FROM rank GROUP BY seg_name;

Case 2: If each customer can belong to more than one segment, a transaction total might belong to more than one segment
   WITH rank AS(
      SELECT 
         seg_name, 
         category, 
         SUM(t.item_qty*t.item_price) AS revenue 
      FROM segments s, transactions t, products p 
      WHERE p.prod_id = t.prod_id 
         AND s.cust_id=t.cust_id 
         AND active_flag='Y'
      GROUP BY seg_name, category
   )

   SELECT seg_name, category, ROUND(MAX(revenue),2) AS revenue FROM rank GROUP BY seg_name;


5. Use the current sample database to find insights. Please document your steps, include any code/documents you used (Excel, SQL, Python, etc), and have the final results in a Powerpoint format (limit 3 slides). You may be asked about the insights you come up with in a follow-up interview.
   *Hint*: This is open ended, but you could look at sales trend, category insights, customers insights
