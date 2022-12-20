#[
  Get my saved Reddit posts via Reddit's official REST API
  Compile with flag `-d:ssl` so the POST requests work
]#

import std/[httpclient, json]
from base64 import encode
from strformat import fmt
from strutils import isEmptyOrWhitespace

# Helper object to encapsulate the relevant post details we want to display
type RedditPost = object
    sub: string   # subreddit
    main_text: string
    url: string

# Helper functions
proc parsePostObjects(post_objects: JsonNode): seq[RedditPost]
proc printPostDetails(id_num: int, post: RedditPost)

# A brief description of our app ("<app name>/<app version>"); can be anything
const APP_NAME      = "SavedSearcher/0.0.1"
# From your personal app you created: https://www.reddit.com/prefs/apps
const APP_ID        = "oFwLNz7t3wUvhkV1atjQfQ"            # personal use script
const APP_SECRET    = "HhjA4bNm7KbmhcKBgjEKAqgHi0et4A"    # secret



## main
## 
# Prompt for Reddit username, password and target subreddit (stdout.write instead of echo so no newline)
stdout.write "Enter your Reddit username: "
let Reddit_username = readLine(stdin)
stdout.write "Enter your Reddit password: "
let Reddit_password = readLine(stdin)
stdout.write "Which subreddit do you want to search from your saved posts? r/"
let target_sub = "r/" & readLine(stdin)

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
#debugEcho fmt"token = {token}"

# Reset headers (otherwise the multipart data screws up GET request) and set new authorisation with token
client.headers = newHttpHeaders({
    "User-Agent": APP_NAME,
    "Authorization": fmt"bearer {token}"
})

# POC
#let thingy = new_client.getContent("https://oauth.reddit.com/api/v1/me")
#echo fmt"thingy = {thingy}"

# Finally can get saved posts
echo "Fetching saved posts now..."
var num_fetched_posts = 0
var num_matched_posts = 0
var after = ""
while true:
    # Max limit per request seems to be 100
    # https://www.reddit.com/dev/api#GET_user_{username}_saved
    let response = client.getContent(fmt"https://oauth.reddit.com/user/{Reddit_username}/saved?limit=100&after={after}&count={num_fetched_posts}&show=all?raw_json=1")
    # TODO: Add error-handling

    # Print saved posts of the target subreddit
    let saved_posts = parsePostObjects(response.parseJson()["data"]["children"])
    for post in saved_posts:
        if post.sub == target_sub:
            inc(num_matched_posts)
            printPostDetails(num_matched_posts, post)
    num_fetched_posts += saved_posts.len
    echo fmt"Total reddit posts scanned so far: {num_fetched_posts}"

    # Update `after` for next fetch request
    after = response.parseJson()["data"]["after"].getStr()
    if after.isEmptyOrWhitespace():   # All done - no more saved posts to fetch
        echo "All done. Bye :)"
        break
    echo "Fetching more posts..."
    #debugEcho fmt"after = '{after}'"



proc parsePostObjects(post_objects: JsonNode): seq[RedditPost] =
    var ret: seq[RedditPost]

    for post_object in post_objects:
        let post = post_object["data"]
        let post_type = post_object["kind"].getStr()

        ret.add(RedditPost(
            sub: post["subreddit_name_prefixed"].getStr(), 
            main_text: (if post_type == "t3": post["title"].getStr() elif post_type == "t1": post["body"].getStr() else: "ERROR: Not link or comment"),
            url: fmt"https://www.reddit.com{post[""permalink""].getStr()}"
        ))

    return ret



proc printPostDetails(id_num: int, post: RedditPost) =
    echo()
    echo fmt"#{id_num}"
    echo post.sub
    echo "\"" & post.main_text & "\""   # Surround with double-quotes
    echo post.url
    echo()
