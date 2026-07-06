-- Подсчитывает общее количество покупателей в таблице customers
SELECT COUNT(*) AS customers_count
FROM customers;

-- Показывает 10 продавцов с наибольшей общей выручкой

SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(*) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e
    ON s.sales_person_id = e.employee_id
JOIN products p
    ON s.product_id = p.product_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY income DESC
LIMIT 10;

-- Отчет с продавцами, чья средняя выручка за сделку ниже средней по всем продавцам
WITH seller_income AS (
    SELECT
        e.first_name || ' ' || e.last_name AS seller,
        SUM(s.quantity * p.price) / COUNT(*) AS average_income
    FROM sales s
    JOIN employees e
        ON s.sales_person_id = e.employee_id
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        e.employee_id,
        e.first_name,
        e.last_name
)

SELECT
    seller,
    FLOOR(average_income) AS average_income
FROM seller_income
WHERE average_income < (
    SELECT AVG(average_income)
    FROM seller_income
)
ORDER BY average_income;

-- Выручка продавцов по дням недели
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    LOWER(TRIM(TO_CHAR(s.sale_date, 'day'))) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY
    seller,
    day_of_week,
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date),
    seller;
