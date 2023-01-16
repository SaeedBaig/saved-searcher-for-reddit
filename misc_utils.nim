#[ Miscellaneous helper functions that felt too unrelated/inappropriate to add in the main file ]#

from terminal import getch
from strutils import strip

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
