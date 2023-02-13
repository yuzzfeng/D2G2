FROM bitnami/minideb:buster

RUN install_packages curl ca-certificates -y
RUN install_packages wget procps openjdk-11-jdk-headless git python3 -y

WORKDIR /tmp

RUN wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz
#COPY spark-3.3.2-bin-hadoop3.tgz .
RUN tar xvf spark-*
RUN mv spark-3.3.2-bin-hadoop3 /opt/spark

ENV SPARK_HOME=/opt/spark
ENV PATH=${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
ENV PYSPARK_PYTHON=/usr/bin/python3

WORKDIR /home

COPY start.sh start.sh
COPY sql/all-spark.sql all-spark.sql

RUN chmod +x start.sh

RUN cd ${SPARK_HOME}/jars && \
wget "https://search.maven.org/remotecontent?filepath=org/apache/sedona/sedona-python-adapter-3.0_2.12/1.3.1-incubating/sedona-python-adapter-3.0_2.12-1.3.1-incubating.jar" && \
wget "https://search.maven.org/remotecontent?filepath=org/apache/sedona/sedona-viz-3.0_2.12/1.3.1-incubating/sedona-viz-3.0_2.12-1.3.1-incubating.jar" && \
wget  "https://search.maven.org/remotecontent?filepath=org/datasyslab/geotools-wrapper/1.3.0-27.2/geotools-wrapper-1.3.0-27.2.jar"
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf
COPY postgresql-42.2.8.jar /opt/spark/jars/postgresql-42.2.8.jar

EXPOSE 8050
EXPOSE 8051
EXPOSE 10000

CMD [ "./start.sh" ]