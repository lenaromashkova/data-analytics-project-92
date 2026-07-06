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

-- Количество покупателей по возрастным группам
SELECT
    age_category,
    COUNT(*) AS age_count
FROM (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category
    FROM customers
) t
GROUP BY age_category
ORDER BY age_category;

-- Количество покупателей и выручка по месяцам
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY
    selling_month;

-- Покупатели, первая покупка которых была совершена по акционному товару
WITH first_dates AS (
    SELECT
        customer_id,
        MIN(sale_date) AS first_sale_date
    FROM sales
    GROUP BY customer_id
)

SELECT DISTINCT ON (c.customer_id)
    c.first_name || ' ' || c.last_name AS customer,
    s.sale_date,
    e.first_name || ' ' || e.last_name AS seller
FROM first_dates fd
JOIN sales s
    ON fd.customer_id = s.customer_id
   AND fd.first_sale_date = s.sale_date
JOIN customers c
    ON s.customer_id = c.customer_id
JOIN employees e
    ON s.sales_person_id = e.employee_id
JOIN products p
    ON s.product_id = p.product_id
WHERE p.price = 0
ORDER BY c.customer_id, s.sales_id;
