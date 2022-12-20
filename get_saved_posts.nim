#[
Get my saved Reddit posts via Reddit's official REST API
(compile with flag `-d:ssl` so the HTTP-POST requests work)
]#

import std/[httpclient, json]
from base64 import encode
from strformat import fmt
from strutils import isEmptyOrWhitespace

# Helper class to encapsulate the relevant post details we want to display
type RedditPost = object
    sub: string   # subreddit
    main_text: string
    url: string

# Type prefixes for different types of Reddit content (https://www.reddit.com/dev/api/#type_prefixes)
type RedditEntity = enum
    Comment="t1", Account="t2", Link="t3", Message="t4", Subreddit="t5", Award="t6"

# Helper functions
proc parsePostObjects(json_body: JsonNode): seq[RedditPost]
proc printPostDetails(id_num: int, post: RedditPost)

# A brief description of our app ("<app name>/<app version>"); can be anything
const APP_NAME      = "SavedSearcher/0.0.1"
# From your personal app you created (https://www.reddit.com/prefs/apps):
const APP_ID        = "oFwLNz7t3wUvhkV1atjQfQ"            # personal use script
const APP_SECRET    = "HhjA4bNm7KbmhcKBgjEKAqgHi0et4A"    # secret


when isMainModule:
    # Prompt for Reddit username, password and target subreddit (stdout.write instead of echo for no newline)
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
    let token = client.postContent(
        "https://www.reddit.com/api/v1/access_token",
        multipart=newMultipartData({"grant_type":"password", "username":Reddit_username, "password":Reddit_password})
    ).parseJson()["access_token"].getStr()
    # TODO: Add error-handling for when username/password incorrect (or just no token)

    # Reset headers (otherwise the multipart data screws up GET request) and set new authorisation with token
    client.headers = newHttpHeaders({
        "User-Agent": APP_NAME,
        "Authorization": fmt"bearer {token}"
    })

    # POC
    #let thingy = new_client.getContent("https://oauth.reddit.com/api/v1/me")
    #debugEcho fmt"thingy = {thingy}"

    # Finally can get saved posts
    echo "Fetching saved posts now..."
    var num_fetched_posts = 0
    var num_matched_posts = 0   # for numbering output
    # Can only fetch a limited number of posts at a time, so keep fetching til we recieve the `after` field to stop
    var after = ""
    while true:
        # Max limit per request seems to be 100 (https://www.reddit.com/dev/api#GET_user_{username}_saved)
        # TODO Add explanation of all URL params
        let response = client.getContent(fmt"https://oauth.reddit.com/user/{Reddit_username}/saved?limit=100&after={after}&count={num_fetched_posts}&show=all&raw_json=1")
        # TODO: Add error-handling

        let json_data = response.parseJson()["data"]

        # Print saved posts from the target subreddit
        let saved_posts = parsePostObjects(json_data)
        for post in saved_posts:
            if post.sub == target_sub:
                inc(num_matched_posts)
                printPostDetails(num_matched_posts, post)
        num_fetched_posts += saved_posts.len
        echo fmt"Total reddit posts scanned so far: {num_fetched_posts}"

        # Update `after` for next fetch request
        after = json_data["after"].getStr()
        if after.isEmptyOrWhitespace():   # All done - no more saved posts to fetch
            echo "All done. Bye :)"
            break
        echo "Fetching more posts..."
        #debugEcho fmt"after = '{after}'"


## Parse response JSON to return list of RedditPost objects
proc parsePostObjects(json_body: JsonNode): seq[RedditPost] =
    #[ There's apparently not much official documentation about Reddit's JSON; the most I could find was this archived 
    wiki last edited in 2016: https://github.com/reddit-archive/reddit/wiki/JSON

    The best you can do is just glean what you can from the official docs and check out your own saved-posts JSON file
    (https://www.reddit.com/user/{username}/saved.json) to grok what the fields mean
    (might help to paste it into a JSON-formatter first, like https://jsonformatter.curiousconcept.com/) ]#
    
    var ret: seq[RedditPost]

    let post_objects = json_body["children"]
    for post_object in post_objects:
        let post = post_object["data"]
        let post_type = post_object["kind"].getStr()

        # Parse data into RedditPost object and add it to the list
        ret.add(RedditPost(
            sub: post["subreddit_name_prefixed"].getStr(),
            main_text: case post_type 
                of $Link:      # Normal saved post
                    post["title"].getStr() 
                of $Comment:   # Saved comment; no title
                    post["body"].getStr() 
                else: 
                    "ERROR: Not link or comment",
            url: fmt"https://www.reddit.com{post[""permalink""].getStr()}"
        ))

    return ret


## Pretty-print details of reddit-post to stdout
proc printPostDetails(id_num: int, post: RedditPost) =
    echo()
    echo fmt"#{id_num}"
    echo post.sub
    echo "\"" & post.main_text & "\""   # Surround with double-quotes
    echo post.url
    echo()
