# PyCharm Quick Setup Guide

## 🎯 Ready-to-Use Configuration

Your RAGFlow Docker development environment is now configured and ready for PyCharm Professional's Docker Compose integration.

## ⚡ Quick Setup Steps

### 1. Start the Environment
```bash
cd /mnt/z/Work/PyCharmProjects/ragflow/docker
docker-compose up -d ragflow-dev
```

### 2. PyCharm Configuration
1. **File** → **Settings** → **Project** → **Python Interpreter**
2. Click **⚙️ Add...** → **Docker Compose**
3. Set these values:

| Field | Value |
|-------|-------|
| **Configuration file** | `/mnt/z/Work/PyCharmProjects/ragflow/docker/docker-compose.yml` |
| **Service** | `ragflow-dev` |
| **Python interpreter path** | `/workspace/.venv/bin/python` |
| **Working directory** | `/workspace` |

## ✅ Verified Configuration

- **Container**: `ragflow-dev` (running and stable)
- **Python**: 3.11.13 in virtual environment
- **Interpreter Path**: `/workspace/.venv/bin/python`
- **PYTHONPATH**: `/workspace:/workspace/app:/workspace/ragflow`
- **Libraries**: RAGFlow SDK, pandas, numpy, matplotlib, seaborn, etc.

## 📁 Volume Mappings

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `./volumes/dev_workspace/` | `/workspace/app/` | Your main code |
| `./volumes/dev_notebooks/` | `/workspace/notebooks/` | Jupyter notebooks |
| `./volumes/dev_data/` | `/workspace/data/` | Data files |
| `./volumes/dev_scripts/` | `/workspace/scripts/` | Utility scripts |
| `../` (project root) | `/workspace/ragflow/` | RAGFlow source (read-only) |

## 🔧 Container Ports

- **SSH**: 2222 (for remote development)
- **Jupyter Lab**: 8888 (if enabled)
- **Debugpy**: 5680 (for remote debugging)

## 🧪 Test Your Setup

Run the test script to verify everything works:
```bash
docker exec ragflow-dev /workspace/.venv/bin/python /workspace/app/test_setup.py
```

## 🚀 Quick Start Example

Create `/workspace/app/hello_ragflow.py`:
```python
#!/usr/bin/env python3
import os
from ragflow_sdk import RAGFlow

def main():
    print("Hello from RAGFlow Development Environment!")
    
    # Check environment
    print(f"Python path: {os.environ.get('PYTHONPATH')}")
    print(f"RAGFlow URL: {os.environ.get('RAGFLOW_API_URL')}")
    
    # Test data science libraries
    import pandas as pd
    import numpy as np
    
    data = pd.DataFrame({
        'x': np.random.randn(100),
        'y': np.random.randn(100)
    })
    
    print(f"Created DataFrame with {len(data)} rows")
    print("Environment ready for development!")

if __name__ == "__main__":
    main()
```

## 📚 Next Steps

1. **Set RAGFlow API Key**: Get from RAGFlow UI → Avatar → API
2. **Start Coding**: Place files in `./volumes/dev_workspace/`
3. **Use Jupyter**: Enable with `START_JUPYTER=true` in `.env`
4. **Debug**: Use port 5680 for remote debugging

Your development environment is now ready for productive RAGFlow development! 🎉