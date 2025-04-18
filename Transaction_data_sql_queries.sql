use my_sql;

select * from transactions_data;

-- Q:1 How many transactions were made using a chip (use_chip) vs. swipe transactions?
select count(id) as total_transaction , use_chip
from transactions_data
group by use_chip;

-- Q: 2 Find the total transaction amount for each client
select client_id, round(sum(replace(replace(amount,'$',''),',','')),2) as total_amount
from transactions_data
group by client_id
order by total_amount;

-- Q:3 List all distinct merchant states 
select distinct merchant_state from transactions_data;

-- Q:4 Find the total and average transaction amount per client.
select client_id, round(sum(replace(replace(amount,'$',''),',','')),2) as total_sum , 
round(avg(replace(replace(amount,'$',''),',','')),2) as average_amount
from transactions_data
group by client_id;

-- Q:5 Find transactions where the amount is negative (potential refunds or chargebacks).
SELECT id, CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2)) AS amount
FROM transactions_data
WHERE CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2)) < 0;

-- Q:6 Find the top 3 most frequent merchant_id values in the dataset.
select merchant_id, count(*) as transaction_count
from transactions_data
group by merchant_id
order by transaction_count DESC
limit 3;

-- Q:7 Calculate the total transaction amount for each client_id, sorted in descending order.
select client_id, round(sum(replace(replace(amount,'$',''),',','')),2) as total_amount
from transactions_data
group by client_id
order by total_amount DESC;

-- Q:8 Find the number of transactions for each mcc code
select mcc, count(id) as number_of_transaction
from transactions_data
group by mcc
order by number_of_transaction desc;

-- Q:9 Retrieve all transactions where the amount is greater than the average transaction amount.
SELECT id, amount
FROM transactions_data
WHERE CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2)) > 
      (SELECT AVG(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2)))
       FROM transactions_data);

-- Q: 10 Identify the client_id that has the highest total spending.
select client_id, sum(replace(replace(amount,'$',''),',','')) as total_amount 
from transactions_data
group by client_id
order by total_amount desc
limit 1;

-- Q:11 Find the merchant_id with the highest total transaction amount.
select merchant_id, sum(replace(replace(amount,'$',''),',','')) as total_amount 
from transactions_data
group by merchant_id
order by total_amount desc
limit 1;

-- Q:12 Determine the top 3 states (merchant_state) with the highest total transaction amounts.
select merchant_state, sum(replace(replace(amount,'$',''),',','')) as total_amount 
from transactions_data
group by merchant_state
order by total_amount desc
limit 3;

-- Q:13 Calculate the cumulative transaction amount for each client_id over time.
select id, client_id, date, amount,
SUM(CAST(REPLACE(REPLACE(amount, '$', ''), ',', '') AS DECIMAL(10,2))) 
        OVER (PARTITION BY client_id ORDER BY date) AS cumulative_amount FROM transactions_data
ORDER BY client_id, date;

-- Q:14 Identify any clients who have transactions at more than one merchant_city.
SELECT client_id
FROM transactions_data
GROUP BY client_id
HAVING COUNT(DISTINCT merchant_city) > 1;

-- Q:15 Detect potential fraudulent activity by listing transactions where the same client_id made 
-- multiple purchases in different states within a short time span (e.g., 5 minutes).





















