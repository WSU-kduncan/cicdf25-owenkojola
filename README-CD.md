Project 4 Semantic Versioning Container Images

Purpose
- Use semantic version tags to trigger GitHub Actions
- Push versioned Docker image tags to DockerHub so older versions are not overwritten

How to see tags in a git repo
```
git tag
```

How to generate a tag
- Tag format: vMAJOR.MINOR.PATCH (vX.X.X)
- Example: v1.0.2
```
git tag -a v1.0.2 -m "Release v1.0.2"
```

How to push a tag to GitHub
```
git push origin v1.0.2
```

Workflow used for semantic versioning
Workflow file
- .github/workflows/ci-dockerhub.yml

Workflow trigger
- Runs only when a tag is pushed that matches vX.X.X

Workflow steps
- Checkout repo
- Setup Docker Buildx
- Login to DockerHub using secrets
- Use docker/metadata-action to generate tags
- Build and push image to DockerHub with latest and semantic tags

DockerHub tags created by the workflow
If I push v1.0.2, DockerHub receives:
- latest
- 1
- 1.0

DockerHub tags (evidence): [owenkojola/project3-site tags](https://hub.docker.com/repository/docker/owenkojola/project3-site/tags)


Values to update if reused
- IMAGE_NAME in workflow (DockerHub repo name)
- DOCKER_USERNAME and DOCKER_TOKEN secrets
- Build context and Dockerfile path if folder layout changes

Changes made for this part
Workflow changes
- Changed workflow trigger from normal pushes to tag pushes only
- Added docker/metadata-action to generate tags: latest, major, major.minor
Repo changes
- Added/updated workflow file in .github/workflows
- Created and used git tags for releases

Testing and validating

How to test that the workflow did its tasking
- Create and push a new tag
- Confirm the Actions run is successful for that tag

How to verify tags exist in DockerHub
- Open tags page and confirm latest, major, major.minor exist
DockerHub repo
- owenkojola/project3-site
- Link: https://hub.docker.com/r/owenkojola/project3-site

How to verify the image works when run
```
docker pull owenkojola/project3-site:latest
docker run --rm -p 8080:80 owenkojola/project3-site:latest
```

Resources I used

https://github.com/docker/metadata-action

https://docs.docker.com/engine/reference/commandline/tag/

https://semver.org/
