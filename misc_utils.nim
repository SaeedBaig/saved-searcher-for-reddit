#[ Miscellaneous helper functions that felt too unrelated/inappropriate to add in the main file ]#

from terminal import getch
from strutils import strip, join
from sequtils import map
from strformat import fmt


## Read in password, typing '*' instead of echoing output
# (code adapted from example here: https://gist.github.com/mttaggart/aa67c96b61ebc1a9ba4cbfd655931492)
proc getPassword*(): string =
    const backspace_character = char(127)   # ASCII code
    var password = ""
    while password == "" or password[^1] notin ['\r', '\n']:
        let entered_char = getch()
        #debugEcho fmt"entered_char = {int(entered_char)} ('{entered_char}')"

        # Cant actually implement backspace behaviour (remove char already printed to stdout), but can at least 
        # not add/print for its character
        if entered_char != backspace_character:
            password.add(entered_char)
            stdout.write("*")
    echo()
    return password.strip()


## echo multiple times
# (just for consistency in stdout content breaks, and one place to edit it if we want it to be more)
proc bigEcho*() =
    echo()
    echo()


## Get a 1-char option from user of what they want to do
## (with a list of provided options & their explanatory strings given for prompting)
proc getSearchMode*(options: seq[(char, string)]): char = 
    # e.g. "Would you like to search for posts (p), subreddits (s) or both (b)? "
    let formatted_options = map(options, proc(option: (char, string)): string = fmt"{option[1]} ({option[0]})")
    stdout.write fmt"Would you like to search for {formatted_options[0 .. ^2].join("", "")} or {formatted_options[^1]}? "

    # Just get the chars (option[0]s)
    let allowed_searchmodes = map(options, proc(option: (char, string)): char = option[0])

    var search_mode: char
    while (search_mode = getch(); search_mode) notin allowed_searchmodes:
        # e.g. "Enter 'p' to search for posts, 's' to search for subreddits, or 'b' to search for both: "
        stdout.write "\nSorry, I don't understand... "
        let formatted_options = map(options, proc(option: (char, string)): string = fmt"'{option[0]}' to search for {option[1]}")
        stdout.write fmt"Enter {formatted_options[0 .. ^2].join("", "")} or {formatted_options[^1]}: "

    return search_mode
