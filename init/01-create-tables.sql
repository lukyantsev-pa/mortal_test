-- SET LOCAL statement_timeout = 0;
-- SET LOCAL lock_timeout = 0;
--------------------------------------------------------------------------

-- Таблица стран
CREATE TABLE IF NOT EXISTS countries (
    country_code SMALLINT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Таблица регионов
CREATE TABLE IF NOT EXISTS regions (
    region_id SERIAL PRIMARY KEY,
    country_code SMALLINT REFERENCES countries(country_code),
    admin1_code VARCHAR(5) NOT NULL,
    description TEXT NOT NULL,
    UNIQUE (country_code, admin1_code)
);

-- Таблица субрегионов
CREATE TABLE IF NOT EXISTS subregions (
    subregion_id SERIAL PRIMARY KEY,
    subdiv_code VARCHAR(5) NOT NULL,
    description TEXT NOT NULL,
    UNIQUE (subdiv_code)
);
--------------------------------------------------------------------------

-- Таблицы списков причин смерти
CREATE TABLE IF NOT EXISTS icd_07a (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_07b (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_08a (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_08b (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_09m (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_09n (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_09c (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_ue1 (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_101 (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS icd_10m (
    cause_code VARCHAR(5) PRIMARY KEY,  
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS list_type_mapping (
    list_type CHAR(3) PRIMARY KEY,
    table_name VARCHAR(10) NOT NULL
);
--------------------------------------------------------------------------

-- Основная таблица смертности
CREATE UNLOGGED TABLE IF NOT EXISTS mortality_data (
    id BIGSERIAL,
    country_code SMALLINT NOT NULL,
    admin1 VARCHAR(5),
    subdiv VARCHAR(5),
    year SMALLINT NOT NULL,
    list_type CHAR(3) NOT NULL,
    cause_code VARCHAR(5) NOT NULL,
    sex BOOLEAN NOT NULL,
    format_code CHAR(2),
    im_format CHAR(2),
    deaths INT[26] DEFAULT ARRAY_FILL(NULL::INT, ARRAY[26]),
    im_deaths INT[4] DEFAULT ARRAY_FILL(NULL::INT, ARRAY[4]),
    CONSTRAINT pk_mortality PRIMARY KEY (id, year),
    CONSTRAINT fk_country FOREIGN KEY (country_code) REFERENCES countries(country_code),
    --CONSTRAINT fk_region FOREIGN KEY (country_code, admin1) REFERENCES regions(country_code, admin1_code),
    --CONSTRAINT fk_subdiv FOREIGN KEY (subdiv) REFERENCES subregions(subdiv_code),
    CONSTRAINT fk_list_type FOREIGN KEY (list_type) REFERENCES list_type_mapping(list_type)
) PARTITION BY RANGE (year);

-- Партиции по годам
CREATE TABLE mortality_data_1950 PARTITION OF mortality_data
    FOR VALUES FROM (1950) TO (1960);
CREATE TABLE mortality_data_1960 PARTITION OF mortality_data
    FOR VALUES FROM (1960) TO (1970);
CREATE TABLE mortality_data_1970 PARTITION OF mortality_data
    FOR VALUES FROM (1970) TO (1980);
CREATE TABLE mortality_data_1980 PARTITION OF mortality_data
    FOR VALUES FROM (1980) TO (1990);
CREATE TABLE mortality_data_1990 PARTITION OF mortality_data
    FOR VALUES FROM (1990) TO (2000);
CREATE TABLE mortality_data_2000 PARTITION OF mortality_data
    FOR VALUES FROM (2000) TO (2010);
CREATE TABLE mortality_data_2010 PARTITION OF mortality_data
    FOR VALUES FROM (2010) TO (2020);
CREATE TABLE mortality_data_2020 PARTITION OF mortality_data
    FOR VALUES FROM (2020) TO (2030);
