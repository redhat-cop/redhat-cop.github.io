---
title: Linting and Testing Helm Charts
---

Helm charts benefit greatly from CI and can be continuously linted and tested in a pipeline using [ct](https://github.com/helm/chart-testing). Ct (or Chart Testing) is a tool for linting and testing Helm charts in a monorepo. It uses git behind the scenes to test only modified charts to avoid lengthy build times. It also enforces SemVer and requires users to increment the version of modified charts to avoid publishing changes to a previously released version.

In this article, we'll look at how the CoP currently performs CI of Helm charts with ct. Afterward, we'll look at how this process can be improved and where it is going.

## File Structure
Ct requires a specific file structure to work correctly. CoP projects that use Helm charts should contain the following files:

* `.github/workflows`: Contains the workflows for GitHub Actions. One workflow should include the [helm/chart-testing-action](https://github.com/helm/chart-testing-action).
* `chart_schema.yaml`: Contains the Chart.yaml schema that ct will enforce
* `charts/`: Contains the Helm chart monorepo
* `charts/*/ci/`: Contains different values files that ct will test
* `ct.yaml`: Contains the ct config
* `lintconf.yaml`: Contains the yamllint config that ct will use to enforce YAML style

Let's look at these files in further detail and how to configure each of these for CoP projects.

### The `.github/workflows` Folder
This folder contains different workflows for performing CI with GitHub actions. Luckily, Helm provides a Chart Testing action you can use out of the box. Below is a workflow that CoP projects use.

```yaml
name: Chart Lint
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Fetch history
        run: git fetch --prune --unshallow
    
      - name: Lint Helm charts
        uses: helm/chart-testing-action@v1.0.0
        with:
          command: lint
          config: ct.yaml
```

Note that this workflow is only performing linting. We’ll get to this more after we talk about the rest of the file structure. For now, let’s move on to the chart_schema.yaml file.

### The `chart_schema.yaml` File
This file is used to enforce a Chart.yaml schema. Below is the recommended chart_schema.yaml config:

```yaml
name: str()
home: str(required=False)
version: str()
appVersion: any(str(), num(), required=False)
description: str(required=False)
keywords: list(str(), required=False)
sources: list(str(), required=False)
maintainers: list(include('maintainer'), required=False)
icon: str(required=False)
apiVersion: str(required=False)
engine: str(required=False)
condition: str(required=False)
tags: str(required=False)
deprecated: bool(required=False)
kubeVersion: str(required=False)
annotations: map(str(), str(), required=False)
---
maintainer:
  name: str(required=False)
  email: str(required=False)
  url: str(required=False)
```

### The `charts/` Folder
This folder contains your Helm chart monorepo. This folder should only contain Helm charts (no other files) because ct could otherwise detect changes in files not related to Helm charts. Here is an example of a charts/ folder.

```
charts/
  chart1/
  chart2/
  chart3/
```

The name of each folder under charts/ should be the same as the name field in the Chart.yaml file.

### The `charts/*/ci/` Folder
This folder is for testing different values files during the CI process. These values merge with the chart's values.yaml file and applied to ensure that different combinations of values still result in a successful chart installation across changes. You can create as many values files as you want under this folder using whatever filename you think is necessary to represent the test case. Here's an example:

```
charts/my-chart/ci/nodeport-values.yaml
charts/my-chart/ci/pvc-values.yaml
```

### The `ct.yaml` File
This file is the ct configuration. It should be at the top level of your project. Here's the recommended ct.yaml config:

```yaml
chart-dirs:
  - charts
validate-maintainers: false
```

This config tells ct where your Helm chart monorepo is (chart-dirs setting) and whether or not to validate that the maintainers field is present in Chart.yaml files. You can add other configs if necessary, which are described in the [ct GitHub page](https://github.com/helm/chart-testing/blob/master/doc/ct_lint.md). Each command-line parameter corresponds to a setting in the ct.yaml file.

### The `lintconf.yaml` File
This file enforces style standards across CoP projects. Ct uses this file to lint the values.yaml and Chart.yaml files. Below is the recommended lintconf.yaml config.

```yaml
---
rules:
  braces:
    min-spaces-inside: 0
    max-spaces-inside: 0
    min-spaces-inside-empty: -1
    max-spaces-inside-empty: -1
  brackets:
    min-spaces-inside: 0
    max-spaces-inside: 0
    min-spaces-inside-empty: -1
    max-spaces-inside-empty: -1
  colons:
    max-spaces-before: 0
    max-spaces-after: 1
  commas:
    max-spaces-before: 0
    min-spaces-after: 1
    max-spaces-after: 1
  comments:
    require-starting-space: true
    min-spaces-from-content: 2
  document-end: disable
  document-start: disable           # No --- to start a file
  empty-lines:
    max: 2
    max-start: 0
    max-end: 0
  hyphens:
    max-spaces-after: 1
  indentation:
    spaces: consistent
    indent-sequences: whatever      # - list indentation will handle both indentation and without
    check-multi-line-strings: false
  key-duplicates: enable
  line-length: disable              # Lines can be any length
  new-line-at-end-of-file: disable
  new-lines:
    type: unix
  trailing-spaces: enable
  truthy:
    level: warning
```

Now that we have reviewed each of the files required for ct, let's explore an example.

## Example
For this example, we will look at the [Pelorus repo](https://github.com/redhat-cop/pelorus). This repo has two separate workflows under [.github/workflows](https://github.com/redhat-cop/pelorus/tree/master/.github/workflows), one specifically for ct and another for building the app (though both workflows could be combined). Here is an example ct build - https://github.com/redhat-cop/pelorus/runs/894996440?check_suite_focus=true.

Let’s look closely at the Lint task of the [ct example](https://github.com/redhat-cop/pelorus/runs/894996440?check_suite_focus=true). After the workflow clones the source code, the “Lint Helm charts” step begins. When ct detects chart changes, you’ll see a message similar to the following.

```
 Charts to be processed:
-----------------------------------------------------------------
 deploy => (version: "v1.2.0-5-g73c9783", path: "charts/deploy")
```

This message means that ct detected a change to the "deploy" chart. If more than one chart were changed, those charts would appear here as well.

Next, ct will check for a version bump:

```
Linting chart 'deploy => (version: "v1.2.0-5-g73c9783", path: "charts/deploy")'
Checking chart 'deploy => (version: "v1.2.0-5-g73c9783", path: "charts/deploy")' for a version bump...
Old chart version: 1.2.0-4-ga689e5e
New chart version: v1.2.0-5-g73c9783
Chart version ok.
```

You must update the version of your Helm chart for the workflow to pass. You can disable this check by adding the `check-version-increment: false` flag to your ct.yaml file, but the CoP does not recommend this.

After the version check, ct will lint your Chart.yaml and values.yaml files (including the ones under ci/). Linting also ensures that your templates, once rendered, produce valid YAML syntax. Here's an example of linting from the workflow logs.

```
Validating /workdir/charts/deploy/Chart.yaml...
Validation success! 👍
==> Linting charts/deploy
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
---------------------------------------------------------------------
 ✔︎ deploy => (version: "v1.2.0-5-g73c9783", path: "charts/deploy")
---------------------------------------------------------------------
All charts linted successfully
```

The pipeline is finished once linting is successful.

## Live Testing
In addition to chart linting, ct is also capable of testing your Helm charts in a live Kubernetes/OpenShift cluster. However, the CoP is not performing live testing until we have access to a long-living OpenShift cluster. Once this is complete, this doc will be updated to include guidelines on how you can implement live testing in your project's CI workflow.

For now, you can manually test your charts with ct outside of a GitHub Actions environment. All you need is access to an OpenShift cluster and the “edit” ClusterRole (unless your chart needs to create admin-level resources like Roles and RoleBindings - then you will need “admin”). Then, at the top-level of your project’s repo, run this command:

```bash
ct install --upgrade --namespace=$OCP_PROJECT
```

This command will install your charts to the specified OpenShift project and run "helm test". Even if your charts don't have test hooks, your charts will still be "tested" if they have readiness probes set. The installation will succeed only if your readiness probe passes.

This command will also perform regression testing against the previous version of your charts, a feature enabled by the "--upgrade" flag. When this flag is specified, ct installs the earlier version of your chart and attempts to upgrade to the new version. Then, it will delete the release and install the new version directly. When using the "--upgrade" flag, regression testing will only be performed if you do not change the major version of your chart. Because the major version indicates breaking changes, ct knows not to try to upgrade against the previous version if the major version is different.

## Releasing Charts
The CoP is currently not releasing Helm charts to a chart repository. Projects that use Helm charts are maintaining those charts only under the charts/ folder of their repository. There are options, however, that the CoP can pursue to release charts in the future.

The first option is to release charts to GitHub Pages. This option can be done easily using the [cr (Chart Releaser) tool](https://github.com/helm/chart-releaser). This tool is designed specifically for releasing charts to GitHub Pages and could be an easy way to release charts linted and tested with ct. Chart Releaser also has a GitHub Action, similar to ct, called [helm/chart-releaser-action](https://github.com/helm/chart-releaser-action). The chart-releaser-action could be used after the chart-testing-action in a workflow to ensure that charts are properly tested and versions are changed to avoid publishing changes to an already released version. 

The second option is to publish to a chart repository, such as https://redhat-developer.github.com/redhat-helm-charts. There is currently no tool maintained by Helm that publish to a chart repository other than GitHub Pages, so the CoP would likely need to create a GitHub Action or customized workflow to do this. The steps to release to the redhat-developer repository are listed here - https://github.com/redhat-developer/redhat-helm-charts/wiki/Adding-a-New-Chart.