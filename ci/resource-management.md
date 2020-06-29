---
title: Requesting and Managing CoP Resources
---

The Red Hat Community of Practice makes use of several services to host content, specifically [GitHub](https://github.com/) for source code management and [Quay.io](https://quay.io/) for container images. This guide provide an overview of these tools and how you can make use of them in a self service capacity to request and manage CoP related resources.

## CoP Resource Management Overview

The CoP has established a repository called [org](https://github.com/redhat-cop/org) as the focal point for managing CoP related resources. This repository contains a request management process leveraging GitHub issues along with a set of tools to automate the management of these services.

### Requesting Resources

Request for CoP related services can be made by creating a new [GitHub Issue](https://github.com/redhat-cop/org/issues/new/choose). The following types of resource requests can be made:

* Becoming a CoP Contributor
* General Support
* Integration with third party components
* Permission modification of existing resources
* Repository management
* Team management

All resources will be fulfilled by the CoP tools team and tracked in the corresponding issue. See the sections below on how you can leverage some of the automation tools to streamline the request and management process. 

## Automation Tools

To emphasize the use of Infrastructure as Code (IaC) concepts, several tools have been employed to management GitHub and Quay assets.

* [Prow](https://github.com/kubernetes/test-infra/tree/master/prow) - Kubernetes based CI/CD system
* [Peribolos](https://github.com/kubernetes/test-infra/tree/master/prow/cmd/peribolos) - Management of GitHub organization settings, teams and management in a declarative fashion.
* [Ansible Quay Role](https://github.com/redhat-cop/infra-ansible/tree/master/roles/scm/quay) - Management of Quay resources including repositories, teams and permissions

## Repository Management

Public source code and assets are contained in repositories within the [redhat-cop](https://github.com/redhat-cop). New repositories can be requested by submitting a [new issue](https://github.com/redhat-cop/org/issues/new?assignees=&labels=access&template=repository-management.md&title=New%20Repository%20Request=).

Once the repository has been created, access be managed within the Peribolos [config.yaml](https://github.com/redhat-cop/org/blob/master/config.yaml) file (described below).

## Managing GitHub Settings and Membership

The settings for the CoP GitHub organization as a whole including teams, their membership and permissions on repositories are specified in the [config.yaml](https://github.com/redhat-cop/org/blob/master/config.yaml) in the [org](https://github.com/redhat-cop/org). This approach allows for the configuration to be expressed declaratively and automatically applied using the Peribolos tool. In conjunction with Prow, changes are tested and applied whenever they have be merged to the _master_ branch.

The primary use case for which contributors might want to manage this file is to modify the composition of teams and the permissions applied to repositories. While changes can be requested through the issue tracking feature described in earlier sections, the following describes how contributors can submit their own changes through a pull request. This accelerate the time that it takes to have the desired change applied. 

The general structure for teams and their associated permissions are as follows:

```
orgs:
  redhat-cop:
    teams:
      <team_name>:
        description: <description>
        maintainers:
          - <maintainer_1>
          - <maintainer_2>
        members:
          - <member_1>
          - <member_2>
        privacy: closed
        repos:
          <repository_name>: <read|write|admin>
        teams:
          <sub_team_name>
          ...
```

For any requested changes, be sure to follow the steps describe in submitting a [pull request](../contrib/pr.md). 

## Quay Management

The [redhat-cop Quay organization](https://quay.io/organization/redhat-cop) contains all of the images produced and managed by the CoP. The configuration for the organization including repositories, teams and robots accounts is declaratively specified in the [all.yml](https://github.com/redhat-cop/org/blob/master/ansible/inventory/group_vars/all.yml) inventory within the [org](https://github.com/redhat-cop/org) repository.

Requested changes, including the creation of new repositories or modification of existing repositories and setting can be facilitated through the issue tracking feature described previously. However, contributors can submit their own pull request against this inventory file with their desired modifications. 

The inventory file is organized as follows:

```
orgs:
  - name: redhat-cop
    repos:
      - name: alertmanager-telegram-gateway
        visibility: <public|private>
        permissions:
          - name: <name of actor>
            type: <user|robot|team>
            role: <read|write|admin>
    robots:
      - name: <name>
        description: "<description>"
    teams:
      - name: <name>
        role: <admin|member|creator>
        members:
          - name: <member1>
          - name: <member2>
```

The following is an example of defining a new repository called _myexample_ that includes a grants the user _joe_ with admin permissions on the repository along with creating a robot account called _myexample_ with write rights.

```
orgs:
  - name: redhat-cop
    repos:
    ...
      - name: myexample
        visibility: public
        permissions:
          - name: jdoe
            type: user
            role: admin
          - name: myexample
            type: robot
            role: write
    ...
    robots:
    ...
      - name: myexample
        description: "Robot account for the myexample repository"
    ...
```

When complete, submit a new Pull Request against the repository as described in submitting a [pull request](../contrib/pr.md).