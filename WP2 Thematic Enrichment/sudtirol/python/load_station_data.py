#import json
import psycopg2
import requests

# 1. Read data from ODH API
# 10k records of temperature data from October
api_url = "https://mobility.api.opendatahub.com/v2/flat%2Cnode/MeteoStation/%2A/2023-10-01T00%3A00%3A00/2023-10-31T23%3A59%3A59?limit=10000&offset=0&select=tunit%2Cmvalue%2Cscode%2Cmvalidtime&where=and%28or%28tname.eq.%22air-temperature%22%2Ctname.eq.%22Air_Temperature%22%29%2Cmvalidtime.neq.null%29&shownull=false&distinct=true&timezone=UTC"
response = requests.get(api_url)
if response.status_code == 200:
    json_data = response.json()
else:
    print("API request failed with status code:", response.status_code)
    exit(1)

# 2. Parse the JSON data
data_list = json_data

# 3. Connect to PostgreSQL
conn = psycopg2.connect(
    host="host.docker.internal",
    database="sudtirol_db",
    user="citydb",
    password="citydb",
    port=7777
)
cursor = conn.cursor()

# 4. Insert the data into the PostgreSQL table
insert_query = f"INSERT INTO METEO_MEASUREMENTS (station_code, timestamp_val, temperature, unit) VALUES (%s, %s, %s, %s)"

# If value is missing, insert None
for item in data_list["data"]:
    scode = item.get("scode", None)
    #lat_value = item.get("field2", None)
    #lng_value = item.get("field3", None)
    tunit = item.get("tunit", None)
    mvalue = item.get("mvalue", None)
    timestamp_val = item.get("mvalidtime", None)
    #sname_de = item.get("smetadata.name_de", None)
    #sname_it = item.get("smetadata.name_it", None)
    #sname_en = item.get("smetadata.name_en", None)
    #sname = item.get("sname", None)


    cursor.execute(insert_query, (scode, timestamp_val, mvalue, tunit))

conn.commit()  # Save the changes
conn.close()  # Close the database connection
