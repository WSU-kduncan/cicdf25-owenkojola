# CI/CD Projects (Project 4 + Project 5)

This repository contains my CI (Project 4) and CD (Project 5) setup for a simple website deployed as a Docker container.

## What is in this repo

- Dockerfile
  - Builds the container image for the website
- web-content/
  - Website files served by the container
- .github/workflows/ci-dockerhub.yml
  - GitHub Actions workflow that builds and pushes images to DockerHub when I push a version tag
- deployment/
  - refresh.sh (re-pulls image + restarts container)
  - hooks.json (webhook hook definition that runs refresh.sh)
  - webhook.service (systemd service to keep webhook running on EC2)
- images/
  - diagram.png (CD diagram)

## Documentation

- README-CI.md
  - Project 4 notes: tag-triggered CI build + push to DockerHub, semantic versioning, and how the workflow works

- README-CD.md
  - Project 5 notes: EC2 setup, refresh script, webhook listener + service, DockerHub webhook sender configuration, and verification steps

## Live webhook URL used (DockerHub -> EC2)

http://3.227.82.211:9000/hooks/refresh?token=72262C69dAC9c6B950EA18A7E9C00048
