---
title: Setting up your local environment
---

As a new contributor, the first thing to do is to get yourself set up to contribute to a git repo.

## Forking & Cloning

1. **Create a Fork of the "Official" Repo**

    A "fork" is essentially a server-side clone of a Git repository. In the pure git world this can be done with a `git clone` command on the Git server, but GitHub provides us a *fork* button to do this, just click it (in the upper right) and confirm you want to fork the repository into your own namespace.
2. **Clone your fork**

    This one is pretty self explanatory. Just make sure you clone _your_ fork and not the official fork.

    ```
    git clone git@github.com/etsauer/git-flow.git
    ```
3. **Set your local clone up to track the "Upstream" fork**

    When I clone a repository locally, that _thing_ is appropriately referred to as your _local repository_. By default, when I run a `git clone`, git automatically sets up that _local repo_ to track the _remote repository_ I cloned from. However, since we cloned from our fork of the "official" repo, our _local repo_ is now tracking our fork. In order to keep up with changes being made to the official repo, we want to set up our _local repo_ to track the official fork, in addition to our own. This is called _adding a remote_. Here's how.

    ```
    git remote add upstream git@github.com/redhat-cop/git-flow.git
    ```
    So the command we ran is `git remote add`, then we gave it the name "upstream" and passed the Git URL to that _remote_. For the record, "upstream" is the common name used to refer to the official fork of a git project, but I could have named it "official" or "nutter-butter" for all git cares.

## Keeping Your Fork Up-to-date

As time goes on and people contribute to the project, it's possible that the _upstream_ repo will drift apart from your fork. It is your responsibility to make sure you are keeping your fork up to date with the latest changes from _upstream_. Usually this means making sure that the _default_ branch of your repo is in the same state as the _default_ branch of your fork. You can do this by occasionally pulling updates from upstream to your fork.

NOTE: Usually the _default_ branch of a repo is the "master" branch, but it's possible for some repos it could be something else. In GitHub, it's easy to know just by looking at whatever branch is the active one when you navigate to the main repo page, or do a `git clone`.

There are two methods for updating your fork. Both are explained below.

### Option 1: Rebase (Recommended)

With a _rebase_ you are essentially telling git to, first, copy the entire state of a remote branch to your local repo, then take any detected changes in my local copy and overlay them on top of the clean remote clone.

```
git checkout master # Make sure your local repo is on the master branch
git fetch upstream # Scan the remote for any updates
git rebase upstream/master # Rebase my local master on top of the master branch of upstream
```

Your local master branch is now up-to-date. However, this did not update your remote fork. To do that you have to push

```
git push
```

### Option 2: Merge

A _merge_ is almost the exact opposite of a _rebase_. Instead of using the remote repo as the base, I'm going to use my local copy as the base, and attempt to overlay any changes since my last merge on top of my current branch. One of the advantages of a _merge_ is that you get to see some output of the commits and files that have changed if that is of interest. The downside is that merging has the potential to cause more conflicts if you've made changes to your local copy _AND_ changes have been made upstream.

```
git checkout master
git fetch upstream
git merge upstream/master
```

Your local master branch is now up-to-date. However, this did not update your remote fork. To do that you have to push

```
git push
```

## Next

* [Opening a Pull Request](pr.html)
