--I assume that each customer should only belongs to one segmentation group
--a customer cannot be loyal and one-offs at the same time, hence only the lastest update on each customer should be labeled with active_flag='Y'. 
--I take the lastest updated segment on each customer as the msot current active segment when a customer has multiple active segment labelled as active.
SELECT cust_id, seg_name, update_at FROM segments WHERE active_flag='Y' GROUP BY cust_id ORDER BY update_at DESC;
