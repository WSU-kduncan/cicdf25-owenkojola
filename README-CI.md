Project 4 CI Docker GitHub Actions DockerHub

Continuous Integration Project Overview
Goal
- Containerize my website with Docker
- Use GitHub Actions to build and push the image to DockerHub

Tools and roles
- Git and GitHub: store the repo and trigger workflows
- Docker - builds and runs the container image
- GitHub Actions: runs CI automatically
- DockerHub - stores the built images and tags

What is not working
- Nothing is not working (on my machine)

Diagram of the CI process

![CI Diagram](images/diagram.png)

What happens in each place
Cloned repo
- I edit the website files in web-content
- I build and run the image locally to test

GitHub
- Stores my repo
- When I push a semver tag, it triggers the workflow to build and push the image

DockerHub
- Receives the pushed image
- Shows tags like latest, 1, and 1.0

Part 1 Create a Docker container image

Website content
- Folder: ./web-content/
- Files: ./web-content/index.html, ./web-content/dogs.html, ./web-content/styles.css

Dockerfile
- File: ./Dockerfile
- Base image: httpd:2.4
- Copies web-content into Apache default web directory

Dockerfile contents
```
FROM httpd:2.4
COPY web-content/ /usr/local/apache2/htdocs/
```

Build image from Dockerfile
```
docker build -t project3-site:latest 
```

Run container to serve the website
```
docker run --rm -p 8080:80 project3-site:latest
```

Verify website works
- http://localhost:8080
- http://localhost:8080/dogs.html (or click the hyperlink for dogs page)

Tagging requirements for DockerHub
- Images are tagged like username/repo:tag
- Example: owenkojola/project3-site:latest
- Using tags matters because latest gets overwritten and you need versions to roll back

DockerHub repo used for this project
- This must match IMAGE_NAME in .github/workflows/ci-dockerhub.yml
- DockerHub repo: owenkojola/project3-site
- Link: https://hub.docker.com/r/owenkojola/project3-site

Part 2 GitHub Actions and DockerHub

DockerHub PAT for GitHub Actions
How I created a PAT
- DockerHub account settings
- Personal access tokens
- Create token with Read and Write permissions

GitHub repository secrets
How I set secrets
- GitHub repo Settings
- Secrets and variables
- Actions
- New repository secret

Secrets used by the workflow
- DOCKER_USERNAME = owenkojola
- DOCKER_PAT = DockerHub PAT value

Workflow file
- .github/workflows/ci-dockerhub.yml

Workflow trigger
- Final version triggers on tag push vX.X.X only

Workflow steps
- Checkout repo
- Setup Docker Buildx
- Login to DockerHub using secrets
- Generate tags from the git tag version
- Build and push the image to DockerHub

Values to change if reused in another repo
- IMAGE_NAME in the workflow
- DockerHub repo name
- Secret names if different
- Docker build context and Dockerfile path if folder structure changes

Testing and validating

How to test workflow ran
- Push a semver tag and check the GitHub Actions run is green

Example tag commands
```
git tag -a v1.0.2 -m "Release v1.0.2"
git push origin v1.0.2
```

How to verify the DockerHub image works
```
docker pull owenkojola/project3-site:latest
docker run --rm -p 8080:80 owenkojola/project3-site:latest
```

Resources I used

ChatGPT for Errors I ran into like having the wrong name for the DOCKER_PAT secret, dockerhub PAT, and a few other small things. Not used to generate any of the project.

https://docs.docker.com/engine/reference/builder/

https://docs.docker.com/engine/reference/commandline/build/

https://docs.docker.com/engine/reference/commandline/run/

https://docs.docker.com/engine/reference/commandline/tag/

https://docs.docker.com/engine/reference/commandline/push/

https://docs.docker.com/engine/reference/commandline/login/

https://docs.docker.com/docker-hub/access-tokens/

https://hub.docker.com/_/httpd

https://httpd.apache.org/docs/

https://docs.github.com/en/actions

https://docs.github.com/en/actions/security-guides/encrypted-secrets

https://github.com/actions/checkout

https://github.com/docker/login-action

https://github.com/docker/build-push-action

https://github.com/docker/metadata-action

https://github.com/docker/setup-buildx-action

https://git-scm.com/book/en/v2/Git-Basics-Tagging

https://semver.org/