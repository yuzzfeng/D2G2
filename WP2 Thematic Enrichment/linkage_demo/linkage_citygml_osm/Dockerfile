FROM python:3.9-bullseye
WORKDIR /code

# Install required packages
ADD requirements.txt .
RUN pip install -r requirements.txt

# Copy the input files and the python script
COPY join_gml_osm_v2.1_modified.py .
COPY data.zip .
RUN unzip data.zip

# Run python script and load data to SQL db
CMD ["python", "-u", "join_gml_osm_v2.1_modified.py"]
