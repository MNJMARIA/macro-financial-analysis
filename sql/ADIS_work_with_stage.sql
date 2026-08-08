SELECT * FROM STG_ASSETS WHERE ROWNUM <=30;
SELECT * FROM STG_GDP WHERE ROWNUM <=30;
SELECT * FROM STG_INFLATION WHERE ROWNUM <=30;
SELECT * FROM STG_REAL_INTEREST WHERE ROWNUM <=30;
SELECT * FROM STG_UNEMPLOYMENT WHERE ROWNUM <=30;


-- Видаляємо фактові таблиці першими (бо вони посилаються на виміри)
DROP TABLE fact_asset_performance CASCADE CONSTRAINTS;
DROP TABLE fact_macro_indicators CASCADE CONSTRAINTS;

-- Видаляємо виміри
DROP TABLE dim_date CASCADE CONSTRAINTS;
DROP TABLE dim_country CASCADE CONSTRAINTS;
DROP TABLE dim_asset CASCADE CONSTRAINTS;
DROP TABLE dim_asset_type CASCADE CONSTRAINTS;
DROP TABLE dim_indicator CASCADE CONSTRAINTS;
DROP TABLE dim_industry CASCADE CONSTRAINTS;
DROP TABLE dim_demographic_slice CASCADE CONSTRAINTS;

-- Видаляємо stage-таблиці
DROP TABLE stg_assets CASCADE CONSTRAINTS;
DROP TABLE stg_gdp CASCADE CONSTRAINTS;
DROP TABLE stg_inflation CASCADE CONSTRAINTS;
DROP TABLE stg_unemployment CASCADE CONSTRAINTS;
DROP TABLE stg_real_interest CASCADE CONSTRAINTS;

COMMIT;

DELETE FROM stg_assets;
DELETE FROM stg_gdp;
DELETE FROM stg_inflation;
DELETE FROM stg_real_interest;
DELETE FROM stg_unemployment;


SELECT
    (SELECT COUNT(*) FROM stg_assets) AS stg_assets,
    (SELECT COUNT(*) FROM stg_gdp) AS stg_gdp,
    (SELECT COUNT(*) FROM stg_inflation) AS stg_inflation,
    (SELECT COUNT(*) FROM stg_real_interest) AS stg_real_interest,
    (SELECT COUNT(*) FROM stg_unemployment) AS stg_unemployment;

-- Скидаємо лічильники (SEQUENCE)
ALTER TABLE stg_assets MODIFY load_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE stg_gdp MODIFY load_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE stg_inflation MODIFY load_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE stg_real_interest MODIFY load_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE stg_unemployment MODIFY load_id GENERATED ALWAYS AS IDENTITY (START WITH 1);


SELECT COUNT(*) FROM stg_assets;
SELECT COUNT(DISTINCT ticker, trade_date) FROM stg_assets;


SELECT
    (SELECT COUNT(*) FROM dim_date) AS dim_date,
    (SELECT COUNT(*) FROM dim_country) AS dim_country,
    (SELECT COUNT(*) FROM dim_asset) AS dim_asset,
    (SELECT COUNT(*) FROM dim_asset_type) AS dim_asset_type,
    (SELECT COUNT(*) FROM dim_industry) AS dim_industry,
    (SELECT COUNT(*) FROM dim_indicator) AS dim_indicator,
    (SELECT COUNT(*) FROM dim_demographic_slice) AS dim_demographic_slice,
    (SELECT COUNT(*) FROM fact_asset_performance) AS fact_asset_performance,
    (SELECT COUNT(*) FROM fact_macro_indicators) AS fact_macro_indicators;

SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL
SELECT 'dim_country', COUNT(*) FROM dim_country
UNION ALL
SELECT 'dim_asset', COUNT(*) FROM dim_asset
UNION ALL
SELECT 'dim_asset_type', COUNT(*) FROM dim_asset_type
UNION ALL
SELECT 'dim_industry', COUNT(*) FROM dim_industry
UNION ALL
SELECT 'dim_indicator', COUNT(*) FROM dim_indicator
UNION ALL
SELECT 'dim_demographic_slice', COUNT(*) FROM dim_demographic_slice
UNION ALL
SELECT 'fact_asset_performance', COUNT(*) FROM fact_asset_performance
UNION ALL
SELECT 'fact_macro_indicators', COUNT(*) FROM fact_macro_indicators;


SELECT *
FROM dim_country
ORDER BY country_name ASC;

-- Видаляємо дані + скидаємо IDENTITY
DELETE FROM fact_asset_performance;
DELETE FROM fact_macro_indicators;

DELETE FROM dim_date;
DELETE FROM dim_asset;
DELETE FROM dim_asset_type;
DELETE FROM dim_industry;
DELETE FROM dim_indicator;
DELETE FROM dim_demographic_slice;
DELETE FROM dim_country;

-- Скидаємо лічильники (SEQUENCE)
ALTER TABLE dim_date MODIFY date_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE dim_country MODIFY country_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE dim_asset MODIFY asset_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE dim_asset_type MODIFY asset_type_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE dim_industry MODIFY industry_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE dim_indicator MODIFY indicator_id GENERATED ALWAYS AS IDENTITY (START WITH 1);
ALTER TABLE dim_demographic_slice MODIFY demographic_slice_id GENERATED ALWAYS AS IDENTITY (START WITH 1);


COMMIT;