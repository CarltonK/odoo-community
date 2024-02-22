#!/bin/bash

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Install Docker
sudo apt install -y docker.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

echo "Docker has been successfully installed."

curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "Docker Compose has been successfully installed."

cat <<EOF > docker-compose.yaml
version: '3.6'

services:
  odoo-db:
    image: postgres:16
    container_name: odoo-db
    environment:
      POSTGRES_DB: odoo-pg
      POSTGRES_PASSWORD: odoo
      POSTGRES_USER: odoo
    volumes:
      - odoo-db-data:/var/lib/postgresql/data
    networks:
      odoo_network:
        ipv4_address: 172.35.0.2
  odoo-app:
    image: odoo:17.0
    container_name: odoo-app
    command: ["odoo", "-d", "odoo", "-i", "base"]
    depends_on:
      - odoo-db
    ports:
      - 8069:8069
    environment:
     HOST: odoo-db
     PORT: 5432
     USER: odoo
     PASSWORD: odoo
    volumes:
      - odoo-data:/var/lib/odoo
      - odoo-addons:/mnt/extra-addons
    networks:
      odoo_network:
        ipv4_address: 172.35.0.3
volumes:
  odoo-db-data:
  odoo-data:
  odoo-addons:
networks:
  odoo_network:
    ipam:
      driver: default
      config:
        - subnet: 172.35.0.0/16
EOF

docker-compose up -d

echo "Odoo 17 is running successfully."