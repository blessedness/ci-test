#!/bin/sh -l

echo "Hello $1"
time=$(date)
echo "::set-output name=time::$time"

BODY="$(jq '.comment.body' $GITHUB_EVENT_PATH)"
ISSUE_NUMBER="$(jq '.issue.number' $GITHUB_EVENT_PATH)"
LOGIN="$(jq '.comment.user.login' $GITHUB_EVENT_PATH | tr -d \")"
REPO="$(jq '.repository.full_name' $GITHUB_EVENT_PATH | tr -d \")"
PULL_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

if [[ $BODY == *".take"* ]]; then
  echo "Assigning issue $ISSUE_NUMBER to $LOGIN"
  echo "Using the link: https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER/assignees"
  curl -H "Authorization: token $GITHUB_TOKEN" -d '{"assignees":["'"$LOGIN"'"]}' https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER/assignees
fi

echo "Assigning issue $ISSUE_NUMBER to $LOGIN"
  echo "Using the link: https://api.github.com/repos/$REPO/pull/$PULL_NUMBER"
  curl -H "Authorization: token $GITHUB_TOKEN" -d '{"assignees":["'"$LOGIN"'"]}' https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER/assignees
