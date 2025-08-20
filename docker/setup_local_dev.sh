#!/bin/bash

# RAGFlow Local Development Setup Script  
# This script sets up RAGFlow for local development with persistent storage and GPU support

echo "=== RAGFlow Local Development Setup ==="
echo ""

# Parse command line arguments
USE_GPU=false
FORCE_CPU=false
INCLUDE_DEV=false
COMPOSE_FILE="docker-compose.yml"

while [[ $# -gt 0 ]]; do
  case $1 in
    --gpu)
      USE_GPU=true
      COMPOSE_FILE="docker-compose-gpu.yml"
      shift
      ;;
    --cpu)
      FORCE_CPU=true
      shift
      ;;
    --dev)
      INCLUDE_DEV=true
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --gpu     Use GPU-enabled Docker Compose configuration"
      echo "  --cpu     Force CPU-only mode"
      echo "  --dev     Include Python development container"
      echo "  --help    Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0              # Auto-detect GPU availability"
      echo "  $0 --gpu        # Force GPU mode"
      echo "  $0 --cpu        # Force CPU mode"
      echo "  $0 --gpu --dev  # GPU mode with development container"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"

# Auto-detect GPU availability if not forced
if [[ "$FORCE_CPU" != "true" ]]; then
    if command -v nvidia-smi &> /dev/null && nvidia-smi > /dev/null 2>&1; then
        if [[ "$USE_GPU" != "true" ]]; then
            echo "🎮 NVIDIA GPU detected! Use --gpu flag to enable GPU acceleration."
            echo "   Running in CPU mode. Use '$0 --gpu' for GPU mode."
        else
            echo "🎮 GPU mode enabled - using NVIDIA GPU acceleration"
        fi
        
        # Check for nvidia-container-runtime
        if ! docker info 2>/dev/null | grep -q nvidia; then
            echo "⚠️  Warning: nvidia-container-runtime not detected in Docker."
            echo "   GPU support may not work properly."
            echo "   Install nvidia-container-toolkit: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
        fi
    else
        if [[ "$USE_GPU" == "true" ]]; then
            echo "⚠️  Warning: GPU mode requested but no NVIDIA GPU detected."
            echo "   Falling back to CPU mode."
            USE_GPU=false
            COMPOSE_FILE="docker-compose.yml"
        fi
    fi
fi

# Set compose file based on final decision
if [[ "$USE_GPU" == "true" ]]; then
    COMPOSE_FILE="docker-compose-gpu.yml"
    echo "📋 Using GPU configuration: $COMPOSE_FILE"
else
    COMPOSE_FILE="docker-compose.yml"
    echo "📋 Using CPU configuration: $COMPOSE_FILE"
fi

# Set proper permissions for volume directories
echo "📁 Setting up volume directories..."
mkdir -p ./volumes/{esdata01,osdata01,infinity_data,mysql_data,minio_data,redis_data,ragflow_data,ragflow_uploads}
sudo chown -R 1000:1000 ./volumes/
chmod -R 755 ./volumes/

echo "✅ Volume directories configured"

# Ensure Docker Compose profiles are set correctly
echo "🔧 Checking environment configuration..."
if grep -q "^COMPOSE_PROFILES=" .env; then
    echo "✅ COMPOSE_PROFILES found in .env"
else
    echo "⚠️  COMPOSE_PROFILES not explicitly set, using default from DOC_ENGINE"
fi

# Display current configuration
echo ""
echo "=== Current Configuration ==="
echo "• Configuration: $COMPOSE_FILE"
echo "• GPU Enabled: $USE_GPU"
echo "• Dev Container: $INCLUDE_DEV"
echo "• UI Port: $(grep SVR_HTTP_PORT .env | cut -d'=' -f2)"
echo "• MySQL Port: $(grep MYSQL_PORT .env | cut -d'=' -f2)"
echo "• MinIO Console Port: $(grep MINIO_CONSOLE_PORT .env | cut -d'=' -f2)"
echo "• Elasticsearch Port: $(grep ES_PORT .env | cut -d'=' -f2)"
echo "• Redis Port: $(grep REDIS_PORT .env | cut -d'=' -f2)"
echo ""

# Show login information
echo "=== RAGFlow UI Login Information ==="
echo "📧 Email: admin@ragflow.io"
echo "🔐 Password: admin"
echo "🌐 RAGFlow UI: http://localhost:8080"
echo ""
echo "⚠️  IMPORTANT: Change the admin password after first login!"
echo ""

# Show API key information
echo "=== RAGFlow API Key Setup ==="
echo "🔑 To use RAGFlow's HTTP/Python APIs:"
echo "   1. Login to RAGFlow UI at http://localhost:8080"
echo "   2. Click your avatar → API page"
echo "   3. Generate/copy your API key"
echo "   4. Use in API calls: Authorization: Bearer YOUR_API_KEY"
echo ""
echo "📚 API Documentation:"
echo "   • RAGFlow UI: http://localhost:8080"
echo "   • HTTP API: http://localhost:$(grep SVR_HTTP_PORT .env | cut -d'=' -f2)/docs"
echo "   • Python SDK: pip install ragflow-sdk"
echo ""

# Start the services
echo "🚀 Starting RAGFlow services..."
docker-compose -f "$COMPOSE_FILE" down
docker-compose -f "$COMPOSE_FILE" pull
docker-compose -f "$COMPOSE_FILE" up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 30

# Check service status
echo ""
echo "=== Service Status ==="
docker-compose -f "$COMPOSE_FILE" ps

echo ""
echo "🎉 Setup complete!"
echo ""
echo "🔍 To check logs:"
echo "   docker-compose -f $COMPOSE_FILE logs -f ragflow"
echo ""
echo "🛑 To stop services:"
echo "   docker-compose -f $COMPOSE_FILE down"
echo ""
echo "📊 Access services:"
echo "   • RAGFlow UI: http://localhost:8080"
echo "   • RAGFlow API: http://localhost:$(grep SVR_HTTP_PORT .env | cut -d'=' -f2)"
echo "   • MinIO Console: http://localhost:$(grep MINIO_CONSOLE_PORT .env | cut -d'=' -f2)"
echo "   • Elasticsearch: http://localhost:$(grep ES_PORT .env | cut -d'=' -f2)"
if [[ "$INCLUDE_DEV" == "true" ]]; then
    echo "   • Jupyter Lab: http://localhost:8888 (if START_JUPYTER=true)"
    echo "   • PyCharm SSH: localhost:2222 (user: root, pass: ragflow123)"
fi
echo ""
echo "📁 Persistent data stored in: ./volumes/"
echo "📋 All uploaded files and work will persist between restarts"
echo ""
if [[ "$USE_GPU" == "true" ]]; then
    echo "🎮 GPU acceleration enabled for faster inference!"
fi