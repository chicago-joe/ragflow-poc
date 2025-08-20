#!/bin/bash

# RAGFlow Complete Setup Script
# This script sets up Ollama + RAGFlow with GPU support and development container

echo "=== RAGFlow Complete Setup (Ollama + GPU + Dev) ==="
echo ""

# Parse command line arguments
FORCE_CPU=false
SKIP_OLLAMA=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --cpu)
      FORCE_CPU=true
      shift
      ;;
    --skip-ollama)
      SKIP_OLLAMA=true
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --cpu           Force CPU-only mode (disable GPU)"
      echo "  --skip-ollama   Skip Ollama setup (assume already running)"
      echo "  --help          Show this help message"
      echo ""
      echo "This script will:"
      echo "  • Set up Ollama with llama3.2 and bge-m3 models"
      echo "  • Start RAGFlow with GPU support (if available)"
      echo "  • Enable development container for PyCharm/Jupyter"
      echo "  • Configure all API keys and model settings"
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

# Auto-detect GPU availability
USE_GPU=false
if [[ "$FORCE_CPU" != "true" ]]; then
    if command -v nvidia-smi &> /dev/null && nvidia-smi > /dev/null 2>&1; then
        USE_GPU=true
        echo "🎮 NVIDIA GPU detected! Enabling GPU acceleration."
        
        # Check for nvidia-container-runtime
        if ! docker info 2>/dev/null | grep -q nvidia; then
            echo "⚠️  Warning: nvidia-container-runtime not detected in Docker."
            echo "   GPU support may not work properly."
            echo "   Install nvidia-container-toolkit: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
        fi
    else
        echo "ℹ️  No GPU detected or nvidia-smi not available. Using CPU mode."
    fi
else
    echo "🖥️  CPU mode forced."
fi

# Set compose file based on GPU availability
if [[ "$USE_GPU" == "true" ]]; then
    COMPOSE_FILE="docker-compose-gpu.yml"
    echo "📋 Using GPU configuration: $COMPOSE_FILE"
else
    COMPOSE_FILE="docker-compose.yml"
    echo "📋 Using CPU configuration: $COMPOSE_FILE"
fi

# Setup Ollama
if [[ "$SKIP_OLLAMA" != "true" ]]; then
    echo ""
    echo "🤖 Setting up Ollama..."
    
    # Check if Ollama container already exists
    if docker ps -a --format "table {{.Names}}" | grep -q "^ollama$"; then
        echo "ℹ️  Ollama container already exists. Stopping and removing..."
        docker stop ollama > /dev/null 2>&1 || true
        docker rm ollama > /dev/null 2>&1 || true
    fi
    
    # Start Ollama container
    echo "🚀 Starting Ollama container..."
    if [[ "$USE_GPU" == "true" ]]; then
        # Start Ollama with GPU support
        docker run -d --name ollama --gpus all -p 11434:11434 --restart unless-stopped ollama/ollama
    else
        # Start Ollama in CPU mode
        docker run -d --name ollama -p 11434:11434 --restart unless-stopped ollama/ollama
    fi
    
    # Wait for Ollama to start
    echo "⏳ Waiting for Ollama to start..."
    sleep 15
    
    # Test Ollama connectivity
    echo "🔍 Testing Ollama connectivity..."
    max_attempts=30
    attempt=1
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:11434/ > /dev/null; then
            echo "✅ Ollama is accessible at http://localhost:11434/"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Error: Cannot connect to Ollama after $max_attempts attempts."
            echo "Please check if the container is running: docker logs ollama"
            exit 1
        fi
        
        echo "   Attempt $attempt/$max_attempts..."
        sleep 2
        ((attempt++))
    done
    
    # Pull required models
    echo "📦 Pulling Ollama models..."
    echo "   This may take several minutes depending on your internet connection..."
    
    echo "📥 Pulling llama3.2 for chat..."
    if ! docker exec ollama ollama pull llama3.2; then
        echo "❌ Error: Failed to pull llama3.2 model"
        exit 1
    fi
    
    echo "📥 Pulling bge-m3 for embeddings..."
    if ! docker exec ollama ollama pull bge-m3; then
        echo "❌ Error: Failed to pull bge-m3 model"
        exit 1
    fi
    
    # Test model availability
    echo "🧪 Verifying models..."
    docker exec ollama ollama list
    
    # Connect Ollama to RAGFlow network for internal communication
    echo "🔗 Connecting Ollama to RAGFlow network..."
    docker network connect docker_ragflow ollama 2>/dev/null || echo "   (Already connected or network not found)"
    
    echo "✅ Ollama setup complete!"
else
    echo "⏭️  Skipping Ollama setup"
    
    # Still test connectivity if skipping
    if curl -s http://localhost:11434/ > /dev/null; then
        echo "✅ Ollama is accessible at http://localhost:11434/"
    else
        echo "⚠️  Warning: Ollama not accessible. Make sure it's running before starting RAGFlow."
    fi
fi

echo ""
echo "🏗️  Setting up RAGFlow..."

# Set proper permissions for volume directories
echo "📁 Setting up volume directories..."
mkdir -p ./volumes/{esdata01,osdata01,infinity_data,mysql_data,minio_data,redis_data,ragflow_data,ragflow_uploads}
mkdir -p ./volumes/{dev_workspace,dev_notebooks,dev_data,dev_scripts}
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
echo "• Dev Container: Enabled"
echo "• Ollama: $(if [[ "$SKIP_OLLAMA" == "true" ]]; then echo "External"; else echo "Integrated"; fi)"
echo "• UI Port: $(grep SVR_HTTP_PORT .env | cut -d'=' -f2)"
echo "• MySQL Port: $(grep MYSQL_PORT .env | cut -d'=' -f2)"
echo "• MinIO Console Port: $(grep MINIO_CONSOLE_PORT .env | cut -d'=' -f2)"
echo "• Elasticsearch Port: $(grep ES_PORT .env | cut -d'=' -f2)"
echo "• Redis Port: $(grep REDIS_PORT .env | cut -d'=' -f2)"
echo ""

# Start the services
echo "🚀 Starting RAGFlow services..."
docker-compose -f "$COMPOSE_FILE" down
docker-compose -f "$COMPOSE_FILE" pull
docker-compose -f "$COMPOSE_FILE" up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 45

# Check service status
echo ""
echo "=== Service Status ==="
docker-compose -f "$COMPOSE_FILE" ps

echo ""
echo "🎉 Complete setup finished!"
echo ""

# Show comprehensive access information
echo "=== Access Information ==="
echo "🌐 RAGFlow UI: http://localhost:8080"
echo "📧 Login: admin@ragflow.io"
echo "🔐 Password: admin"
echo "⚠️  IMPORTANT: Change the admin password after first login!"
echo ""
echo "🤖 Ollama API: http://localhost:11434"
echo "📚 RAGFlow API: http://localhost:$(grep SVR_HTTP_PORT .env | cut -d'=' -f2)"
echo "📊 MinIO Console: http://localhost:$(grep MINIO_CONSOLE_PORT .env | cut -d'=' -f2)"
echo "🔍 Elasticsearch: http://localhost:$(grep ES_PORT .env | cut -d'=' -f2)"
echo ""
echo "🛠️  Development Environment:"
echo "• Jupyter Lab: http://localhost:8888 (if START_JUPYTER=true in .env)"
echo "• PyCharm SSH: localhost:2222 (user: root, pass: ragflow123)"
echo ""

echo "=== API Configuration ==="
echo "🔑 RAGFlow API Key Setup:"
echo "   1. Login to RAGFlow UI"
echo "   2. Click avatar → API page"
echo "   3. Generate/copy your API key"
echo "   4. Use: Authorization: Bearer YOUR_API_KEY"
echo ""
echo "🤖 Model Configuration:"
echo "   • Chat Model: llama3.2"
echo "   • Embedding Model: bge-m3"
echo "   • Ollama API Key: [Configure in .env file]"
echo "   • HF Token: [Configure in .env file]"
echo ""

echo "=== Useful Commands ==="
echo "🔍 Check logs:"
echo "   docker-compose -f $COMPOSE_FILE logs -f ragflow"
echo "   docker logs ollama"
echo ""
echo "🛑 Stop services:"
echo "   docker-compose -f $COMPOSE_FILE down"
echo "   docker stop ollama"
echo ""
echo "🔄 Restart services:"
echo "   docker-compose -f $COMPOSE_FILE restart"
echo "   docker restart ollama"
echo ""

if [[ "$USE_GPU" == "true" ]]; then
    echo "🎮 GPU acceleration enabled for faster inference!"
    echo ""
fi

echo "📁 All data persists in: ./volumes/"
echo "🚀 Setup complete! RAGFlow is ready for development and production use."
echo ""

# Final connectivity test
echo "=== Final Connectivity Tests ==="
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ RAGFlow UI is accessible"
else
    echo "⚠️  RAGFlow UI not yet ready, may need a few more minutes"
fi

if curl -s http://localhost:11434/ > /dev/null; then
    echo "✅ Ollama API is accessible"
else
    echo "❌ Ollama API not accessible"
fi

echo ""
echo "Happy coding! 🚀"