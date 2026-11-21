#!/usr/bin/env bash
# One-shot OpenCTI + XTM One lab setup. Run inside Ubuntu (WSL2) with Docker Desktop running.
set -e

if [ "$(cat /proc/sys/vm/max_map_count)" -lt 1048575 ]; then
  echo "vm.max_map_count is too low. Set it in .wslconfig, run 'wsl --shutdown', restart Docker Desktop, then rerun."
  exit 1
fi

git clone https://github.com/OpenCTI-Platform/docker.git opencti-lab
cd opencti-lab
cp .env.sample .env

sed -i "s|^OPENCTI_ADMIN_TOKEN=.*|OPENCTI_ADMIN_TOKEN=$(cat /proc/sys/kernel/random/uuid)|" .env
sed -i "s|^OPENCTI_ENCRYPTION_KEY=.*|OPENCTI_ENCRYPTION_KEY=$(openssl rand -base64 32)|" .env
sed -i "s|^PLATFORM_REGISTRATION_TOKEN=.*|PLATFORM_REGISTRATION_TOKEN=$(openssl rand -hex 32)|" .env
sed -i "s|^XTM_ONE_SECRET_KEY=.*|XTM_ONE_SECRET_KEY=$(openssl rand -hex 32)|" .env
sed -i "s|=changeme$|=LabPass2026x|; s|=ChangeMe$|=LabPass2026x|" .env
printf "\nCONNECTOR_CISA_ID=%s\n" "$(cat /proc/sys/kernel/random/uuid)" >> .env  # .env.sample has no trailing newline

cat > docker-compose.override.yml <<'EOF'
services:
  connector-cisa-kev:
    image: opencti/connector-cisa-known-exploited-vulnerabilities:latest
    environment:
      - OPENCTI_URL=http://opencti:8080
      - OPENCTI_TOKEN=${OPENCTI_ADMIN_TOKEN}
      - CONNECTOR_ID=${CONNECTOR_CISA_ID}
    restart: always
EOF

docker compose up -d

echo ""
echo "Started. First boot takes 5-15 min."
echo "OpenCTI: http://localhost:8080   XTM One: http://localhost:8090"
echo "Login: admin@filigran.io / LabPass2026x"
echo "Check progress: docker compose ps   |   docker compose logs -f opencti"
