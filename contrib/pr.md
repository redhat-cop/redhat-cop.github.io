---
title: Opening A Pull Request
---

Contributing to a Git Project is Facilitated through _Pull Requests_. Here's how it works.

NOTE: This guide assumes you've set up your local machine per the [Local Setup Guide](https://github.com/redhat-cop/git-flow/wiki/Local-Setup).

## Overview

For the purpose of this guide, we will walk through the process of making a contribution to our [Spring-Rest](https://github.com/redhat-cop/spring-rest.git) app, a demo app we use to show developer workflows in OpenShift.

## Quick and Dirty

For those who are impatient, here's a quick reference to the git commands involved in a Pull Request.

```
git checkout master
git checkout -b my-new-branch
# Make some Changes
git add <files changed or created>
git commit -m"Some commit message here"
git push -u origin my-new-branch
```

Then use the browser to do the rest!

## Opening a Pull Request

```
# First make sure your master is up to date
$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
$ git fetch upstream
remote: Counting objects: 1, done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (1/1), done.
From github.com:redhat-cop/spring-rest
 * [new branch]      master     -> upstream/master
$ git rebase upstream/master
First, rewinding head to replay your work on top of it...
Fast-forwarded master to upstream/master.
$ git push
Counting objects: 1, done.
Writing objects: 100% (1/1), 653 bytes | 653.00 KiB/s, done.
Total 1 (delta 0), reused 0 (delta 0)
To github.com:etsauer/spring-rest.git
   325e315..b2c637d  master -> master
```

It's always best to start with a new branch when working on a new feature or contribution. That way it's possible to have multiple separate features in progress at once without making a mess of your repo. It's also nice to keep your master branch clean and tracking the latest from upstream.

```
# Create a new feature branch for Changes
$ git checkout -b add-readme
Switched to a new branch 'add-readme'
```

This is the part where we make our code changes. For this walkthrough, the change will involve adding a new file (`README.md`)
```
# Now, Make your changes...
$ git status
On branch add-readme
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
$ echo "# Spring Rest - A Restful API written in Spring Boot" > README.md
$ git status
On branch add-readme
Your branch is up-to-date with 'origin/master'.
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	README.md

nothing added to commit but untracked files present (use "git add" to track)

# Flag new files for the next commit
$ git add README.md
$ git status
On branch add-readme
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   README.md

# Commit your changes
$ git commit -m"Adding README doc to this repo"
[add-readme e20292c] Adding README doc to this repo
 1 file changed, 1 insertion(+)
 create mode 100644 README.md

# Push your new branch to your fork
$ git push -u origin add-readme
Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 325 bytes | 325.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To github.com:etsauer/spring-rest.git
 * [new branch]      add-readme -> add-readme
Branch add-readme set up to track remote branch add-readme from origin.

```

Now, we go to GitHub. (the main repo, not your fork)

![New branch view](/images/github-newbranch-ss.png)

If you did everything right you should see a callout that a new branch has been pushed to a forked repo, with a prompt to **Compare & pull request**. Clicking that button will open the new Pull Request view.

The title is populated with the last commit message. You can change it if you want to.

In the comment box, leave a comment that gives a reviewer the proper ability to review and/or test your changes. It's also a good practice to callout the individuals that you would like to review it. Within the [redhat-cop](https://github.com/redhat-cop) space, we have several teams defined that can be used to call them out.

![New pull request view](/images/github-newpr.png)

Now click **Create pull request**, and your pull request is Created!

## Maintaining Your Pull Request

Pull requests are rarely correct the first time, and having multiple pull requests in flux at once can create conflicts and other complications. Because of this, it will often be necessary for you to update your open pull request as it is being reviewed. Below we walk through a few of the common cases for pull request maintenance.

### Making more Changes

TBD

### Rebasing

TBD

## Next

* [Reviewing a Pull Request](./pr-test.html)
