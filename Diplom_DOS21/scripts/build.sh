#!/bin/bash
echo "Building Docker images..."
docker build -t myapp-backend:latest -f Dockerfile .
docker build -t myapp-frontend:latest -f Dockerfile .
