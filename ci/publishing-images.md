---
title: Publishing images to Quay.io
---

Many of our repositories, such as [Containers-Quickstarts](https://github.com/redhat-cop/containers-quickstarts) and [OpenShift Toolkit](https://github.com/redhat-cop/openshift-toolkit) have container images that we publish to Quay.io.

## What you need

In order to publish images to Quay.io, you'll need the following set up ahead of time:

* A new repository and robot account created in Quay.io, set as a Secret on your repo. You can [open an issue with the CoP Tooling team](https://github.com/redhat-cop/org/issues/new?assignees=&labels=integrations&template=integrations.md&title=) to have this created.
  * REGISTRY_URI: quay.io
  * REGISTRY_REPOSITORY: redhat-cop
  * REGISTRY_USERNAME
  * REGISTRY_PASSWORD

## Setting up a GitHub Actions Workflow to Publish an Image on Push/Merge

We use [GitHub Actions](https://github.com/features/actions) for many continuous integration needs, including publishing images. To get started, create a new YAML file in your repo at `.github/workflows/`. The name of the file doesn't matter, but would typically be something like `workflow.yaml`, `main.yaml` or specifically `publish-image.yaml`.

The contents of the file should look like this (this is an example for our rabbitmq image):

```
{% raw %}
name: rabbitmq-publish
on:
  push:
    branches:
      - master
    tags:
      - '*'
    paths:
      - rabbitmq/version.json
jobs:
  build:
    env:
      context: rabbitmq
      image_name: rabbitmq
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Get image tags
        id: image_tags
        run: |
          echo -n ::set-output name=IMAGE_TAGS::
          VERSION=$(jq -r '.version' ${context}/version.json)
          TAGS=('latest')
          if [ "${VERSION}" ] && [ "${VERSION}" != "latest" ]; then
              TAGS+=("${VERSION}")
          fi
          if [[ "${GITHUB_REF}" =~ refs/tags/(.*) ]]; then
              TAGS+=("git-${BASH_REMATCH[1]}")
          fi
          ( IFS=$','; echo "${TAGS[*]}" )
      - name: Build and publish image to Quay
        uses: docker/build-push-action@v1
        with:
          path: ${{ env.context }}
          registry: ${{ secrets.REGISTRY_URI }}
          repository: ${{ secrets.REGISTRY_REPOSITORY }}/${{ env.image_name }}
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}
          tags: "${{ steps.image_tags.outputs.IMAGE_TAGS }}"
{% endraw %}
```

The above also requires a `version.json` file in the directory of you code. The content is very simple, `{"version":"v1.0.0"}` and will be used to tag the image. With this file you can tag your image independently of tags on the repository. This can be convenient when you are building multiple images from the same repo, such as containers-quickstarts.

From there, you can follow our [standard Pull Request](/contrib/) process to get your workflow added to the repo.

## Add Pre-merge (Pull Request) testing of your image

For images that can be built and tested in a standard Docker environment, we can add a second workflow to run those tests.

Add another workflow file to `.github/workflows/` that looks like the following:

```
name: rabbitmq-pr
on:
  pull_request:
    paths:
      - rabbitmq/**
jobs:
  build:
    env:
      context: rabbitmq
      image_name: rabbitmq
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Check and verify version.json
        id: check_version
        run: |
          echo -n ::set-output name=IMAGE_TAGS::
          echo $(jq -r '.version' ${context}/version.json)
      - name: Build image
        uses: docker/build-push-action@v1
        with:
          path: ${{ env.context }}
          push: false
          repository: ${{ env.image_name }}
          tags: ${{ steps.check_version.outputs.IMAGE_TAGS }}
      - name: Test image
        run: |
          echo "Running: docker run --entrypoint 'rabbitmqctl' ${image_name}:${{ steps.check_version.outputs.IMAGE_TAGS }} 'version'"
          docker run --entrypoint 'rabbitmqctl' ${image_name}:${{ steps.check_version.outputs.IMAGE_TAGS }} 'version'
```

From there, you can follow our [standard Pull Request](/contrib/) process to get your workflow added to the repo.
