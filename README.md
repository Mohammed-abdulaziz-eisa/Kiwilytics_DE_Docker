# Kiwilytics Docker Environment

A modern Docker-based environment for Kiwilytics data Engineering workflows, migrated from VirtualBox VM.

## Quick Connection Reference

**Airflow**: http://localhost:8080 (kiwilytics/kiwilytics)  
**Jupyter**: http://localhost:8888  
**PostgreSQL**: localhost:5433 (retaildb/kiwilytics/kiwilytics)

> **Note**: PostgreSQL runs on port 5433 (instead of the default 5432) to avoid conflicts with local PostgreSQL installations.

## Complete Setup Guide

### For First-Time Users (Complete Setup)

#### Step 1: Prerequisites
1. **Install Docker Desktop**
   - Download from [docker.com](https://www.docker.com/products/docker-desktop/)
   - Install and start Docker Desktop
   - Ensure Docker is running (you should see the Docker icon in your menu bar)

2. **Verify Installation**
   ```bash
   docker --version
   docker compose version
   ```

#### Step 2: Clone/Download Project
1. **Download the project files** to your local machine
2. **Open Terminal/Command Prompt** and navigate to the project directory:
   ```bash
   cd /path/to/kiwilytics
   ```

#### Step 3: Initial Setup
1. **Run the migration script** to create all necessary files:
   ```bash
   ./vm_to_docker_migration.sh
   ```

2. **Build and start the environment**:
   ```bash
   make quick-setup
   ```

#### Step 4: Verify Installation
1. **Check container status**:
   ```bash
   docker ps
   ```
   You should see two containers running: `kiwilytics-kiwilytics-1` and `kiwilytics-postgres-1`

2. **Access your services**:
   - **Airflow**: http://localhost:8080 (username: `kiwilytics`, password: `kiwilytics`)
   - **Jupyter**: http://localhost:8888
   - **PostgreSQL**: localhost:5433

### For Returning Users (Start Existing Environment)

#### Quick Start Commands
```bash
# Start all services
make up

# View running services
docker ps

# View logs
make logs

# Stop all services
make down
```

#### If Services Won't Start
1. **Check for port conflicts**:
   ```bash
   lsof -i :8080
   lsof -i :8888
   lsof -i :5432  # Check if local PostgreSQL is running
   lsof -i :5433  # Our Docker PostgreSQL port
   ```

2. **Common issues and solutions**:
   - **Port 5432 in use**: Our setup uses port 5433 to avoid conflicts
   - **Volume mount errors**: Check that `dags/`, `notebooks/`, and `data/` directories exist
   - **Container won't start**: Check logs with `make logs`

3. **Reset and restart**:
   ```bash
   make down
   make up
   ```

4. **Full reset** (if needed):
   ```bash
   make clean
   make build
   make up
   ```

### Manual Control Options
```bash
# Build Docker images
make build

# Start services
make up

# View logs
make logs

# Stop services
make down

# Clean everything (containers, volumes, images)
make clean
```

## Access Points

Once running, access your environment at:

### **Airflow Web UI**
- **URL**: http://localhost:8080
- **Username**: `kiwilytics`
- **Password**: `kiwilytics`

### **Jupyter Notebook**
- **URL**: http://localhost:8888
- **Authentication**: No authentication required

### **PostgreSQL Database**
- **Host**: `localhost`
- **Port**: `5433`
- **Database**: `retaildb`
- **Username**: `kiwilytics`
- **Password**: `kiwilytics`

#### **DBeaver Connection Settings**
When setting up a new connection in DBeaver:
1. **Connection Type**: PostgreSQL
2. **Host**: `localhost`
3. **Port**: `5433`
4. **Database**: `retaildb`
5. **Username**: `kiwilytics`
6. **Password**: `kiwilytics`
7. **Save Password**: Check this option for convenience

## Project Structure

```
kiwilytics/
├── docker-compose.yml      # Docker services configuration
├── Dockerfile             # Kiwilytics container definition
├── Makefile               # Build and deployment commands
├── vm_to_docker_migration.sh  # Migration script
├── README.md              # Project documentation and quick start guide
├── docs/                  # Documentation folder
│   ├── MIGRATION_GUIDE.md # Detailed migration instructions
│   └── SETUP_GUIDE.md     # Complete setup and usage guide
├── extracted/             # Data extracted from VM (if available)
│   ├── airflow/dags/     # Airflow DAGs from VM
│   └── github/           # Course materials from VM
├── dags/                  # Custom DAGs directory
├── notebooks/             # Jupyter notebooks
└── data/                  # Data files
```

## Technical Specifications

### Current Version Details
- **Airflow**: 2.8.1 (stable release with Python 3.11 support)
- **Python**: 3.11-slim
- **PostgreSQL**: 15
- **Pendulum**: 2.1.2 (pinned for compatibility)
- **Flask-Session**: 0.5.0 (required dependency)
- **Pandas**: 2.1.3
- **Matplotlib**: 3.8.2
- **Jupyter**: 1.0.0

### Port Configuration
- **Airflow Web UI**: 8080
- **Jupyter Notebook**: 8888
- **PostgreSQL**: 5433 (mapped from container port 5432)

## Prerequisites

- Docker Desktop installed and running
- VirtualBox (optional, for VM data extraction)
- Make (usually pre-installed on macOS)

## Documentation

- **[docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md)** - Complete step-by-step setup and usage guide
- **[docs/MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md)** - VM to Docker migration instructions

## Troubleshooting

### Common Issues

1. **Port conflicts**: 
   - Port 5432 often conflicts with local PostgreSQL - our setup uses 5433
   - If ports 8080 or 8888 are in use, modify `docker-compose.yml`
2. **Volume mount errors**: 
   - Ensure `dags/`, `notebooks/`, and `data/` directories exist
   - Check for conflicting volume mounts in `docker-compose.yml`
3. **Permission issues**: Ensure Docker has access to the project directory
4. **Build failures**: Check Docker logs with `make logs`

### Reset Environment
```bash
make clean    # Remove all containers and volumes
make build    # Rebuild from scratch
make up       # Start fresh
```

## Benefits Over VM

- **90% faster startup** (seconds vs minutes)
- **70% less disk usage** (2GB vs 8GB+)
- **Better resource efficiency**
- **Easier sharing and deployment**
- **Modern development practices**
- **Cross-platform compatibility**

## Support

For issues or questions:
1. Check the logs: `make logs`
2. Review the migration guide: `docs/MIGRATION_GUIDE.md`
3. Reset and rebuild: `make clean && make build`


## Important Notice

To ensure a smooth migration and access to all required datasets, please download the `Kiwilytics_VM.ova` file and place it in the root directory of the `Kiwilytics_DE_Docker` project (e.g., `/path/to/Kiwilytics_DE_Docker`). This step is required for extracting legacy data and materials from the original virtual machine environment.