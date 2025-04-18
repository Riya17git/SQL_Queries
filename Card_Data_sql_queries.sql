select * from cards_data;
select * from transactions_data;
select * from users_data;
use my_sql;


-- cards_data

select * from cards_data;
-- Q:1 Which clients have the highest and lowest credit limits?

select client_id, max(credit_limit) as highest , min(credit_limit) as lowest from cards_data
group by client_id;

-- Q:2 How many cards does each client own, and what is the average credit limit across their cards?
select client_id, count(distinct card_number) as total_card_own , 
AVG(CAST(REPLACE(REPLACE(credit_limit, '$', ''), ',', '') AS DECIMAL(10, 2))) AS average_limit
from cards_data
group by client_id
order by client_id;

-- Q:3 What is the maximum and minimum credit limit for each client?
select client_id, max(replace(replace(credit_limit,'$',''),',','')) as Max_limit , 
min(replace(replace(credit_limit,',',''),'$','')) as Min_limit
from cards_data
group by client_id
order by client_id;

-- Q:4 What is the total number of debit vs. credit cards issued in the dataset?
select card_type, count(*) as total_cards
from cards_data
group by card_type;

-- Q:5 List clients who have cards flagged as card_on_dark_web = Yes.
select client_id from cards_data
where card_on_dark_web = 'YES';

-- Q:6 How many cards are expiring within the next 6 months?

select count(distinct card_number) as total_expiring_card 
from(
select card_number, str_to_date(expires,'%m%Y') as converted_date from Cards_data) 
as converted_data
where converted_date between curdate() and date_add(curdate(),Interval 6 MONTH);

-- Q:7 Which client have the most cards expiring in the current year?
SELECT 
    client_id, 
    COUNT(card_number) AS total_expiring_cards
FROM (
    SELECT 
        client_id, 
        card_number, 
        STR_TO_DATE(expires, '%m/%Y') AS expiration_date
    FROM cards_data
) AS converted_data
WHERE YEAR(expiration_date) = YEAR(CURDATE())
GROUP BY client_id
ORDER BY total_expiring_cards DESC
LIMIT 1;

-- Q:8 List the total credit limit for cards issued in each year (acct_open_date).

SELECT 
    YEAR(STR_TO_DATE(CONCAT('01/', acct_open_date), '%d/%m/%Y')) AS current_year,
    SUM(CAST(REPLACE(REPLACE(credit_limit, '$', ''), ',', '') AS DECIMAL(10,2))) AS total_limit
FROM cards_data
GROUP BY current_year
ORDER BY current_year;

-- Q:9 What is the earliest and latest account opening date in the dataset?
select min(str_to_date(concat('01/',acct_open_date), '%d/%m/%Y')) as earliest_date,
max(str_to_date(concat('01/',acct_open_date), '%d/%m/%Y')) as latest_date
from cards_data;

-- Q:10 Which clients have not changed their PIN for more than 5 years?
SELECT DISTINCT client_id
FROM cards_data
WHERE YEAR(NOW()) - year_pin_last_changed > 5;

-- Q:11 What is the count of cards by brand (e.g., Visa, Mastercard)?
select card_brand, count(card_brand) as total_cards
from cards_data
group by card_brand;

-- Q:12 What is the average credit limit for each card brand and type?
select card_brand, card_type, avg(replace(replace(credit_limit,'$',''),',','')) as average_limit
from cards_data
group by card_brand, card_type;

-- Q:13 What percentage of cards are Debit, Credit, or Prepaid?
SELECT 
    card_type,
    COUNT(*) AS total_cards,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM cards_data), 2) AS percentage
FROM cards_data
GROUP BY card_type
ORDER BY percentage DESC;

-- Q:14 How many cards have a chip (has_chip = YES) and are also flagged as "card_on_dark_web = No"?
select count(distinct card_number) as total_cards 
from cards_data
where has_chip = 'YES' and card_on_dark_web = 'No';

-- Q:15 What is the total credit limit of cards flagged as "card_on_dark_web = No"?
select sum(replace(replace(credit_limit,'$',''), ',','')) as total_credit_limit
from cards_data
where card_on_dark_web = 'No';

-- Q:16 Calculate the average number of cards (num_cards_issued) issued per client.
select client_id, avg(num_cards_issued) as average_card_issued
from cards_data
group by client_id;

-- Q:17 What is the total credit limit for cards issued before 2010?
select SUM(CAST(REPLACE(REPLACE(credit_limit, '$', ''), ',', '') AS DECIMAL(10,2))) AS total_credit_limit
from cards_data
where year(str_to_date(concat('01/',acct_open_date),'%d/%m/%Y')) < 2010;

-- Q:18 Find the most common expiration month across all cards.
select count(month(str_to_date(concat('01/',expires),'%d/%m/%Y'))) as total_count, month(str_to_date(concat('01/',expires),'%d/%m/%Y')) as month_most
from cards_data
group by month_most
order by total_count desc
limit 1;

-- Q:19 Which clients have both Debit and Credit cards?
SELECT client_id
FROM cards_data
WHERE card_type IN ('Debit', 'Credit')
GROUP BY client_id
HAVING COUNT(DISTINCT card_type) = 2;

-- Q:20 Find the ratio of Debit cards to Credit cards for each client.
SELECT 
    client_id,
    SUM(CASE WHEN card_type = 'Debit' THEN 1 ELSE 0 END) AS debit_count,
    SUM(CASE WHEN card_type = 'Credit' THEN 1 ELSE 0 END) AS credit_count,
    CASE 
        WHEN SUM(CASE WHEN card_type = 'Credit' THEN 1 ELSE 0 END) = 0 THEN NULL
        ELSE ROUND(
            SUM(CASE WHEN card_type = 'Debit' THEN 1 ELSE 0 END) / 
            SUM(CASE WHEN card_type = 'Credit' THEN 1 ELSE 0 END), 2
        )
    END AS debit_credit_ratio
FROM cards_data
GROUP BY client_id;

-- Q:21 List clients whose total credit limit is less than $10,000.
select client_id , sum(replace(replace(credit_limit,'$',''),',','')) as total_credit_limit
from cards_data
group by client_id
having sum(replace(replace(credit_limit,'$',''),',','')) < 10000;

-- Q:22 How many years has each client had their oldest account open?
SELECT 
    client_id, 
    YEAR(CURDATE()) - min(year(str_to_date(concat('01/', expires),'%d/%m/%Y'))) AS years_since_oldest_account
FROM cards_data
GROUP BY client_id;


-- Q :23 Identify cards where the expires date is more than 10 years after the acct_open_date.
SELECT * 
FROM cards_data
WHERE 
    (YEAR(STR_TO_DATE(CONCAT('01/', expires), '%d/%m/%Y')) - 
     YEAR(STR_TO_DATE(CONCAT('01/', acct_open_date), '%d/%m/%Y'))) > 10;
     
     


