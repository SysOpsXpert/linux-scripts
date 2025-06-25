#!/bin/bash

set -e

echo "📦 Installing Apache Guacamole via Docker Compose..."

# 1. Create working directory
mkdir -p /guacamole-docker
cd /guacamole-docker

# 2. Create docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  guacd:
    image: guacamole/guacd
    container_name: guacd
    restart: always

  db:
    image: mysql:8
    container_name: guac-db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: guacroot
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacuser
      MYSQL_PASSWORD: guacpass
    volumes:
      - db_data:/var/lib/mysql

  guacamole:
    image: guacamole/guacamole
    container_name: guacamole
    restart: always
    depends_on:
      - guacd
      - db
    ports:
      - "8080:8080"
    environment:
      MYSQL_HOSTNAME: db
      MYSQL_PORT: 3306
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacuser
      MYSQL_PASSWORD: guacpass
      GUACD_HOSTNAME: guacd

volumes:
  db_data:
EOF

# 3. Start containers
echo "🚀 Starting containers..."
docker-compose up -d

# Wait for MySQL to become ready
echo "⏳ Waiting for MySQL to be ready..."
until docker exec guac-db mysqladmin ping -h "localhost" --silent; do
  sleep 2
done

# 4. Download and run initdb.sql
echo "📄 Initializing Guacamole database schema..."
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
docker cp initdb.sql guac-db:/initdb.sql
docker exec guac-db bash -c "mysql -uguacuser -pguacpass guacamole_db < /initdb.sql"

# 5. Restart Guacamole to apply schema
docker restart guacamole

echo "✅ Apache Guacamole is ready!"
echo "🌐 Access it at: http://localhost:8080/guacamole"
echo "👤 Default login: guacadmin / guacadmin"

