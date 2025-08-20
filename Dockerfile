FROM python:3.11-slim

ENV AIRFLOW_HOME=/opt/airflow
ENV DEBIAN_FRONTEND=noninteractive
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=sqlite:///opt/airflow/airflow.db

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    git \
    curl \
    gcc \
    python3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages with constraints
RUN pip install --no-cache-dir \
    "apache-airflow[postgres]==2.8.4" \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.8.4/constraints-3.11.txt"

RUN pip install --no-cache-dir \
    pandas==2.1.3 \
    matplotlib==3.8.2 \
    jupyter==1.0.0

# Create user and directories
RUN useradd -m -u 1000 kiwilytics && \
    mkdir -p $AIRFLOW_HOME && \
    mkdir -p /home/kiwilytics/Desktop/github && \
    mkdir -p /home/kiwilytics/notebooks && \
    chown -R kiwilytics:kiwilytics $AIRFLOW_HOME /home/kiwilytics

USER kiwilytics

# Start script
COPY --chown=kiwilytics:kiwilytics start.sh /start.sh
USER root
RUN chmod +x /start.sh
USER kiwilytics

EXPOSE 8080 8888

CMD ["/start.sh"]
