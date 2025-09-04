# Kiwilytics Docker Environment - Complete Setup Guide

This guide provides comprehensive step-by-step instructions for setting up and using the Kiwilytics Docker environment.

## Table of Contents
1. [First-Time Setup](#first-time-setup)
2. [Daily Usage](#daily-usage)
3. [Troubleshooting](#troubleshooting)
4. [Advanced Operations](#advanced-operations)

---

## First-Time Setup

### Prerequisites Check

Before starting, ensure you have the following installed:

#### 1. Docker Desktop
- **macOS**: Download from [docker.com](https://www.docker.com/products/docker-desktop/)
- **Windows**: Download from [docker.com](https://www.docker.com/products/docker-desktop/)
- **Linux**: Follow [Docker installation guide](https://docs.docker.com/engine/install/)

#### 2. Verify Docker Installation
```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Verify Docker is running
docker ps
```

If any command fails, restart Docker Desktop and try again.

### Step-by-Step Installation

#### Step 1: Prepare Your Environment
1. **Create a new directory** for your project:
   ```bash
   mkdir kiwilytics
   cd kiwilytics
   ```

2. **Download the project files** to this directory
3. **Ensure you have the following files**:
   - `vm_to_docker_migration.sh`
   - `docker-compose.yml`
   - `Dockerfile`
   - `start.sh`
   - `Makefile`
   - `README.md`

#### Step 2: Initial Setup
1. **Make the migration script executable**:
   ```bash
   chmod +x vm_to_docker_migration.sh
   ```

2. **Run the migration script** to create all necessary files:
   ```bash
   ./vm_to_docker_migration.sh
   ```

3. **Verify files were created**:
   ```bash
   ls -la
   ```
   You should see additional files like `docs/MIGRATION_GUIDE.md`

#### Step 3: Build and Start
1. **Build the Docker environment**:
   ```bash
   make quick-setup
   ```

2. **Wait for completion** - this may take 5-10 minutes on first run

3. **Verify containers are running**:
   ```bash
   docker ps
   ```

#### Step 4: Access Your Environment
1. **Open your web browser** and navigate to:
   - **Airflow**: http://localhost:8080
     - Username: `kiwilytics`
     - Password: `kiwilytics`
   - **Jupyter Notebook**: http://localhost:8888
   - **PostgreSQL**: localhost:5433

2. **Test Airflow login** - you should see the Airflow dashboard

#### **Database Connection Details**
For connecting to the PostgreSQL database with any client (DBeaver, pgAdmin, etc.):

**Connection Parameters:**
- **Host**: `localhost`
- **Port**: `5433`
- **Database**: `retaildb`
- **Username**: `kiwilytics`
- **Password**: `kiwilytics`

**DBeaver Setup:**
1. Click "New Database Connection" (plug icon)
2. Select "PostgreSQL" from the list
3. Enter the connection details above
4. Test the connection
5. Save and connect

---

## Daily Usage

### Starting Your Environment

#### Quick Start (Most Common)
```bash
# Navigate to your project directory
cd /path/to/kiwilytics

# Start all services
make up

# Verify services are running
docker ps
```

#### Check Service Status
```bash
# View running containers
docker ps

# View service logs
make logs

# Check specific service logs
docker compose logs kiwilytics
docker compose logs postgres
```

### Stopping Your Environment

#### Graceful Shutdown
```bash
# Stop all services
make down

# Verify containers stopped
docker ps
```

#### Emergency Stop
```bash
# Force stop all containers
docker compose down --remove-orphans
```

### Working with Your Environment

#### Accessing Services
- **Airflow**: http://localhost:8080 - Manage data pipelines and workflows
- **Jupyter**: http://localhost:8888 - Create and run notebooks
- **Database**: Use any PostgreSQL client to connect to localhost:5433

#### Database Connection Details
**PostgreSQL Connection Parameters:**
- **Host**: `localhost`
- **Port**: `5433`
- **Database**: `retaildb`
- **Username**: `kiwilytics`
- **Password**: `kiwilytics`

**Popular Database Clients:**

**DBeaver:**
1. Click "New Database Connection" (plug icon)
2. Select "PostgreSQL"
3. Enter connection details above
4. Test connection and save

**pgAdmin:**
1. Right-click "Servers" → "Create" → "Server"
2. General tab: Name your connection
3. Connection tab: Enter host, port, database, username, password
4. Save and connect

**Command Line:**
```bash
psql -h localhost -p 5433 -U kiwilytics -d retaildb
```

#### File Management
- **DAGs**: Place Airflow DAGs in the `dags/` directory
- **Notebooks**: Create notebooks in the `notebooks/` directory
- **Data**: Store data files in the `data/` directory

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Port Already in Use
**Symptoms**: Error message "Ports are not available" or "address already in use"

**Solution**:
```bash
# Check what's using the port
lsof -i :8080
lsof -i :8888
lsof -i :5433

# Stop conflicting services or change ports in docker-compose.yml
```

#### Issue 2: Containers Won't Start
**Symptoms**: Containers exit immediately or show "Exited" status

**Solution**:
```bash
# Check container logs
docker compose logs

# Restart services
make down
make up

# If still failing, rebuild
make clean
make build
make up
```

#### Issue 3: Can't Access Web Interfaces
**Symptoms**: Browser shows "Connection refused" or timeout

**Solution**:
```bash
# Verify containers are running
docker ps

# Check if ports are exposed
docker port kiwilytics-kiwilytics-1

# Restart services
make down
make up
```

#### Issue 4: Database Connection Issues
**Symptoms**: Airflow shows database errors or won't start

**Solution**:
```bash
# Check PostgreSQL container status
docker compose logs postgres

# Verify database is healthy
docker compose exec postgres pg_isready -U kiwilytics

# Restart database
docker compose restart postgres
```

### Reset and Recovery

#### Soft Reset (Keep Data)
```bash
# Stop and restart services
make down
make up
```

#### Hard Reset (Remove All Data)
```bash
# Stop and remove everything
make clean

# Rebuild from scratch
make build
make up
```

---

## Advanced Operations

### Database Operations

#### Backup Database
```bash
# Create backup
docker compose exec postgres pg_dump -U kiwilytics retaildb > backup_$(date +%Y%m%d_%H%M%S).sql
```

#### Restore Database
```bash
# Copy backup file to container
docker compose cp backup_file.sql postgres:/tmp/

# Restore from backup
docker compose exec postgres psql -U kiwilytics -d retaildb -f /tmp/backup_file.sql
```

### Customization

#### Modify Ports
Edit `docker-compose.yml` to change exposed ports:
```yaml
ports:
  - "8081:8080"  # Change Airflow from 8080 to 8081
  - "8889:8888"  # Change Jupyter from 8888 to 8889
  - "5434:5432"  # Change PostgreSQL from 5433 to 5434
```

#### Add Custom DAGs
1. Place your DAG files in the `dags/` directory
2. Restart Airflow: `docker compose restart kiwilytics`
3. DAGs will appear in the Airflow UI

#### Install Additional Python Packages
1. Edit the `Dockerfile` to add packages
2. Rebuild: `make clean && make build`
3. Restart: `make up`

### Monitoring and Logs

#### View Real-time Logs
```bash
# All services
make logs

# Specific service
docker compose logs -f kiwilytics
docker compose logs -f postgres
```

#### Resource Usage
```bash
# Container resource usage
docker stats

# Disk usage
docker system df
```

---

## Support and Maintenance

### Regular Maintenance
- **Weekly**: Check for Docker updates
- **Monthly**: Review and clean up unused images: `docker system prune`
- **As needed**: Update project files and rebuild

### Getting Help
1. **Check logs first**: `make logs`
2. **Verify Docker status**: `docker info`
3. **Check system resources**: Ensure sufficient RAM and disk space
4. **Review this guide** for common solutions

### Performance Tips
- **Allocate sufficient RAM** to Docker Desktop (recommended: 8GB+)
- **Use SSD storage** for better performance
- **Close unused containers** when not working
- **Monitor resource usage** with `docker stats`

---

## Quick Reference Commands

```bash
# Essential Commands
make up          # Start environment
make down        # Stop environment
make logs        # View logs
make clean       # Reset everything

# Status Commands
docker ps        # View running containers
docker stats     # Resource usage
docker compose logs # Service logs

# Maintenance Commands
make build       # Rebuild images
docker system prune # Clean up space
docker compose down --volumes # Remove volumes
```

---

*This guide covers the essential setup and usage of your Kiwilytics Docker environment. For advanced customization or specific use cases, refer to the Docker and Airflow documentation.*
