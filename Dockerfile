FROM python:3.11-slim

ENV AIRFLOW_HOME=/opt/airflow
ENV DEBIAN_FRONTEND=noninteractive
ENV AIRFLOW__CORE__DEFAULT_TIMEZONE=UTC
ENV AIRFLOW__WEBSERVER__DEFAULT_UI_TIMEZONE=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir \
    apache-airflow==2.8.1 \
    pandas==2.1.3 \
    matplotlib==3.8.2 \
    psycopg2-binary==2.9.9 \
    jupyter==1.0.0 \
    pendulum==2.1.2 \
    flask-session==0.5.0

# Create user and directories
RUN useradd -m -u 1000 kiwilytics && \
    mkdir -p $AIRFLOW_HOME && \
    mkdir -p /home/kiwilytics/Desktop/github && \
    mkdir -p /home/kiwilytics/notebooks && \
    chown -R kiwilytics:kiwilytics $AIRFLOW_HOME /home/kiwilytics

USER kiwilytics

# Initialize Airflow
RUN airflow db init && \
    airflow users create \
    --username kiwilytics \
    --firstname Kiwi \
    --lastname Analytics \
    --role Admin \
    --email admin@kiwilytics.com \
    --password kiwilytics

# Start script
COPY --chown=kiwilytics:kiwilytics start.sh /start.sh
USER root
RUN chmod +x /start.sh
USER kiwilytics

EXPOSE 8080 8888

CMD ["/start.sh"]
