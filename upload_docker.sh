
#!/usr/bin/env bash
# This file tags and uploads an image to Docker Hub

# Assumes that an image is built via `run_docker.sh`

# Step 1:
# Create dockerpath
dockerpath=desjenkins/app

# Step 2:
# Authenticate & tag
echo "Docker ID and Image: $dockerpath"
docker tag udacity:latest desjenkins/udacity:latest
docker login --username=desjenkins

# Step 3:
# Push image to a docker repository
docker push desjenkins/udacity:latest
