#!/bin/bash
set -e

IMAGE_TAG=${1:-latest}
PROJECT_ID="stunning-cell-465612-n8"
IMAGE_URL="us-east1-docker.pkg.dev/${PROJECT_ID}/realestatemodels/real_estate:${IMAGE_TAG}"

echo "Deploying ML serving infrastructure with image: ${IMAGE_URL}"

# Stop existing containers
docker stop tensorflow-serving 2>/dev/null || true
docker stop web-server 2>/dev/null || true

# Remove existing containers
docker rm tensorflow-serving 2>/dev/null || true
docker rm web-server 2>/dev/null || true

# Pull latest image
docker pull ${IMAGE_URL}

# Start TensorFlow Serving container
echo "Starting TensorFlow Serving..."
docker run -d \
  --name tensorflow-serving \
  --restart unless-stopped \
  -p 8501:8501 \
  ${IMAGE_URL} \
  --rest_api_port=8501 \
  --model_name=real_estate_price_model \
  --model_base_path=/models/real_estate_price_model \
  --rest_api_enable_cors_support=true

# Wait for TensorFlow Serving to be ready
echo "Waiting for TensorFlow Serving to start..."
sleep 10

# Start web server
echo "Starting web server..."
nohup python3 -m http.server 8000 > web_server.log 2>&1 &
echo $! > web_server.pid

# Health check
echo "Running health checks..."
sleep 5

if curl -f http://localhost:8501/v1/models/real_estate_price_model/metadata; then
  echo "✅ TensorFlow Serving is healthy"
else
  echo "❌ TensorFlow Serving health check failed"
  exit 1
fi

if curl -f http://localhost:8000/index.html; then
  echo "✅ Web server is healthy"
else
  echo "❌ Web server health check failed"
  exit 1
fi

echo "🚀 Deployment completed successfully!"
