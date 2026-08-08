-- 1. Заповнення dim_date
-- dim_date
INSERT INTO dim_date (full_date, year, quarter, month, month_name, day, day_of_week, is_weekend)
SELECT DISTINCT 
    TRUNC(trade_date) AS full_date,
    EXTRACT(YEAR FROM trade_date),
    TO_NUMBER(TO_CHAR(trade_date, 'Q')),
    EXTRACT(MONTH FROM trade_date),
    TO_CHAR(trade_date, 'Month'),
    EXTRACT(DAY FROM trade_date),
    TO_NUMBER(TO_CHAR(trade_date, 'D')),
    CASE WHEN TO_CHAR(trade_date, 'D') IN (1,7) THEN 1 ELSE 0 END
FROM stg_assets
WHERE trade_date IS NOT NULL
MINUS
SELECT full_date, year, quarter, month, month_name, day, day_of_week, is_weekend 
FROM dim_date;




-- 2. Заповнення довідкових таблиць
-- dim_asset_type
INSERT INTO dim_asset_type (asset_type_name)
SELECT DISTINCT asset_type FROM stg_assets
WHERE asset_type IS NOT NULL
MINUS
SELECT asset_type_name FROM dim_asset_type;



-- dim_industry
INSERT INTO dim_industry (industry_name, industry_tag)
SELECT DISTINCT NULL, industry_tag 
FROM stg_assets 
WHERE industry_tag IS NOT NULL
MINUS
SELECT industry_name, industry_tag FROM dim_industry;



-- dim_indicator
INSERT INTO dim_indicator (indicator_name)
SELECT DISTINCT indicator_name FROM stg_gdp
UNION
SELECT DISTINCT indicator_name FROM stg_inflation
UNION
SELECT DISTINCT indicator_name FROM stg_unemployment
UNION
SELECT DISTINCT indicator_name FROM stg_real_interest
MINUS
SELECT indicator_name FROM dim_indicator;



-- dim_demographic_slice
INSERT INTO dim_demographic_slice (sex, age_group, age_categories)
SELECT DISTINCT sex, age_group, age_categories 
FROM stg_unemployment
WHERE sex IS NOT NULL
MINUS
SELECT sex, age_group, age_categories FROM dim_demographic_slice;




-- dim_country
INSERT INTO dim_country (country_name, country_code)
SELECT 
    country_name,
    MAX(country_code) AS country_code
FROM (
    SELECT LOWER(TRIM(country)) AS country_name, country_code FROM stg_gdp
    UNION ALL
    SELECT LOWER(TRIM(country)), country_code FROM stg_real_interest
    UNION ALL
    SELECT LOWER(TRIM(country)), NULL FROM stg_assets
    UNION ALL
    SELECT LOWER(TRIM(country)), NULL FROM stg_inflation
    UNION ALL
    SELECT LOWER(TRIM(country)), NULL FROM stg_unemployment
)
WHERE country_name IS NOT NULL
GROUP BY country_name
MINUS
SELECT LOWER(country_name), country_code FROM dim_country;





-- 4. Заповнення dim_asset
-- dim_asset
INSERT INTO dim_asset (asset_symbol, asset_name, asset_type_id, industry_id, country_id)
SELECT 
    a.ticker,
    MAX(a.asset_name),
    at.asset_type_id,
    MAX(i.industry_id),
    MAX(c.country_id)
FROM stg_assets a
JOIN dim_asset_type at ON LOWER(TRIM(at.asset_type_name)) = LOWER(TRIM(a.asset_type))
LEFT JOIN dim_industry i   ON i.industry_tag = a.industry_tag
LEFT JOIN dim_country c    ON LOWER(TRIM(c.country_name)) = LOWER(TRIM(a.country))
WHERE a.ticker IS NOT NULL
GROUP BY 
    a.ticker,
    at.asset_type_id
HAVING NOT EXISTS (
    SELECT 1 
    FROM dim_asset da 
    WHERE da.asset_symbol = a.ticker
);




-- 5. Заповнення FACT таблиць
-- fact_asset_performance
INSERT /*+ APPEND */ INTO fact_asset_performance
    (date_id, asset_id, open_price, high_price, low_price, close_price, volume, daily_return)
SELECT
    d.date_id,
    da.asset_id,
    a.open_price,
    a.high_price,
    a.low_price,
    a.close_price,
    a.volume,
    a.daily_return
FROM stg_assets a
JOIN dim_date d ON d.full_date = TRUNC(a.trade_date)
JOIN dim_asset da ON da.asset_symbol = TRIM(a.ticker)
WHERE a.trade_date IS NOT NULL
    AND NOT EXISTS (     -- захист від дублів
        SELECT 1 
        FROM fact_asset_performance f 
        WHERE f.date_id = d.date_id
            AND f.asset_id = da.asset_id
    );



-- fact_macro_indicators
INSERT INTO fact_macro_indicators 
    (date_id, country_id, indicator_id, demographic_slice_id, value)
SELECT 
    d.date_id,
    c.country_id,
    i.indicator_id,
    NULL AS demographic_slice_id,
    AVG(x.value) AS value
FROM (
    SELECT country, year_date, gdp_value AS value, indicator_name
    FROM stg_gdp
    UNION ALL
    SELECT country, year_date, inflation_value AS value, indicator_name
    FROM stg_inflation
    UNION ALL
    SELECT  country, year_date, unemployment_rate AS value, indicator_name
    FROM stg_unemployment
    UNION ALL
    SELECT  country, year_date, real_interest_rate AS value, indicator_name
    FROM stg_real_interest
) x
JOIN dim_date d ON d.full_date = TRUNC(x.year_date)
JOIN dim_country c ON c.country_name = x.country
JOIN dim_indicator i ON i.indicator_name = x.indicator_name
GROUP BY 
    d.date_id,
    c.country_id,
    i.indicator_id
HAVING NOT EXISTS (
    SELECT 1
    FROM fact_macro_indicators f
    WHERE f.date_id = d.date_id
        AND f.country_id = c.country_id
        AND f.indicator_id = i.indicator_id
);


COMMIT;
