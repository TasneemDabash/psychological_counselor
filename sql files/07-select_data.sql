SELECT *
FROM sales;

SELECT date_created,
  customer_name,
  product_name,
  volume
FROM sales;

SELECT date_created,
  customer_name,
  product_name,
  volume AS total_sales
FROM sales;

SELECT
  'Hello World',
  1500,
  date_created,
  customer_name,
  product_name,
  volume AS total_sales
FROM sales;

SELECT
  date_created,
  customer_name,
  product_name,
  volume / 1000 AS 'normalized volume'
FROM sales;

SELECT
  date_created,
  customer_name,
  product_name,
  volume / 1000 AS total_sales
FROM sales;