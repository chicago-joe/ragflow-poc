#!/bin/bash

# RAGFlow Ollama Setup Script
# This script sets up Ollama for use with RAGFlow

echo "=== RAGFlow Ollama Setup ==="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"

# Start Ollama container
echo "🚀 Starting Ollama container..."
docker run -d --name ollama -p 11434:11434 --restart unless-stopped ollama/ollama

# Wait for Ollama to start
echo "⏳ Waiting for Ollama to start..."
sleep 10

# Test Ollama connectivity
echo "🔍 Testing Ollama connectivity..."
if curl -s http://localhost:11434/ > /dev/null; then
    echo "✅ Ollama is accessible at http://localhost:11434/"
else
    echo "❌ Error: Cannot connect to Ollama. Please check if the container is running."
    exit 1
fi

# Pull required models
echo "📦 Pulling Ollama models..."
echo "Pulling llama3.2 for chat..."
docker exec ollama ollama pull llama3.2

echo "Pulling bge-m3 for embeddings..."
docker exec ollama ollama pull bge-m3

# Test model availability
echo "🧪 Testing model availability..."
docker exec ollama ollama list

echo ""
echo "🎉 Ollama setup complete!"
echo ""
echo "📋 Configuration Summary:"
echo "  • Ollama URL: http://localhost:11434"
echo "  • Chat Model: llama3.2"
echo "  • Embedding Model: bge-m3"
echo "  • API Key: [Your Ollama API Key]"
echo ""
echo "🚀 Next steps:"
echo "  1. Run ./setup_local_dev.sh to start RAGFlow"
echo "  2. Access RAGFlow UI at http://localhost:8080"
echo "  3. Login with admin@ragflow.io / admin"
echo "  4. The Ollama models should be automatically configured"
echo ""
echo "🔧 Manual model configuration (if needed):"
echo "  1. Go to Settings -> Model Providers"
echo "  2. Add Ollama provider:"
echo "     - Base URL: http://host.docker.internal:11434/v1"
echo "     - API Key: [Your Ollama API Key]"
echo "  3. Select models: llama3.2 (chat), bge-m3 (embedding)"
echo ""