# git-hydra

This is a git post-commit hook which cherry-picks the new commit into another
branch, conditionally creating the branch and optionally making a PR as well.

This makes it pretty easy to rapidly develop multiple independent features
and split them up into branches and pull-requests.

> This hook is currently unstable and highly experimental. There are
> various untested edge cases and some circumstance might make you lost
> and confused in your repo.
>
> It does not (knowingly) run hard resets or other commands where you
> can permanently lose data. But none-the-less, please do not use this
> unless you have read the source code and are comfortable with your git
> knowledge. The reflog especially might come in handy.


# Motivation

The idea is to increase throughput on projects with PRs and code-reviews.
Especially where PRs need to be small, focused and self-contained, and
reviews might take a day or more.

In high throughput development, you may be working on separate fixes and
features in your working tree at the same time, and it can be painful to
split them up into their own branches and pull-requests.

It can also be really annoying to always be working from an "old" master, not
having all the latest fixes and improvements which are still in review.

This hook tries to simplify this workflow so you can do all your work on
a single branch, where commits are automatically cherry-pick to the correct
remote branch and pull-request.

# Install

There is just one soft dependency. To create github pull-requests, you first
have to install and configure the [hub command line tool](https://github.com/github/hub).

Here are at least two ways to install the post-commit hook itself.

## Easy update npm way

Install the git-hydra npm package globally:

```
npm i -g git-hydra
```

Then you can install the post-commit hook into a repo like this:

```
git hydra install
```

This will install the hook as a symbolic link to the npm package which you
can update later.

## Manual install

Just move the [post-commit.sh](https://github.com/aranja/git-hydra/master/post-commit.sh) into the
`.git/hooks` folder of a repository.

# Usage

While committing as usual, append your commit message with a line
containing only "Branch: <name>".

If all works like it should, you won't notice a difference in your
working tree, but the new commit has been committed to the specified
branch as well. If it didn't exist already, it does now, created from
master.

If you end the message with "Push: <name>" instead, the target branch will
additionally be pushed to the remote and if you do "PR: <name>", a pull-request
will be created on github.

# Tips

It's recommended to create a local development branch which you can customise
to your liking by merging in active branches and pull-requests. You should
never push this branch.

On this branch you can crunch commits, splitting them into different
pull-requests. The github client provides an excellent UI for selecting
hunks and lines to commit. As long as they changes are fairly independent
everything should be beautiful.

When master has been updated enough, you can start again by recreating the
local branch from master, and merge all active pull-requests again.

# Notes

*   The matcher is case insensitive and the colon is optional. E.g. you can
    end your commit message with "branch <name>".

*   If the commit conflicts with master or the target branch, you'll end
    up in the target branch where you have to resolve the merge conflict.

    After doing so, you can go back to the branch you came from. If you
    are missing changes from your working tree, run `git stash pop` and
    they should be back

*   If you forget to annotate where a commit should go, you can amend it's
    commit message and it will go where it should. It's also possible to
    undo and recommit it in the github application.
