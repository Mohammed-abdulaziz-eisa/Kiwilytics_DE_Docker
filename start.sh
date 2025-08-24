#!/bin/bash
set -e

echo "Starting Kiwilytics Docker Environment..."

# Initialize Airflow database
echo "Initializing Airflow..."
airflow db init

# Create admin user
echo "Creating admin user..."
airflow users create \
    --username kiwilytics \
    --firstname Kiwi \
    --lastname Analytics \
    --role Admin \
    --email admin@kiwilytics.com \
    --password kiwilytics || echo "User already exists"

# Create PostgreSQL connection for DAGs
echo "Creating PostgreSQL connection..."
airflow connections add 'postgres_conn' \
    --conn-type 'postgres' \
    --conn-host 'postgres' \
    --conn-login 'kiwilytics' \
    --conn-password 'kiwilytics' \
    --conn-port '5432' \
    --conn-schema 'retaildb' || echo "Connection already exists"

# Wait for PostgreSQL if available
if [ "$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN" != "sqlite:///opt/airflow/airflow.db" ]; then
    echo "Waiting for PostgreSQL..."
    while ! pg_isready -h postgres -p 5432 -U kiwilytics; do
        sleep 1
    done
    echo "PostgreSQL is ready!"
    
    # Update connection string and upgrade  
    export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://kiwilytics:kiwilytics@postgres:5432/retaildb
    airflow db upgrade
fi

# Start services
echo "Starting Airflow webserver..."
airflow webserver --port 8080 &

echo "Starting Airflow scheduler..."
airflow scheduler &

echo "Starting Jupyter notebook..."
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root \
    --NotebookApp.token='' --NotebookApp.password='' \
    --notebook-dir=/home/kiwilytics &

echo "All services started!"
echo "Access points:"
echo "   - Airflow: http://localhost:8080 (kiwilytics/kiwilytics)"
echo "   - Jupyter: http://localhost:8888"
if [ "$AIRFLOW__DATABASE__SQL_ALCHEMY_CONN" != "sqlite:///opt/airflow/airflow.db" ]; then
    echo "   - PostgreSQL: localhost:5433 (kiwilytics/kiwilytics)"
fi

# Keep container running
tail -f /dev/null
