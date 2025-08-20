# PyCharm Docker Compose Python Interpreter Setup

This guide walks you through configuring PyCharm Professional to use the RAGFlow development container as a Python interpreter via Docker Compose.

## 🔧 Prerequisites

- **PyCharm Professional** (Docker Compose integration requires Pro version)
- **Docker Desktop** or **Docker Engine** with Docker Compose
- **RAGFlow development environment** set up

## 📁 Project Structure

The Docker development environment provides:

```
docker/
├── docker-compose.yml           # Main compose file with ragflow-dev service
├── dev-container/
│   ├── Dockerfile              # Python 3.11 development container
│   ├── pyproject.toml          # Python dependencies
│   └── README_PYCHARM.md       # Detailed setup instructions
├── volumes/
│   ├── dev_workspace/          # Your application code (mounted to /workspace/app)
│   ├── dev_notebooks/          # Jupyter notebooks (mounted to /workspace/notebooks)
│   ├── dev_data/              # Data files (mounted to /workspace/data)
│   └── dev_scripts/           # Utility scripts (mounted to /workspace/scripts)
└── .env                       # Environment configuration
```

## 🚀 PyCharm Configuration Steps

### 1. Start the Development Environment

```bash
cd docker
docker-compose up -d ragflow-dev
```

### 2. Configure PyCharm Docker Compose Interpreter

#### Step 2.1: Open Interpreter Settings
1. **File** → **Settings** (or **PyCharm** → **Preferences** on macOS)
2. Navigate to **Project** → **Python Interpreter**
3. Click the **⚙️ gear icon** → **Add...**

#### Step 2.2: Select Docker Compose
1. Choose **Docker Compose** from the left panel
2. **Configuration files**: Browse and select your `docker-compose.yml`:
   ```
   /path/to/your/project/ragflow/docker/docker-compose.yml
   ```
3. **Service**: Select `ragflow-dev`
4. **Environment variables**: Add if needed (optional)

#### Step 2.3: Configure Python Interpreter Path
1. **Python interpreter path**: Set to:
   ```
   /workspace/.venv/bin/python
   ```
2. **Working directory**: Set to:
   ```
   /workspace
   ```

#### Step 2.4: Path Mappings (Automatic)
PyCharm should automatically detect these mappings:
```
Local Path                                    → Container Path
/path/to/ragflow/docker/volumes/dev_workspace → /workspace/app
/path/to/ragflow/docker/volumes/dev_notebooks → /workspace/notebooks
/path/to/ragflow/docker/volumes/dev_data      → /workspace/data
/path/to/ragflow/docker/volumes/dev_scripts   → /workspace/scripts
```

### 3. Verify Configuration

#### Test Python Environment:
```python
import sys
print(f"Python: {sys.version}")
print(f"Executable: {sys.executable}")

# Test RAGFlow SDK
from ragflow_sdk import RAGFlow
print("RAGFlow SDK available!")

# Test data science libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
print("Data science stack ready!")
```

## 🔧 Container Specifications

### Python Environment
- **Python Version**: 3.11.13
- **Virtual Environment**: `/workspace/.venv/`
- **Interpreter Path**: `/workspace/.venv/bin/python`
- **PYTHONPATH**: `/workspace:/workspace/app`

### Key Features
- **RAGFlow SDK**: Pre-installed for API integration
- **Data Science Stack**: pandas, numpy, matplotlib, seaborn, plotly, scikit-learn
- **Development Tools**: black, isort, pylint, pytest
- **Jupyter Lab**: Available on port 8888 (if enabled)
- **SSH Access**: Port 2222 (for alternative remote development)

### Volume Mappings
| Host Directory | Container Path | Purpose |
|---------------|----------------|---------|
| `./volumes/dev_workspace` | `/workspace/app` | Main application code |
| `./volumes/dev_notebooks` | `/workspace/notebooks` | Jupyter notebooks |
| `./volumes/dev_data` | `/workspace/data` | Data files |
| `./volumes/dev_scripts` | `/workspace/scripts` | Utility scripts |

## 🎯 Development Workflow

### 1. Code Development
- Place your main Python code in: `docker/volumes/dev_workspace/`
- This maps to `/workspace/app` in the container
- PyCharm will sync changes automatically

### 2. RAGFlow Integration
```python
import os
from ragflow_sdk import RAGFlow

# Environment variables are pre-configured
rag = RAGFlow(
    api_key=os.getenv("RAGFLOW_API_KEY"),
    base_url=os.getenv("RAGFLOW_API_URL", "http://ragflow:9380")
)

# Your RAGFlow development code here
datasets = rag.list_datasets()
```

### 3. Data Science Work
- Use Jupyter notebooks in: `docker/volumes/dev_notebooks/`
- Store data files in: `docker/volumes/dev_data/`
- Access via container path: `/workspace/notebooks` and `/workspace/data`

## 🔧 Environment Configuration

### Required Environment Variables (.env file):
```bash
# RAGFlow API Configuration
RAGFLOW_API_KEY=your-api-key-here

# Development Options
START_JUPYTER=false
START_IPYTHON=false

# Other RAGFlow configuration...
```

### To Get RAGFlow API Key:
1. Start RAGFlow: `docker-compose up -d ragflow`
2. Visit: http://localhost:8080
3. Login with: `admin@ragflow.io` / `admin`
4. Go to: **Avatar** → **API** → **Generate Key**
5. Add key to `.env` file and restart container

## 🐛 Troubleshooting

### Container Issues:
```bash
# Check container status
docker-compose ps ragflow-dev

# View logs
docker-compose logs ragflow-dev

# Restart container
docker-compose restart ragflow-dev

# Rebuild if needed
docker-compose build ragflow-dev
```

### PyCharm Issues:
1. **Interpreter not found**: Verify path is `/workspace/.venv/bin/python`
2. **Module not found**: Check PYTHONPATH includes `/workspace` and `/workspace/app`
3. **Connection issues**: Ensure container is running and healthy
4. **Performance**: Consider allocating more resources to Docker

### Permission Issues:
```bash
# Fix volume permissions (Linux/macOS)
sudo chown -R $USER:$USER ./volumes/
```

## 🎉 Success Validation

Your setup is working correctly when:

✅ PyCharm shows Python 3.11.13 interpreter  
✅ Can import `ragflow_sdk` without errors  
✅ Can import data science libraries (pandas, numpy, etc.)  
✅ Code completion and debugging work in PyCharm  
✅ File changes sync between host and container  
✅ Can run scripts and tests through PyCharm  

## 📚 Additional Resources

- [PyCharm Docker Compose Integration](https://www.jetbrains.com/help/pycharm/using-docker-compose-as-a-remote-interpreter.html)
- [RAGFlow Documentation](https://ragflow.io/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

**Note**: This configuration is optimized for development. For production deployments, consider security hardening and resource optimization.