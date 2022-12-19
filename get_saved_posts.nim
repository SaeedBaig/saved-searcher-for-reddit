#[
  Get my saved Reddit posts via Reddit's official REST API
  Compile with flag `-d:ssl` so the POST requests work
]#

import std/[httpclient, json, base64, strformat]

# A brief description of our app ("<app name>/<app version>"); can be anything
const APP_NAME          = "SavedSearcher/0.0.1"
# From your personal app you created: https://www.reddit.com/prefs/apps
const APP_ID            = "oFwLNz7t3wUvhkV1atjQfQ"            # personal use script
const APP_SECRET        = "HhjA4bNm7KbmhcKBgjEKAqgHi0et4A"    # secret


# Prompt for Reddit username & password (stdout.write instead of echo so no newline)
stdout.write "Enter your Reddit username: "
let Reddit_username = readLine(stdin)
stdout.write "Enter your Reddit password: "
let Reddit_password = readLine(stdin)

#[ Setup our header info:
   - A brief description of our app
   - HTTP Basic Auth with the Reddit-dev secrets ("Basic <CLIENT ID>:<CLIENT SECRET>") ]#
let client = newHttpClient()
client.headers = newHttpHeaders({
    "User-Agent": APP_NAME,
    "Authorization": "Basic " & base64.encode(fmt"{APP_ID}:{APP_SECRET}")
})

# Send our request for an OAuth token (valid for ~2 hours)
# TODO: Add error-handling for when username/password incorrect
let token = client.postContent(
    "https://www.reddit.com/api/v1/access_token",
    multipart=newMultipartData({"grant_type":"password", "username":Reddit_username, "password":Reddit_password})
).parseJson()["access_token"].getStr()
#echo fmt"token = {token}"

# Reset headers (otherwise the multipart data screws up GET request) and set new authorisation with token
client.headers = newHttpHeaders({
    "User-Agent": APP_NAME,
    "Authorization": fmt"bearer {token}"
})
# TODO: Is this assignment to newHttpHeaders() a memory leak of the old headers?

# POC
#let thingy = new_client.getContent("https://oauth.reddit.com/api/v1/me")
#echo fmt"thingy = {thingy}"

# Finally can get saved posts
echo "Fetching saved posts now..."

var total_num_reddit_posts = 0
var after = ""
for i in 1..3: # poc - replace with while loop
    # Max limit per request seems to be 100 (3 for now for debugging)
    # https://www.reddit.com/dev/api#GET_user_{username}_saved
    let response = client.getContent(fmt"https://oauth.reddit.com/user/{Reddit_username}/saved?limit=3&after={after}&count={total_num_reddit_posts}")

    let saved_posts = response.parseJson()["data"]["children"]
    after = response.parseJson()["data"]["after"].getStr()
    echo fmt"after = '{after}'"    # TODO: Look into debugEcho

    for post_object in saved_posts:
        let post = post_object["data"]
        echo()
        echo post["subreddit_name_prefixed"].getStr()
        echo post["title"]  # dont convert from JSON->string for free double quotes
        echo fmt"https://www.reddit.com{post[""permalink""].getStr()}"
        echo()
        # TODO: Refactor printing into seperate proc
    total_num_reddit_posts += saved_posts.len
    
echo fmt"total_num_reddit_posts = {total_num_reddit_posts}"
