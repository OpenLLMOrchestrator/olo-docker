@echo off
cd /d "%~dp0"

echo Creating shared Docker network: olo-net (if needed)...
docker network inspect olo-net >nul 2>&1
if errorlevel 1 (
  docker network create olo-net
)

echo Bringing up full OLO dev stack (project: olo, in sequence: db, cache, elastic, temporal, olo, ai-text, ai-image, ai-video, ai-audio)...

docker compose -p olo ^
  -f "docker-compose-db.yml" ^
  -f "docker-compose-cache.yml" ^
  -f "docker-compose-ElasticSearch.yml" ^
  -f "docker-compose-temporal.yml" ^
  -f "docker-compose-olo.yml" ^
  -f "docker-compose-ai-text.yml" ^
  -f "docker-compose-ai-image.yml" ^
  -f "docker-compose-ai-video.yml" ^
  -f "docker-compose-ai-audio.yml" ^
  up -d

echo Dev OLO stack is up (project: olo).
