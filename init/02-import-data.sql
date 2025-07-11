-- Загрузка стран
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM countries LIMIT 1) THEN
        COPY countries (country_code, name)
        FROM '/data/country_code.csv'
        DELIMITER ',' CSV HEADER;
        RAISE NOTICE 'Загружено % стран', (SELECT COUNT(*) FROM countries);
    END IF;
END $$;

-- Загрузка регионов
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM regions LIMIT 1) THEN
        COPY regions (country_code, admin1_code, description)
        FROM '/data/region_code.csv'
        DELIMITER ',' CSV HEADER;
        RAISE NOTICE 'Загружено % регионов', (SELECT COUNT(*) FROM regions);
    END IF;
END $$;

-- Загрузка субрегионов
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM subregions LIMIT 1) THEN
        COPY subregions (subdiv_code, description)
        FROM '/data/subregion_code.csv'
        DELIMITER ',' CSV HEADER;
        RAISE NOTICE 'Загружено % субрегионов', (SELECT COUNT(*) FROM subregions);
    END IF;
END $$;
--------------------------------------------------------------------------

-- Загрузка списков причин смерти
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_07a LIMIT 1) THEN
        COPY icd_07a (cause_code, description)
        FROM '/data/cause_07A.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_07a);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_07b LIMIT 1) THEN
        COPY icd_07b (cause_code, description)
        FROM '/data/cause_07B.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_07b);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_08a LIMIT 1) THEN
        COPY icd_08a (cause_code, description)
        FROM '/data/cause_08A.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_08a);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_08b LIMIT 1) THEN
        COPY icd_08b (cause_code, description)
        FROM '/data/cause_08B.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_08b);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_09m LIMIT 1) THEN
        COPY icd_09m (cause_code, description)
        FROM '/data/cause_09M.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_09m);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_09n LIMIT 1) THEN
        COPY icd_09n (cause_code, description)
        FROM '/data/cause_09N.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_09n);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_09c LIMIT 1) THEN
        COPY icd_09c (cause_code, description)
        FROM '/data/cause_09C.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_09c);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_ue1 LIMIT 1) THEN
        COPY icd_ue1 (cause_code, description)
        FROM '/data/cause_UE1.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_ue1);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_101 LIMIT 1) THEN
        COPY icd_101 (cause_code, description)
        FROM '/data/cause_101.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_101);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM icd_10m LIMIT 1) THEN
        COPY icd_10m (cause_code, description)
        FROM '/data/cause_10M.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM icd_10m);
    END IF;
END $$;

-- Заполнение связующей таблицы
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM list_type_mapping LIMIT 1) THEN
        COPY list_type_mapping (list_type, table_name)
        FROM '/data/cause_mapping.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
        RAISE NOTICE 'Загружено % строк', (SELECT COUNT(*) FROM list_type_mapping);
    END IF;
END $$;
--------------------------------------------------------------------------

-- Загрузка основных данных смертности
DO $$
DECLARE
    file_path TEXT;
    file_name TEXT;
    files_found INT := 0;
    total_rows BIGINT := 0;
BEGIN
    -- Временная таблица для пакетной загрузки
    CREATE TEMP TABLE temp_mortality (
        country_code TEXT,
        admin1 TEXT,
        subdiv TEXT,
        year TEXT,
        list_type TEXT,
        cause_code TEXT,
        sex TEXT,
        format_code TEXT,
        im_format TEXT,
        deaths1 TEXT, deaths2 TEXT, deaths3 TEXT, deaths4 TEXT, deaths5 TEXT,
        deaths6 TEXT, deaths7 TEXT, deaths8 TEXT, deaths9 TEXT, deaths10 TEXT,
        deaths11 TEXT, deaths12 TEXT, deaths13 TEXT, deaths14 TEXT, deaths15 TEXT,
        deaths16 TEXT, deaths17 TEXT, deaths18 TEXT, deaths19 TEXT, deaths20 TEXT,
        deaths21 TEXT, deaths22 TEXT, deaths23 TEXT, deaths24 TEXT, deaths25 TEXT,
        deaths26 TEXT,
        im_deaths1 TEXT, im_deaths2 TEXT, im_deaths3 TEXT, im_deaths4 TEXT
    ) ON COMMIT DROP;

    -- Отключаем проверки для ускорения загрузки
    ALTER TABLE mortality_data DISABLE TRIGGER ALL;
    SET CONSTRAINTS ALL DEFERRED;

    -- Обработка всех CSV файлов
    FOR file_name IN SELECT pg_ls_dir FROM pg_ls_dir('/data') 
    WHERE pg_ls_dir LIKE 'Morticd%.csv'
    LOOP
        file_path := '/data/' || file_name;
        RAISE NOTICE 'Начата загрузка файла: %', file_name;
        
        -- Очистка временной таблицы
        TRUNCATE temp_mortality;
        
        -- Загрузка данных
        EXECUTE format('COPY temp_mortality FROM %L DELIMITER %L CSV HEADER', 
                      file_path, ',');
        
        -- Вставка в основную таблицу
        INSERT INTO mortality_data (
            country_code, admin1, subdiv, year, list_type, 
            cause_code, sex, format_code, im_format,
            deaths, im_deaths
        )
        SELECT 
            country_code::SMALLINT,
            admin1,
            subdiv,
            year::SMALLINT,
            list_type,
            cause_code,
            CASE WHEN sex::INT = 1 THEN TRUE ELSE FALSE END,
            NULLIF(format_code, ''),
            NULLIF(im_format, ''),
            ARRAY[
                NULLIF(deaths1, '')::INT, NULLIF(deaths2, '')::INT, 
                NULLIF(deaths3, '')::INT, NULLIF(deaths4, '')::INT,
                NULLIF(deaths5, '')::INT, NULLIF(deaths6, '')::INT,
                NULLIF(deaths7, '')::INT, NULLIF(deaths8, '')::INT,
                NULLIF(deaths9, '')::INT, NULLIF(deaths10, '')::INT,
                NULLIF(deaths11, '')::INT, NULLIF(deaths12, '')::INT,
                NULLIF(deaths13, '')::INT, NULLIF(deaths14, '')::INT,
                NULLIF(deaths15, '')::INT, NULLIF(deaths16, '')::INT,
                NULLIF(deaths17, '')::INT, NULLIF(deaths18, '')::INT,
                NULLIF(deaths19, '')::INT, NULLIF(deaths20, '')::INT,
                NULLIF(deaths21, '')::INT, NULLIF(deaths22, '')::INT,
                NULLIF(deaths23, '')::INT, NULLIF(deaths24, '')::INT,
                NULLIF(deaths25, '')::INT, NULLIF(deaths26, '')::INT
            ],
            ARRAY[
                NULLIF(im_deaths1, '')::INT, NULLIF(im_deaths2, '')::INT,
                NULLIF(im_deaths3, '')::INT, NULLIF(im_deaths4, '')::INT
            ]
        FROM temp_mortality
        ON CONFLICT (id, year) DO NOTHING;
        
        files_found := files_found + 1;
        total_rows := total_rows + (SELECT COUNT(*) FROM temp_mortality);
        
        RAISE NOTICE 'Загружено % строк из %', 
            (SELECT COUNT(*) FROM temp_mortality), file_name;
    END LOOP;

    -- Включаем проверки обратно
    ALTER TABLE mortality_data ENABLE TRIGGER ALL;
    SET CONSTRAINTS ALL IMMEDIATE;
    
    RAISE NOTICE 'Загрузка завершена. Обработано файлов: %, всего строк: %', 
        files_found, total_rows;
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Ошибка загрузки: %', SQLERRM;
END $$;
--------------------------------------------------------------------------

-- Создание индексов после загрузки
CREATE INDEX IF NOT EXISTS idx_mortality_country_year 
ON mortality_data(country_code, year);

CREATE INDEX IF NOT EXISTS idx_mortality_cause 
ON mortality_data(cause_code);

-- Обновление статистик
ANALYZE VERBOSE mortality_data;

-- Включаем журналирование для основной таблицы
ALTER TABLE mortality_data SET LOGGED;

DO $$ BEGIN
    RAISE NOTICE 'Done!';
END $$;