#[
Search a given Reddit user's saved posts, fetched via Reddit's official REST API
(compile with flag `-d:ssl` so the HTTP-POST requests work)
]#

import std/[httpclient, json]
from base64 import encode
from strformat import fmt
from strutils import isEmptyOrWhitespace, normalize, contains, repeat
from terminal import getch, styleBright, styledEcho, styledWriteLine   # styledWriteLine needed for styledEcho to compile
from sequtils import filter
from sugar import `=>`   # syntactic sugar for anonymous functions

from misc_utils import getPassword

# A brief description of our app ("<app name>/<app version>"); can be anything
const APP_NAME      = "SavedSearcher/0.0.1"
# From your personal app you created (https://www.reddit.com/prefs/apps):
const APP_ID        = "oFwLNz7t3wUvhkV1atjQfQ"            # personal use script
const APP_SECRET    = "HhjA4bNm7KbmhcKBgjEKAqgHi0et4A"    # secret

# Consts for printing (just eyeballed what looked good)
const SEPARATOR_WIDTH = 110
const HEADER_PREFIX_WIDTH = 23
const BANNER = "#".repeat(SEPARATOR_WIDTH)
const POST_SEPARATOR = "_".repeat(SEPARATOR_WIDTH)

# Helper class to encapsulate the relevant post details we want to display
type RedditPost = object
    sub: string   # subreddit
    main_text: string
    url: string

# Type prefixes for different types of Reddit content (https://www.reddit.com/dev/api/#type_prefixes)
type RedditEntity = enum
    Comment="t1", Account="t2", Link="t3", Message="t4", Subreddit="t5", Award="t6"

# Helper functions
proc readInSavedPosts(fetch_url: string, output_list: var seq[RedditPost]): string
proc printPosts(posts: seq[RedditPost])


when isMainModule:
    # Prompt for Reddit username & password (stdout.write instead of echo for no newline)
    stdout.write "Enter your Reddit username: "
    let Reddit_username = readLine(stdin)
    stdout.write "Enter your Reddit password: "
    let Reddit_password = getPassword()
    echo "\nFetching your saved posts, this may take a moment..."

    #[ Setup our header info:
    - A brief description of our app
    - HTTP Basic Auth with the Reddit-dev secrets ("Basic <CLIENT ID>:<CLIENT SECRET>") ]#
    let client = newHttpClient()
    client.headers = newHttpHeaders({
        "User-Agent": APP_NAME,
        "Authorization": "Basic " & base64.encode(fmt"{APP_ID}:{APP_SECRET}")
    })

    # Send our request for an OAuth token (valid for 24 hours)
    # Since we fetch all the saved posts into memory ASAP and don't need to access the API afterwards, token 
    # expiry shouldn't be a problem
    let auth_response = client.postContent(
        "https://www.reddit.com/api/v1/access_token",
        multipart=newMultipartData({"grant_type":"password", "username":Reddit_username, "password":Reddit_password})
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

    #[ Parameters for fetch URL are:
    - limit:    maximum #posts to fetch in this request (max Reddit allows is 100)
    - show:     optional; if "all", filters such as "hide links that I have voted on" will be disabled
    - raw_json: optional; if "1", gives literals in JSON for <, > and & instead of legacy &lt; &gt; and &amp;
    ]#
    let base_fetch_url = fmt"https://oauth.reddit.com/user/{Reddit_username}/saved?limit=100&show=all&raw_json=1"
    #[ There are also 2 additional parameters to pass on subsequent requests
    - after:    id of a post; serves as an anchor point for future requests
    - count:    total #posts fetched already (not required but recommended)

    More information at https://www.reddit.com/dev/api ]#
    
    # Can only fetch a limited number of posts at a time, so keep fetching til we get them all
    var after = readInSavedPosts(base_fetch_url, saved_posts)
    stdout.write fmt"Fetched {saved_posts.len} so far. "
    while not after.isEmptyOrWhitespace():
        echo "Fetching more..."
        after = readInSavedPosts(fmt"{base_fetch_url}&after={after}&count={saved_posts.len}", saved_posts)
        #debugEcho fmt"after = '{after}'"
        stdout.write fmt"Fetched {saved_posts.len} so far. "
    printPosts(saved_posts)
    echo "\nAll saved posts fetched\n"

    # REPL
    while true:   # TODO: Add Ctrl+C handling for graceful exit
        stdout.write "Enter search term, or nothing to display all posts (Ctrl+C to quit): "
        let search_input = readLine(stdin)

        if search_input == "":
            printPosts(saved_posts)
            echo()
            echo()
            continue
        # else

        stdout.write "Would you like to search for posts (p), subreddits (s) or both (b)? "
        var search_mode: char
        while (search_mode = getch(); search_mode) notin ['p', 's', 'b']:
            stdout.write "\nSorry, I don't understand... Enter 'p' to search by post, 's' to search by subreddit, or 'b' to search by both: "

        echo()
        echo()
        echo BANNER
        let header = fmt" Search results for ""{search_input}"" "
        echo "#".repeat(HEADER_PREFIX_WIDTH) & header & "#".repeat(SEPARATOR_WIDTH - HEADER_PREFIX_WIDTH - header.len)
        echo BANNER
        echo()

        let normalized_text = normalize(search_input)   # for case-insensitive searching

        let filtered_by_search_mode = case search_mode
        of 'p':
            saved_posts.filter((post) => 
                normalize(post.main_text).contains(normalized_text)
            )
        of 's':
            saved_posts.filter((post) => 
                normalize(post.sub).contains(normalized_text)
            )
        of 'b':
            saved_posts.filter((post) =>
                normalize(post.sub).contains(normalized_text) or normalize(post.main_text).contains(normalized_text)
            )
        else:
            quit("Error: `search_mode` not one of 'p', 's' or 'b'; don't know what to do")
        #[ I had considered doing something more clever, like using a hashmap of subreddit-names to saved-posts for 
        faster searching by subreddit. But since Reddit only allows users to have a maximum of 1000 saved posts anyways 
        (which is nothing for modern CPUs), the speed boost from a map compared to straightforward iteration probably 
        wouldn't even be noticeable; so I'll stick to the simplicity & extensability of iteration. ]#

        printPosts(filtered_by_search_mode)
        echo()
        echo()


## Fetch saved posts via Reddit API and parse them into the RedditPost-objects list; return `after` field from JSON
proc readInSavedPosts(fetch_url: string, output_list: var seq[RedditPost]): string =
    # Fetch saved Reddit posts
    let response = client.getContent(fetch_url)
    # TODO: Add error-handling (incl 500 Server Error, which I randomly got one time for no reason)
    let json_data = response.parseJson()["data"]

    # Now to parse them into RedditPost objects and add them to `output_list`
    #[ There's apparently not much official documentation about Reddit's JSON; the most I could find was this archived 
    wiki https://github.com/reddit-archive/reddit/wiki/JSON last edited in 2016

    The best you can do is probably just to glean what you can from the official docs and check out your own saved-posts
    JSON file (https://www.reddit.com/user/{username}/saved.json) to grok what the fields mean (might help to paste it 
    into a JSON-formatter first, like https://jsonformatter.curiousconcept.com/). ]#
    let post_objects = json_data["children"]
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
                    quit("ERROR: Encountered a post that's not a link or a comment; don't know how to handle it"),
            url: fmt"https://www.reddit.com{post[""permalink""].getStr()}"
        ))

    return json_data["after"].getStr()
    

## Pretty-print reddit posts to stdout
proc printPosts(posts: seq[RedditPost]) =
    if posts.len == 0:
        echo "(no results)"
        return
    # else
    var counter = 0   # for numbering output
    for post in posts:
        inc(counter)
        echo fmt"#{counter}"
        echo()
        styledEcho fmt"{post.sub} - ", styleBright, fmt"'{post.main_text}'"   # bold the post's maintext
        echo post.url
        echo POST_SEPARATOR
        echo()
    echo "(end)"
