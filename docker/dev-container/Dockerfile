# RAGFlow Development Environment
# Python 3.11 with data science tools and RAGFlow SDK
FROM python:3.11-bullseye

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV DEBIAN_FRONTEND=noninteractive
ENV UV_CACHE_DIR=/root/.cache/uv

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    wget \
    openssh-server \
    rsync \
    sqlite3 \
    postgresql-client \
    default-mysql-client \
    redis-tools \
    graphviz \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    pkg-config \
    libhdf5-dev \
    libssl-dev \
    libffi-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

# Install UV (fast Python package installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Create workspace directory
WORKDIR /workspace

# Create project structure
RUN mkdir -p /workspace/app /workspace/notebooks /workspace/data /workspace/scripts

# Copy project configuration files
COPY pyproject.toml /workspace/

# Install Python dependencies using UV
RUN uv venv /workspace/.venv && \
    . /workspace/.venv/bin/activate && \
    uv pip install --no-cache-dir -r /workspace/pyproject.toml

# Install RAGFlow SDK
RUN . /workspace/.venv/bin/activate && \
    uv pip install ragflow-sdk

# Configure SSH for PyCharm remote development
RUN mkdir /var/run/sshd && \
    echo 'root:ragflow123' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Create startup script
RUN echo '#!/bin/bash\n\
# Start SSH daemon\n\
/usr/sbin/sshd -D &\n\
\n\
# Activate virtual environment\n\
source /workspace/.venv/bin/activate\n\
\n\
# Set environment variables for RAGFlow\n\
export RAGFLOW_API_URL=${RAGFLOW_API_URL:-http://ragflow:9380}\n\
export RAGFLOW_API_KEY=${RAGFLOW_API_KEY:-}\n\
\n\
# Start Jupyter Lab if requested\n\
if [ "$START_JUPYTER" = "true" ]; then\n\
    echo "Starting Jupyter Lab..."\n\
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root \\\n\
        --NotebookApp.token="" --NotebookApp.password="" &\n\
fi\n\
\n\
# Start IPython if requested\n\
if [ "$START_IPYTHON" = "true" ]; then\n\
    echo "Starting IPython..."\n\
    ipython --no-confirm-exit\n\
    exit\n\
fi\n\
\n\
echo "RAGFlow Development Environment Ready!"\n\
echo "SSH: Port 2222, User: root, Password: ragflow123"\n\
echo "RAGFlow API: $RAGFLOW_API_URL"\n\
if [ "$START_JUPYTER" = "true" ]; then\n\
    echo "Jupyter Lab: http://localhost:8888"\n\
fi\n\
\n\
# Keep container running\n\
tail -f /dev/null\n\
' > /start.sh && chmod +x /start.sh

# Configure Python path and virtual environment activation
RUN echo 'source /workspace/.venv/bin/activate' >> /root/.bashrc && \
    echo 'export PYTHONPATH=/workspace:/workspace/app:$PYTHONPATH' >> /root/.bashrc && \
    echo 'cd /workspace' >> /root/.bashrc

# Create sample RAGFlow connection script
RUN echo '#!/usr/bin/env python3\n\
"""\n\
RAGFlow API Connection Helper\n\
Usage: python ragflow_helper.py\n\
"""\n\
\n\
import os\n\
from ragflow_sdk import RAGFlow\n\
\n\
def get_ragflow_client():\n\
    """Initialize RAGFlow client with environment variables"""\n\
    api_url = os.getenv("RAGFLOW_API_URL", "http://ragflow:9380")\n\
    api_key = os.getenv("RAGFLOW_API_KEY")\n\
    \n\
    if not api_key:\n\
        print("Warning: RAGFLOW_API_KEY not set. Generate one from RAGFlow UI.")\n\
        print("Visit: http://localhost:8080 -> Avatar -> API")\n\
        return None\n\
    \n\
    try:\n\
        rag = RAGFlow(api_key=api_key, base_url=api_url)\n\
        print(f"Connected to RAGFlow at {api_url}")\n\
        return rag\n\
    except Exception as e:\n\
        print(f"Failed to connect to RAGFlow: {e}")\n\
        return None\n\
\n\
def test_connection():\n\
    """Test RAGFlow connection and list datasets"""\n\
    rag = get_ragflow_client()\n\
    if not rag:\n\
        return\n\
    \n\
    try:\n\
        datasets = rag.list_datasets()\n\
        print(f"Found {len(datasets)} datasets:")\n\
        for ds in datasets[:5]:  # Show first 5\n\
            print(f"  - {ds.name} (ID: {ds.id})")\n\
    except Exception as e:\n\
        print(f"Error listing datasets: {e}")\n\
\n\
if __name__ == "__main__":\n\
    test_connection()\n\
' > /workspace/scripts/ragflow_helper.py && chmod +x /workspace/scripts/ragflow_helper.py

# Create sample notebook
RUN echo '{\n\
 "cells": [\n\
  {\n\
   "cell_type": "markdown",\n\
   "metadata": {},\n\
   "source": [\n\
    "# RAGFlow Data Science Environment\\n",\n\
    "\\n",\n\
    "This notebook demonstrates the RAGFlow SDK and data science tools."\n\
   ]\n\
  },\n\
  {\n\
   "cell_type": "code",\n\
   "execution_count": null,\n\
   "metadata": {},\n\
   "source": [\n\
    "# Import essential libraries\\n",\n\
    "import pandas as pd\\n",\n\
    "import numpy as np\\n",\n\
    "import matplotlib.pyplot as plt\\n",\n\
    "import seaborn as sns\\n",\n\
    "import plotly.express as px\\n",\n\
    "from ragflow_sdk import RAGFlow\\n",\n\
    "import os\\n",\n\
    "\\n",\n\
    "print(\\"Environment ready!\\")"]\n\
  },\n\
  {\n\
   "cell_type": "code",\n\
   "execution_count": null,\n\
   "metadata": {},\n\
   "source": [\n\
    "# RAGFlow connection example\\n",\n\
    "api_key = os.getenv(\\"RAGFLOW_API_KEY\\")\\n",\n\
    "if api_key:\\n",\n\
    "    rag = RAGFlow(api_key=api_key, base_url=\\"http://ragflow:9380\\")\\n",\n\
    "    datasets = rag.list_datasets()\\n",\n\
    "    print(f\\"Connected! Found {len(datasets)} datasets\\")\\n",\n\
    "else:\\n",\n\
    "    print(\\"Set RAGFLOW_API_KEY environment variable\\")"]\n\
  }\n\
 ],\n\
 "metadata": {\n\
  "kernelspec": {\n\
   "display_name": "Python 3",\n\
   "language": "python",\n\
   "name": "python3"\n\
  },\n\
  "language_info": {\n\
   "codemirror_mode": {\n\
    "name": "ipython",\n\
    "version": 3\n\
   },\n\
   "file_extension": ".py",\n\
   "mimetype": "text/x-python",\n\
   "name": "python",\n\
   "nbconvert_exporter": "python",\n\
   "pygments_lexer": "ipython3",\n\
   "version": "3.11.0"\n\
  }\n\
 },\n\
 "nbformat": 4,\n\
 "nbformat_minor": 4\n\
}' > /workspace/notebooks/ragflow_example.ipynb

# Set working directory and expose ports
EXPOSE 2222 8888
WORKDIR /workspace

# Default command
CMD ["/start.sh"]