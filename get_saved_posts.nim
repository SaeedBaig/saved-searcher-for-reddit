#[
Search a given Reddit user's saved posts, fetched via Reddit's official REST API
(compile with flag `-d:ssl` so the HTTP-POST requests work)
]#

import std/[httpclient, json]
from base64 import encode
from strformat import fmt
from strutils import multiReplace, isEmptyOrWhitespace

# Helper class to encapsulate the relevant post details we want to display
type RedditPost = object
    sub: string   # subreddit
    main_text: string
    url: string

# Type prefixes for different types of Reddit content (https://www.reddit.com/dev/api/#type_prefixes)
type RedditEntity = enum
    Comment="t1", Account="t2", Link="t3", Message="t4", Subreddit="t5", Award="t6"

# Helper functions
proc readPostObjectsIntoList(json_body: JsonNode, output_list: var seq[RedditPost])
proc printPostDetailsMatching(sub: string, posts: seq[RedditPost])

# A brief description of our app ("<app name>/<app version>"); can be anything
const APP_NAME      = "SavedSearcher/0.0.1"
# From your personal app you created (https://www.reddit.com/prefs/apps):
const APP_ID        = "oFwLNz7t3wUvhkV1atjQfQ"            # personal use script
const APP_SECRET    = "HhjA4bNm7KbmhcKBgjEKAqgHi0et4A"    # secret


when isMainModule:
    # Prompt for Reddit username & password (stdout.write instead of echo for no newline)
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
    # Since we fetch all the saved posts into memory ASAP and don't need to access the API afterwards, token 
    # expiry shouldn't be a problem
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
    echo "Fetching your saved posts. This may take a moment..."
    var after = ""
    var saved_posts: seq[RedditPost]
    # Can only fetch a limited number of posts at a time, so keep fetching til we recieve the `after` field to stop
    while true:
        # Fetch saved posts (max limit per request seems to be 100)
        # https://www.reddit.com/dev/api
        # TODO Add explanation of all URL params
        let response = client.getContent(fmt"""
            https://oauth.reddit.com/user/{Reddit_username}/saved?
            limit=100&
            after={after}&
            count={saved_posts.len}&
            show=all&
            raw_json=1
        """.multiReplace(("\n", ""), (" ", "")))   # remove whitespace from URL
        # TODO: Add error-handling

        # Read them into our list
        let json_data = response.parseJson()["data"]
        readPostObjectsIntoList(json_data, saved_posts)
        stdout.write fmt"Fetched {saved_posts.len} posts so far. "

        # Update `after` for next fetch request
        after = json_data["after"].getStr()
        if after.isEmptyOrWhitespace():   # All done - no more saved posts to fetch
            break
        # else
        echo "Fetching more..."
        #debugEcho fmt"after = '{after}'"

    echo()
    echo "All saved posts fetched - time to start searching"
    echo()

    # REPL
    while true:
        stdout.write "Which subreddit do you want to search from your saved posts (Ctrl+C to quit)? r/"
        # TODO: Add Ctrl+C handling for graceful exit
        let target_sub = "r/" & readLine(stdin)
        printPostDetailsMatching(target_sub, saved_posts)
        echo()


## Parse response JSON to add to the list of RedditPost objects
proc readPostObjectsIntoList(json_body: JsonNode, output_list: var seq[RedditPost]) =
    #[ There's apparently not much official documentation about Reddit's JSON; the most I could find was this archived 
    wiki last edited in 2016: https://github.com/reddit-archive/reddit/wiki/JSON

    The best you can do is just glean what you can from the official docs and check out your own saved-posts JSON file
    (https://www.reddit.com/user/{username}/saved.json) to grok what the fields mean
    (might help to paste it into a JSON-formatter first, like https://jsonformatter.curiousconcept.com/). ]#

    let post_objects = json_body["children"]
    for post_object in post_objects:
        let post = post_object["data"]
        let post_type = post_object["kind"].getStr()

        # Parse data into RedditPost object and add it to the list
        output_list.add(RedditPost(
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


## Pretty-print reddit-posts' from `sub` to stdout
proc printPostDetailsMatching(sub: string, posts: seq[RedditPost]) =
    var num_matched = 0   # for numbering output
    for post in posts:
        if post.sub == sub:
            inc(num_matched)
            echo()
            echo fmt"#{num_matched}"
            echo post.sub
            echo "\"" & post.main_text & "\""   # Surround with double-quotes
            echo post.url
            echo()            
    echo "(end)"
    #[ I had considered doing something more clever, like using a hashmap of subreddit-names to saved-posts for 
    faster searching by subreddit. But since Reddit only allows users to have a maximum of 1000 saved posts anyways 
    (which is nothing for modern CPUs), the speed boost from a map compared to straightforward iteration probably 
    wouldn't even be noticeable; so I'll stick to the simplicity & extensability of iteration. ]#
