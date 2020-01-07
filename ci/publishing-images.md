---
title: Publishing images to Quay.io
---

Many of our repositories, such as [Containers-Quickstarts](https://github.com/redhat-cop/containers-quickstarts) and [OpenShift Toolkit](https://github.com/redhat-cop/openshift-toolkit) have container images that we publish to Quay.io.

## What you need

In order to publish images to Quay.io, you'll need the following set up ahead of time:

* A new repository and robot account created in Quay.io, set as a Secret on your repo. You can [open an issue with the CoP Tooling team](https://github.com/redhat-cop/org/issues/new?assignees=&labels=integrations&template=integrations.md&title=) to have this created.
  * QUAY_USERNAME
  * QUAY_PASSWORD

## Setting up a GitHub Actions Workflow to Publish an Image on Push/Merge

We use [GitHub Actions](https://github.com/features/actions) for many continuous integration needs, including publishing images. To get started, create a new YAML file in your repo at `.github/workflows/`. The name of the file doesn't matter, but would typically be something like `workflow.yaml`, `main.yaml` or specifically `publish-image.yaml`.

The contents of the file should look like this:

```
name: myimage-publish-workflow
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Publish My Image to Quay
      uses: elgohr/Publish-Docker-Github-Action@2.11
      with:
        name: redhat-cop/myimage
        username: ${{ secrets.QUAY_USERNAME }}
        password: ${{ secrets.QUAY_PASSWORD }}
        registry: quay.io
        dockerfile: container-images/myimage/Dockerfile
        tag_names: true
```

From there, you can follow our [standard Pull Request](/contrib/) process to get your workflow added to the repo.

## Add Pre-merge (Pull Request) testing of your image

For images that can be built and tested in a standard Docker environment, we can add a second workflow to run those tests.

Add another workflow file to `.github/workflows/` that looks like the following:

```
name: myimage-test
on: [pull_request, push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: Build image and test that it is functional
      run: |
        docker build -f container-images/myimage/Dockerfile -t myimage .
        docker run -p 54321:54321 myimage

        # Include validation steps
        curl http://127.0.0.1:54321
```

From there, you can follow our [standard Pull Request](/contrib/) process to get your workflow added to the repo.
