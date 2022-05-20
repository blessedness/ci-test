#!/bin/sh -l

echo "Hello"
time=$(date)
echo "::set-output name=time::$time"

echo "$(jq '.repository.pulls_url' $GITHUB_EVENT_PATH)"
echo "$(jq '.' $GITHUB_EVENT_PATH)"

BODY="$(jq '.comment.body' $GITHUB_EVENT_PATH)"
ISSUE_NUMBER="$(jq '.issue.number' $GITHUB_EVENT_PATH)"
LOGIN="$(jq '.comment.user.login' $GITHUB_EVENT_PATH | tr -d \")"
REPO="$(jq '.repository.full_name' $GITHUB_EVENT_PATH | tr -d \")"
GITHUB_SHA="$(jq '.head.sha' $GITHUB_EVENT_PATH)"
#PULL_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
PR_NUMBER=$(echo $GITHUB_REF | awk 'BEGIN { FS = "/" } ; { print $3 }')
URL=https://api.github.com/repos/$REPO/pulls/$PR_NUMBER/comments
GITHUB_TOKEN="$1"
echo $GITHUB_SHA

if [[ $BODY == *".take"* ]]; then
  echo "Assigning issue $ISSUE_NUMBER to $LOGIN"
  echo "Using the link: https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER/assignees"
  curl -H "Authorization: Bearer $GITHUB_TOKEN" -d '{"assignees":["'"$LOGIN"'"]}' https://api.github.com/repos/$REPO/issues/$ISSUE_NUMBER/assignees
fi

echo "Using the link: $URL"
curl POST -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" -d '{"body": "Great stuff!","commit_id": "'"$GITHUB_SHA"'","path": "app/Http/Controllers/Controller.php","start_line": 13,"start_side": "RIGHT","line": 16,"side": "RIGHT"}' $URL

curl --location --request POST "$URL" \
--header 'Accept: application/vnd.github.v3+json' \
--header "Authorization: Bearer $GITHUB_TOKEN" \
--header 'Content-Type: application/json' \
--data-raw "{
    \"body\": \"Great stuff!\",
    \"commit_id\": \"$GITHUB_SHA\",
    \"path\": \"app/Http/Controllers/Controller.php\",
    \"start_line\": 13,
    \"start_side\": \"RIGHT\",
    \"line\": 16,
    \"side\": \"RIGHT\"
}"

#curl --location --request POST "https://api.github.com/repos/$REPO/pulls/$PR_NUMBER/comments" \
#--header 'Accept: application/vnd.github.v3+json' \
#--header "Authorization: Token $GITHUB_TOKEN" \
#--header 'Content-Type: application/json' \
#--data-raw '{"body": "Great stuff!","commit_id": "'$GITHUB_SHA'","path": "app/Http/Controllers/Controller.php","start_line": 13,"start_side": "RIGHT","line": 16,"side": "RIGHT"}'
