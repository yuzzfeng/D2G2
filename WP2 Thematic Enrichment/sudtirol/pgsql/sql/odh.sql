CREATE TABLE METEO_MEASUREMENTS
(
    id SERIAL PRIMARY KEY,
    station_code TEXT NOT NULL,
    timestamp_val TIMESTAMP NOT NULL,
    temperature DOUBLE PRECISION,
    unit TEXT
);
