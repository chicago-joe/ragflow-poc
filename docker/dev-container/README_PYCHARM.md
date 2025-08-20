# PyCharm Remote Development with RAGFlow

This development container provides a complete Python data science environment with RAGFlow SDK integration for PyCharm remote development.

## 🚀 Quick Start

### 1. Start the Development Environment

```bash
# Start with CPU mode
./setup_local_dev.sh

# Or with GPU mode  
./setup_local_dev.sh --gpu

# To start with Jupyter Lab enabled
START_JUPYTER=true ./setup_local_dev.sh --gpu
```

### 2. Configure PyCharm Remote Development

#### SSH Connection Details:
- **Host**: `localhost`
- **Port**: `2222`
- **Username**: `root`
- **Password**: `ragflow123`

#### PyCharm Setup Steps:

1. **Open PyCharm Professional**
2. **File → Remote Development → SSH Connection**
3. **Configure Connection:**
   - Host: `localhost`
   - Port: `2222`
   - Username: `root` 
   - Password: `ragflow123`
4. **Set Remote Project Path:** `/workspace`
5. **Configure Python Interpreter:** `/workspace/.venv/bin/python`

### 3. Set RAGFlow API Key

1. **Generate API Key:**
   - Visit RAGFlow UI: http://localhost:8080
   - Login: admin@ragflow.io / admin
   - Go to Avatar → API → Generate Key

2. **Set Environment Variable:**
   ```bash
   # Edit .env file
   RAGFLOW_API_KEY=your-api-key-here
   ```

3. **Restart Container:**
   ```bash
   docker-compose restart ragflow-dev
   ```

## 📁 Project Structure

```
/workspace/
├── app/           # Your application code
├── notebooks/     # Jupyter notebooks
├── data/          # Data files
├── scripts/       # Utility scripts
└── .venv/         # Python virtual environment
```

## 🛠️ Available Tools

### Data Science Stack:
- **pandas, numpy, scipy** - Data manipulation & analysis
- **matplotlib, seaborn, plotly** - Data visualization  
- **scikit-learn, statsmodels** - Machine learning & statistics
- **jupyter, ipython** - Interactive development
- **dask, polars** - Big data processing

### Development Tools:
- **black, isort, pylint** - Code formatting & linting
- **pytest** - Testing framework
- **python-lsp-server** - Language server for IDE support
- **debugpy** - Python debugging

### RAGFlow Integration:
- **ragflow-sdk** - RAGFlow Python SDK
- **Helper scripts** in `/workspace/scripts/ragflow_helper.py`

## 🔧 Usage Examples

### RAGFlow SDK Usage:
```python
import os
from ragflow_sdk import RAGFlow

# Initialize client
rag = RAGFlow(
    api_key=os.getenv("RAGFLOW_API_KEY"), 
    base_url="http://ragflow:9380"
)

# List datasets
datasets = rag.list_datasets()
print(f"Found {len(datasets)} datasets")

# Create dataset
dataset = rag.create_dataset(name="my_dataset")

# Upload document
dataset.upload_documents([
    {'display_name': 'doc.txt', 'blob': open('doc.txt', 'rb').read()}
])
```

### Jupyter Lab Access:
- **URL**: http://localhost:8888
- **Start**: Set `START_JUPYTER=true` in .env file

### SSH Commands:
```bash
# SSH into container
ssh root@localhost -p 2222

# Copy files to container
scp -P 2222 local_file.py root@localhost:/workspace/app/

# Run Python in container
ssh root@localhost -p 2222 "cd /workspace && python app/my_script.py"
```

## 🐛 Troubleshooting

### Connection Issues:
```bash
# Check container status
docker-compose ps ragflow-dev

# Check logs
docker-compose logs ragflow-dev

# Restart container
docker-compose restart ragflow-dev
```

### Permission Issues:
```bash
# Fix volume permissions
sudo chown -R 1000:1000 ./volumes/dev_*
```

### Package Installation:
```bash
# SSH into container
ssh root@localhost -p 2222

# Activate environment and install packages
source /workspace/.venv/bin/activate
uv pip install your-package
```

## 💡 Tips

1. **PyCharm Synchronization**: Enable automatic upload for real-time sync
2. **Environment Variables**: Use PyCharm's run configurations to set env vars
3. **Debugging**: Use PyCharm's remote debugging with the pre-installed debugpy
4. **Version Control**: Git is pre-installed in the container
5. **Data Persistence**: All files in `/workspace/app`, `/workspace/notebooks`, `/workspace/data` persist between container restarts

## 🔐 Security Notes

- The SSH password is for development only
- Change the default password in production environments
- Consider using SSH keys instead of passwords for enhanced security
- The container runs as root for simplicity - consider non-root setup for production