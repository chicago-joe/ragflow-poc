    **RAGFlow Configuration Summary for Project Memory:**

    **Complete RAGFlow + Ollama + HuggingFace Configuration**

    **API Keys:**
    - Hugging Face Token: `[Configure in .env file]`
    - Ollama API Key: `[Configure in .env file]`

    **Models Configured:**
    - Chat Model: llama3.2
    - Embedding Model: bge-m3
    - Image2Text Model: llama3.2

    **Network Configuration:**
    - Ollama Container: Connected to docker_ragflow network
    - Internal Communication URL: http://ollama:11434/v1
    - External Access URL: http://localhost:11434

    **Access Points:**
    - RAGFlow UI: http://localhost:8080 (admin@ragflow.io / admin)
    - RAGFlow API: http://localhost:9380
    - Development SSH: localhost:2222 (root / ragflow123)
    - Jupyter Lab: http://localhost:8888 (if enabled)

    **Setup Command:**
    ```bash
    ./setup_complete.sh  # Automated setup with GPU detection and dev container
    ```

    **Key Configuration Files:**
    - `.env`: Contains API keys and model settings
    - `service_conf.yaml.template`: Enables automatic model configuration for new users
    - `setup_complete.sh`: Complete automation script for deployment

    **Critical Fix Applied:**
    Docker network connectivity issue resolved by connecting Ollama container to RAGFlow network and updating base URL from host.docker.internal to container name (ollama)..
