#  VM to Docker Migration Guide

## Recommended Approach

Instead of extracting the .ova file (which has compatibility issues), use this approach:

### Option A: Direct Migration (Recommended)
```bash
# 1. Run the migration script
./vm_to_docker_migration.sh

# 2. Build and start
make migrate
```

### Option B: Manual Migration
If automatic extraction fails:

1. **Start your VM and extract data manually:**
   ```bash
   # In VM terminal
   pg_dump -U kiwilytics retaildb > /tmp/retaildb_backup.sql
   tar -czf /tmp/vm_data.tar.gz /home/kiwilytics/airflow/dags /home/kiwilytics/Desktop/github
   ```

2. **Copy files to your Docker project:**
   ```bash
   # Copy from VM to your Mac
   scp kiwilytics@VM_IP:/tmp/retaildb_backup.sql ./
   scp kiwilytics@VM_IP:/tmp/vm_data.tar.gz ./
   
   # Extract
   tar -xzf vm_data.tar.gz
   mv home/kiwilytics/airflow/dags ./extracted/airflow/
   mv home/kiwilytics/Desktop/github ./extracted/
   ```

3. **Start Docker environment:**
   ```bash
   make build up
   ```

### Option C: Fresh Start (Easiest)
If you don't need the existing VM data:
```bash
make quick-setup
```

## 🔧 Why This Is Better Than .ova Extraction

| Issue | .ova Extraction | This Approach |
|-------|----------------|---------------|
| **Filesystem compatibility** | ❌ Linux ext4 on macOS | ✅ Standard file copy |
| **Database migration** | ❌ Binary incompatibility | ✅ SQL dump/restore |
| **Permissions** | ❌ UID/GID conflicts | ✅ Proper user setup |
| **Dependencies** | ❌ System-level configs | ✅ Clean environment |
| **Maintenance** | ❌ Complex debugging | ✅ Standard Docker |

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

## Benefits of Docker Approach

- **90% faster startup** (seconds vs minutes)
- **70% less disk usage** (2GB vs 8GB+)
- **Better resource efficiency**
- **Easier sharing and deployment**
- **Modern development practices**
