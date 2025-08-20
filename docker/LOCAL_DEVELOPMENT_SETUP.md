# RAGFlow Local Development Setup

This guide provides instructions for setting up RAGFlow locally with persistent storage and networking for development purposes.

## 🔐 Login Information

**RAGFlow UI Default Credentials:**
- **Email:** `admin@ragflow.io`
- **Password:** `admin`
- **URL:** `http://localhost:8080`

⚠️ **IMPORTANT:** Change the admin password after first login!

## 🔑 RAGFlow API Key

**To use RAGFlow's HTTP/Python APIs:**
1. Login to RAGFlow UI
2. Click your avatar in the top right corner
3. Navigate to **API** page
4. Generate/copy your API key
5. Use in API calls: `Authorization: Bearer YOUR_API_KEY`

**API Resources:**
- **RAGFlow UI:** http://localhost:8080
- **HTTP API Endpoint:** http://localhost:9380
- **HTTP API Documentation:** http://localhost:9380/docs  
- **Python SDK:** `pip install ragflow-sdk`
- **Usage Example:**
  ```python
  from ragflow_sdk import RAGFlow
  
  rag = RAGFlow(api_key="YOUR_API_KEY", base_url="http://localhost:9380")
  datasets = rag.list_datasets()
  ```

## 🚀 Quick Start

### CPU Mode (Default)
```bash
./setup_local_dev.sh
```

### GPU Mode (NVIDIA GPU Required)
```bash
./setup_local_dev.sh --gpu
```

### Options
- `--gpu`: Enable NVIDIA GPU acceleration
- `--cpu`: Force CPU-only mode  
- `--help`: Show usage information

The setup script will:
- Auto-detect NVIDIA GPU availability
- Check Docker is running
- Set up volume directories with proper permissions
- Start all RAGFlow services with appropriate configuration
- Display service status

## 🐳 Manual Setup

If you prefer to run commands manually:

1. **Create volume directories:**
   ```bash
   mkdir -p ./volumes/{esdata01,osdata01,infinity_data,mysql_data,minio_data,redis_data,ragflow_data,ragflow_uploads}
   sudo chown -R 1000:1000 ./volumes/
   chmod -R 755 ./volumes/
   ```

2. **Start services:**
   ```bash
   # CPU mode
   docker-compose up -d
   
   # GPU mode (requires nvidia-container-toolkit)
   docker-compose -f docker-compose-gpu.yml up -d
   ```

3. **Check status:**
   ```bash
   docker-compose ps
   ```

## 📁 Persistent Storage

All data is stored in local directories under `./volumes/`:

- **esdata01/**: Elasticsearch data
- **osdata01/**: OpenSearch data  
- **infinity_data/**: Infinity database data
- **mysql_data/**: MySQL database files
- **minio_data/**: MinIO object storage
- **redis_data/**: Redis cache data
- **ragflow_data/**: RAGFlow application data
- **ragflow_uploads/**: User uploaded files

**Benefits:**
- ✅ Data persists between container restarts
- ✅ Data survives `docker-compose down`
- ✅ Easy backup and restore
- ✅ Direct access to data files
- ✅ Version control friendly (data excluded via .gitignore)

## 🌐 Service Ports

- **RAGFlow UI:** http://localhost:8080 (nginx frontend)
- **RAGFlow API:** http://localhost:9380 (direct API access)
- **MinIO Console:** http://localhost:9001
- **Elasticsearch:** http://localhost:1200
- **MySQL:** localhost:5455
- **Redis:** localhost:6379

## 🎮 GPU Support

**Prerequisites for GPU acceleration:**
1. NVIDIA GPU with CUDA support
2. NVIDIA Docker Container Toolkit installed
3. Docker configured to use nvidia runtime

**Install NVIDIA Container Toolkit:**
```bash
# Ubuntu/Debian
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**Test GPU availability:**
```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

## 🛠️ Common Commands

**View logs:**
```bash
# CPU mode
docker-compose logs -f ragflow
docker-compose logs -f mysql

# GPU mode
docker-compose -f docker-compose-gpu.yml logs -f ragflow
```

**Restart specific service:**
```bash
# CPU mode
docker-compose restart ragflow

# GPU mode
docker-compose -f docker-compose-gpu.yml restart ragflow
```

**Stop all services:**
```bash
# CPU mode
docker-compose down

# GPU mode
docker-compose -f docker-compose-gpu.yml down
```

**Remove all containers (data persists):**
```bash
docker-compose down -v
```

**Full cleanup (⚠️ removes all data):**
```bash
docker-compose down -v
sudo rm -rf ./volumes/*
```

## 🔧 Configuration

**Environment variables** are defined in `.env` file:
- `SVR_HTTP_PORT`: RAGFlow UI port (default: 9380)
- `MYSQL_PORT`: MySQL external port (default: 5455)  
- `MYSQL_PASSWORD`: MySQL root password (default: infini_rag_flow)
- `MINIO_USER/PASSWORD`: MinIO credentials (default: rag_flow/infini_rag_flow)

**Service configuration** in `service_conf.yaml.template`:
- Database connections
- Storage settings
- Authentication settings

## 🐛 Troubleshooting

**Services won't start:**
1. Check Docker is running: `docker info`
2. Check ports aren't in use: `netstat -tulpn | grep -E ':(8080|9380)'`
3. Check disk space: `df -h`
4. Check volume permissions: `ls -la ./volumes/`

**Permission errors:**
```bash
sudo chown -R 1000:1000 ./volumes/
chmod -R 755 ./volumes/
```

**Reset everything:**
```bash
docker-compose down -v
sudo rm -rf ./volumes/*
./setup_local_dev.sh
```

## 📊 Health Checks

All services include health checks. View status:
```bash
docker-compose ps
```

Services should show "(healthy)" status when ready.

## 🔄 Updates

**Update RAGFlow:**
```bash
# CPU mode
docker-compose pull
docker-compose down
docker-compose up -d

# GPU mode
docker-compose -f docker-compose-gpu.yml pull
docker-compose -f docker-compose-gpu.yml down
docker-compose -f docker-compose-gpu.yml up -d
```

**Backup data before updates:**
```bash
tar -czf ragflow-backup-$(date +%Y%m%d).tar.gz ./volumes/
```

## 🤝 Development Tips

1. **Log monitoring:** Use `docker-compose logs -f` during development
2. **Quick restarts:** Use `docker-compose restart ragflow` for code changes
3. **Database access:** Connect to MySQL on localhost:5455 with root/infini_rag_flow
4. **File uploads:** Files persist in `./volumes/minio_data/` and `./volumes/ragflow_uploads/`
5. **Configuration changes:** Restart services after modifying `.env` or service configs