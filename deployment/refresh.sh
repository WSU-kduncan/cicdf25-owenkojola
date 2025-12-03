#!/bin/bash

# stop + remove old container (ignore errors if it doesnt exist)
docker stop web || true
docker rm web || true

# pull fresh image
docker pull owenkojola/project3-site:latest

# run new container (prod style)
docker run -d -p 80:80 --name web --restart unless-stopped owenkojola/project3-site:latest