#[ Search a given Reddit user's saved posts, fetched via Reddit's official REST API ]#

from httpclient import newHttpClient, newHttpHeaders, postContent, newMultipartData, getContent, HttpClient
from json import parseJson, hasKey, getStr, `[]`, items
from base64 import encode
from strformat import fmt
from strutils import isEmptyOrWhitespace, parseEnum

# A brief description of our app ("<app name>/<app version>"); can be anything
const APP_NAME      = "SavedSearcher/0.0.1"
# From your personal app you created (https://www.reddit.com/prefs/apps):
const APP_ID        = "oFwLNz7t3wUvhkV1atjQfQ"            # personal use script
const APP_SECRET    = "HhjA4bNm7KbmhcKBgjEKAqgHi0et4A"    # secret

# Type prefixes for different types of Reddit content (https://www.reddit.com/dev/api/#type_prefixes)
type RedditEntity = enum Comment="t1", Post="t3"
# (there are other types, but for our purposes only need t1 and t3)

# Helper class to encapsulate the relevant post details we want to display
type RedditPost* = object
    sub*: string   # subreddit
    main_text*: string
    url*: string
    reddit_type: RedditEntity

# Helper function
proc readInSavedPosts(fetch_url:string, output_list: var seq[RedditPost], client:HttpClient): string
# TODO: See if can move var next to ':'


## Fetch a Reddit user's saved posts and return them as a list
## (need their username & password to access)
proc fetchSavedPosts*(reddit_username:string, reddit_password:string): seq[RedditPost] =
    #[Setup our header info:
    - A brief description of our app
    - HTTP Basic Auth with the Reddit-dev secrets ("Basic <CLIENT ID>:<CLIENT SECRET>")]#
    let client = newHttpClient()
    client.headers = newHttpHeaders({
        "User-Agent": APP_NAME,
        "Authorization": "Basic " & base64.encode(fmt"{APP_ID}:{APP_SECRET}")
    })

    # Send our request for an OAuth token (valid for 24 hours)
    #[Since we fetch all the saved posts into memory ASAP and don't need to access the API afterwards, token expiry 
    shouldn't be a problem]#
    let auth_response = client.postContent(
        "https://www.reddit.com/api/v1/access_token",
        multipart=newMultipartData({"grant_type":"password", "username":reddit_username, "password":reddit_password})
    ).parseJson()

    # Error-handling
    if not auth_response.hasKey "access_token":
        echo auth_response["error"].getStr
        quit("Error: Username or password incorrect")
    # else
    let token = auth_response["access_token"].getStr()

    # Reset headers (otherwise the multipart data screws up GET request) and set new authorisation with token
    client.headers = newHttpHeaders({
        "User-Agent": APP_NAME,
        "Authorization": fmt"bearer {token}"
    })

    # POC
    #let thingy = new_client.getContent("https://oauth.reddit.com/api/v1/me")
    #debugEcho fmt"{thingy=}"

    # Finally can fetch saved posts
    var saved_posts: seq[RedditPost]

    #[Parameters for fetch URL are:
    - limit:    maximum #posts to fetch in this request (max Reddit allows is 100)
    - show:     optional; if "all", filters such as "hide links that I have voted on" will be disabled
    - raw_json: optional; if "1", gives literal chars for '<', '>' and '&' (instead of legacy &lt; &gt; and &amp;)
    ]#
    let base_fetch_url = fmt"https://oauth.reddit.com/user/{reddit_username}/saved?limit=100&show=all&raw_json=1"
    #[ There are also 2 additional parameters to pass on subsequent requests
    - after:    id of a post; serves as an anchor point for future requests
    - count:    total #posts fetched already (not required but recommended)

    More information at https://www.reddit.com/dev/api ]#
    
    # Can only fetch a limited number of posts at a time, so keep fetching til we get them all
    var after = readInSavedPosts(base_fetch_url, saved_posts, client)
    stdout.write fmt"Fetched {saved_posts.len} posts"
    while not after.isEmptyOrWhitespace():
        echo ", fetching more..."
        after = readInSavedPosts(fmt"{base_fetch_url}&after={after}&count={saved_posts.len}", saved_posts, client)
        stdout.write fmt"Fetched {saved_posts.len} posts"

    return saved_posts


## Fetch saved posts via Reddit API and parse them into the RedditPost-objects list; return `after` field from JSON
proc readInSavedPosts(fetch_url: string, output_list: var seq[RedditPost], client:HttpClient): string =
    # Fetch saved Reddit posts
    let response = client.getContent(fetch_url)
    # TODO: Add error-handling (incl 500 Server Error, which I randomly got one time for no reason)
    let json_data = response.parseJson()["data"]

    # Now to parse them into RedditPost objects and add them to `output_list`
    #[There's apparently not much official documentation about Reddit's JSON; the most I could find was this archived 
    wiki https://github.com/reddit-archive/reddit/wiki/JSON last edited in 2016

    The best you can do is probably just to glean what you can from the official docs and check out your own saved-
    posts JSON file (https://www.reddit.com/user/{username}/saved.json) to grok what the fields mean (might help to 
    paste it into a JSON-formatter first, like https://jsonformatter.curiousconcept.com/).]#
    let post_objects = json_data["children"]
    for post_object in post_objects:
        let post = post_object["data"]
        let post_type = post_object["kind"].getStr()

        # Parse data into RedditPost object and add it to the list
        output_list.add(RedditPost(
            sub: post["subreddit_name_prefixed"].getStr(),
            main_text: (case post_type 
                of $Post:      # Normal saved post
                    post["title"].getStr() 
                of $Comment:   # Saved comment; no title
                    post["body"].getStr() 
                else:
                    quit("ERROR: Encountered a post that's not a link or a comment; don't know how to handle it")
            ),
            url: fmt"https://www.reddit.com{post[""permalink""].getStr()}",
            reddit_type: parseEnum[RedditEntity](post_type)
        ))

    return json_data["after"].getStr()
