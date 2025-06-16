SELECT * FROM sales
WHERE volume > 1000;

SELECT * FROM sales
WHERE is_recurring = TRUE;

SELECT * FROM sales
WHERE (is_disputed IS TRUE) AND (volume > 5000);

SELECT * FROM sales
WHERE (is_disputed IS TRUE) OR (volume > 5000);

SELECT *
FROM sales;