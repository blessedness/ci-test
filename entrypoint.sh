#!/bin/sh -l

echo "Hello $1"
time=$(date)
echo "::set-output name=time::$time"

ENV
echo "${{ github.event.pull_request.number }}"
echo 'github'
echo $GITHUB_REF
echo $GITHUB_REF_NAME
echo $GITHUB_SHA

BODY="$(jq '.comment.body' $GITHUB_EVENT_PATH)"
ISSUE_NUMBER="$(jq '.issue.number' $GITHUB_EVENT_PATH)"
LOGIN="$(jq '.comment.user.login' $GITHUB_EVENT_PATH | tr -d \")"
REPO="$(jq '.repository.full_name' $GITHUB_EVENT_PATH | tr -d \")"
#PULL_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
PR_NUMBER=$(echo $GITHUB_REF | awk 'BEGIN { FS = "/" } ; { print $3 }')

if [[ $BODY == *".take"* ]]; then
  echo "Assigning issue $ISSUE_NUMBER to $LOGIN"
  echo "Using the link: https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER/assignees"
  curl -H "Authorization: token $GITHUB_TOKEN" -d '{"assignees":["'"$LOGIN"'"]}' https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER/assignees
fi

echo "Assigning issue $ISSUE_NUMBER to $LOGIN"
echo "Using the link: https://api.github.com/repos/$REPO/pull/$PR_NUMBER"
#curl -H "Authorization: token $GITHUB_TOKEN" -d '{"assignees":["'"$LOGIN"'"]}' https://api.github.com/repos/$REPO/pull/$PULL_NUMBER

curl --location --request POST "https://api.github.com/repos/$REPO/pulls/$PR_NUMBER/comments" \
--header 'Accept: application/vnd.github.v3+json' \
--header "Authorization: Token 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" \
--header 'Content-Type: application/json' \
--data-raw '{
    "body": "Great stuff!",
    "commit_id": "'$GITHUB_SHA'",
    "path": "app/Http/Controllers/Controller.php",
    "start_line": 13,
    "start_side": "RIGHT",
    "line": 16,
    "side": "RIGHT"
}'
