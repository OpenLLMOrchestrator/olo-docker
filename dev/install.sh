#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "Creating shared Docker network: olo-net (if needed)..."
if ! docker network inspect olo-net >/dev/null 2>&1; then
  docker network create olo-net
fi

echo "Pulling latest OLO images (olo, olo-worker, olo-ui, olo-chat)..."
docker pull openllmorchestrator/olo:latest
docker pull openllmorchestrator/olo-worker:latest
docker pull openllmorchestrator/olo-ui:latest
docker pull openllmorchestrator/olo-chat:latest

echo "Bringing up full OLO dev stack (project: olo, in sequence: db, cache, elastic, vectordb, temporal, olo, ai-text, ai-image, ai-video, ai-audio)..."

docker compose -p olo \
  -f docker-compose-db.yml \
  -f docker-compose-cache.yml \
  -f docker-compose-ElasticSearch.yml \
  -f docker-compose-vectordb.yml \
  -f docker-compose-temporal.yml \
  -f docker-compose-olo.yml \
  -f docker-compose-ai-text.yml \
  -f docker-compose-ai-image.yml \
  -f docker-compose-ai-video.yml \
  -f docker-compose-ai-audio.yml \
  up -d

echo "Dev OLO stack is up (project: olo)."

echo "Waiting for Ollama, then pulling models (llama3.2, mistral, phi3, etc.)..."
sleep 5
"$(dirname "$0")/scripts/ollama-pull-models.sh" || true

echo "Waiting for LocalAI (openai-oss), then installing models..."
sleep 5
"$(dirname "$0")/scripts/openai-oss-pull-models.sh" || true

echo "Done."
