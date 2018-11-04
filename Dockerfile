FROM python:3.6-slim

# get variables from environment
ARG AIRFLOW_DB_LISTENADDR
ARG AIRFLOW_DB_PORT
ARG AIRFLOW_DB_USER
ARG AIRFLOW_DB_PASSWORD
ARG AIRFLOW_DB_NAME
ARG AIRFLOW_ENCRYPTION_FERNET_KEY

# update system
RUN apt-get update -q -y && \
    apt-get install -y vim make build-essential && \
    apt-get clean -q -y && \
    apt-get autoclean -q -y && \
    apt-get autoremove -q -y

# set up env variables
ENV PATH=/home/dev/.local/bin:$PATH \
    AIRFLOW_HOME="/airflow"
ENV PYTHONPATH="${PYTHONPATH}:$AIRFLOW_HOME" \
    AIRFLOW_DB_LISTENADDR=$AIRFLOW_DB_LISTENADDR \
    AIRFLOW_DB_PORT=$AIRFLOW_DB_PORT \
    AIRFLOW_DB_USER=$AIRFLOW_DB_USER \
    AIRFLOW_DB_PASSWORD=$AIRFLOW_DB_PASSWORD \
    AIRFLOW_DB_NAME=$AIRFLOW_DB_NAME \
    SLUGIFY_USES_TEXT_UNIDECODE="yes" \
    AIRFLOW_ENCRYPTION_FERNET_KEY=$AIRFLOW_ENCRYPTION_FERNET_KEY \
    AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://$AIRFLOW_DB_LISTENADDR:$AIRFLOW_DB_PORT/$AIRFLOW_DB_NAME?user=$AIRFLOW_DB_USER&password=$AIRFLOW_DB_PASSWORD" \
    AIRFLOW__CORE__FERNET_KEY=$AIRFLOW_ENCRYPTION_FERNET_KEY \
    AIRFLOW__CORE__EXECUTOR=LocalExecutor \
    AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__WEBSERVER__DAG_DEFAULT_VIEW=graph \
    AIRFLOW__SCHEDULER__MIN_FILE_PROCESS_INTERVAL=30 \
    AIRFLOW__SCHEDULER__SCHEDULER_MAX_THREADS=1

# copy necessary files to container
COPY ./dags $AIRFLOW_HOME/dags
COPY ["entrypoint.sh", "wait_for_db.py", "requirements.txt", "makefile", "$AIRFLOW_HOME/"]

WORKDIR $AIRFLOW_HOME

# install necessary python packages
RUN make init

# run airflow
CMD sh $AIRFLOW_HOME/entrypoint.sh
