# Project 5 Continuous Deployment - DockerHub Webhook + EC2

### Purpose
- Keep an EC2 instance updated automatically when DockerHub receives a new image push
- Use a webhook listener to trigger a refresh script that pulls and runs the newest image

### App / Image Used
- DockerHub image: owenkojola/project3-site:latest
- Container name: web
- App port: 80

## Part 1 - Script a Refresh

### EC2 Instance Details
- OS / AMI: Amazon Linux 2023
- Instance type: t2.medium
- Volume size: 30 GB

### Security Group configuration
Inbound rules (recommended)
- SSH (22) from MY IP only
- HTTP (80) from 0.0.0.0/0 so the site is public
- Webhook (9000) from 0.0.0.0/0 so DockerHub can reach it

### Security Group restriction(s)
- 22 is locked to my IP to prevent random SSH attempts
- 80 is open so the website is reachable from anywhere
- 9000 is open because DockerHub webhook source IPs are not fixed, so I protect it with a secret token in the webhook URL

### Docker Setup on EC2 instance
Install docker

    sudo dnf update -y
    sudo dnf install -y docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker ec2-user
    newgrp docker
    docker --version

#### Confirm Docker works

    sudo docker run --rm hello-world

#### Testing on EC2 Instance
#### Pull the image

    sudo docker pull owenkojola/project3-site:latest

#### Run the container & test

    sudo docker run -d --name web --restart always -p 80:80 owenkojola/project3-site:latest
    sudo docker ps
    curl -I http://127.0.0.1:80

### Scripting Container Application Refresh
#### What the refresh script does
- Stops and removes the old container
- Pulls the newest image tag from DockerHub
- Starts a the new container

#### Refresh script link
[Refresh Script](deployment/refresh.sh)

#### Test the script works

    sudo bash /opt/deployment/refresh.sh
    sudo docker ps
    curl -I http://127.0.0.1:80

## Part 2 - Listen (Webhook on EC2)

### Install webhook
#### Example install 

    sudo curl -L -o webhook.tar.gz https://github.com/adnanh/webhook/releases/latest/download/webhook-linux-amd64.tar.gz
    sudo tar -xzf webhook.tar.gz
    sudo mv webhook-linux-amd64/webhook /usr/local/bin/webhook
    sudo chmod +x /usr/local/bin/webhook
    /usr/local/bin/webhook -version

#### Hook definition file
- Trigger uses a shared secret token in the URL query string

    [hooks.json](deployment/hooks.json)

#### Webhook URL
- http://3.227.82.211:9000/hooks/refresh?token=72262C69dAC9c6B950EA18A7E9C00048

#### How to test webhook manually

    curl -X POST "http://3.227.82.211:9000/hooks/refresh?token=72262C69dAC9c6B950EA18A7E9C00048"
    sudo journalctl -u webhook -n 80 --no-pager
    sudo docker ps

#### How to monitor logs live

    sudo journalctl -u webhook -f

#### What to look for in docker process views

    sudo docker ps
    sudo docker ps -a

#### Webhook service (systemd)
#### What the service does
- Starts webhook automatically on boot
- Loads /opt/deployment/hooks.json
- Keeps running with Restart=always

[Webhook Service](deployment/webhook.service)

#### Enable and start the service

    sudo systemctl daemon-reload
    sudo systemctl enable --now webhook
    sudo systemctl status webhook --no-pager

## Part 3 - Send a Payload (DockerHub → EC2)

#### Why DockerHub is the sender
- DockerHub sends a webhook event automatically when a repository push happens
- If the update doesn't maker it to DockerHub there is no point in wasting resources trying to pull it.

#### How to enable DockerHub to send payloads
- DockerHub Repo -> Webhooks -> Create webhook
- Destination URL set to:
  http://3.227.82.211:9000/hooks/refresh?token=72262C69dAC9c6B950EA18A7E9C00048

#### What triggers a payload
- Any push to the DockerHub repository

#### How to verify a successful payload delivery
- On DockerHub: Webhook delivery history should show a POST and a success response
- On EC2:

    sudo journalctl -u webhook -n 100 --no-pager
    sudo docker ps

#### How I validate the webhook only triggers from trusted sources
- The hook requires the correct token in the URL query string
- Requests without the token do not match the trigger rule and do not run the refresh script

#### How to I generated my token

[Random md5 Hash Generator](https://onlinehashtools.com/generate-random-md5-hash)

Resources I used (links)

ChatGPT for troubleshooting webhooks after install.

https://docs.docker.com/docker-hub/repos/manage/webhooks/

https://docs.docker.com/docker-hub/repos/

https://docs.github.com/actions/learn-github-actions/events-that-trigger-workflows

https://docs.github.com/actions/using-workflows/triggering-a-workflow

https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions

https://github.com/adnanh/webhook

https://github.com/adnanh/webhook/releases

https://sources.debian.org/src/webhook/2.8.0-4/docs/Hook-Examples.md/

https://pkg.go.dev/github.com/adnanh/webhook/internal/hook

https://www.freedesktop.org/software/systemd/man/systemd.service.html

https://man7.org/linux/man-pages/man8/systemd-journald.service.8.html

https://www.systutorials.com/docs/linux/man/1-systemd-journalctl/

https://docs.fedoraproject.org/en-US/quick-docs/systemd-understanding-and-administering/

https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules-reference.html

https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html

https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html

https://docs.docker.com/engine/install/

https://docs.docker.com/engine/reference/commandline/docker/

https://docs.docker.com/engine/reference/commandline/pull/

https://docs.docker.com/engine/reference/commandline/run/

https://docs.docker.com/engine/reference/commandline/ps/

https://docs.docker.com/engine/reference/commandline/logs/

https://docs.docker.com/engine/reference/commandline/tag/

https://github.com/docker/metadata-action

https://github.com/docker/build-push-action

https://semver.org/