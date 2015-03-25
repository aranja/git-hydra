#!/bin/sh

# Fail on unexpected error
set -euo pipefail

# Collect some info
MSG=`git log -n 1 --format=format:%s%n%n%b`
CURRENT=`git symbolic-ref -q --short HEAD || git rev-parse HEAD`
TAIL=`echo "$MSG" | tail -n 1`
MSG_SANS_TAIL=`echo "$MSG" | sed -e '$ d'`
TARGET=""
STASH=""

# Check if tail specifies a target and extract it.
if [[ $TAIL =~ ^(branch|pr|push):?[[:space:]]+(.+) ]]; then
	TYPE=`echo "${BASH_REMATCH[1]}" | tr "[:upper:]" "[:lower:]"`
	TARGET="${BASH_REMATCH[2]}"
fi

# Quit early if commit message did not end with a `Branch:` or `PR:` line.
if [ -z "$TARGET" ]; then
	exit
fi

# If there are any changes in index or working tree, stash them and remember!
if ! git diff-index --quiet HEAD; then
	git stash --quiet
	STASH=1
fi

# Go to the target branch, or create it from master if it doesn't exist.
git checkout $TARGET 2>/dev/null || git checkout -b $TARGET master --quiet

# Cherry pick the new commit to the target branch. Here be dragons, or merge conflicts. Either or.
git cherry-pick -n "$CURRENT"

# Commit with the same message, except skipping the trigger line.
if ! git diff-index --quiet --cached HEAD; then
	git commit -m "$MSG_SANS_TAIL" --quiet
fi

# Push?
if [ $TYPE != "branch" ]; then
	git push --quiet
fi

# Create github PR?
if [ $TYPE = "pr" ]; then
	# Check if hub command exists
	if hash hub 2>/dev/null; then
		# Create pull-request.
		hub pull-request -m "$MSG_SANS_TAIL"
	else
		# Uh-oh
		echo Could not create pull-request - hub not installed.
	fi
fi

# Go back to where we were
git checkout "$CURRENT" --quiet

# Pop the stash if needed
if [ -n "$STASH" ]; then
	git stash pop --quiet
fi
