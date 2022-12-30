# Saved-Post Searcher For Reddit
A simple CLI app to search your saved Reddit posts (WIP, but functional)

## Usage
Enter your details once to fetch all your saved posts via Reddit's API, then interactively search them in a REPL loop til you quit.

### Example
```sh
$ ./get_saved_posts
Enter your Reddit username: johndoe
Enter your Reddit password: *********

Fetching your saved posts. This may take a moment...
Fetched 100 posts so far. Fetching more...
Fetched 200 posts so far. Fetching more...
…
All saved posts fetched!

Enter search text (Ctrl+C to quit): linux
Would you like to search for posts (p), subreddits (s) or both (b)? 

##############################################################################################################
####################### Search results for "linux" ###########################################################
##############################################################################################################

#1

r/linux - 'Tales of the M1 GPU - Asahi Linux'
https://www.reddit.com/r/linux/comments/z7zl2j/tales_of_the_m1_gpu_asahi_linux/
______________________________________________________________________________________________________________

#2

r/linuxmasterrace - 'My linux sticker setup!'
https://www.reddit.com/r/linuxmasterrace/comments/zqnyzz/my_linux_sticker_setup/
______________________________________________________________________________________________________________

#3

r/unixporn - '[sway] Arch Linux Purple'
https://www.reddit.com/r/unixporn/comments/y34f67/sway_arch_linux_purple/
______________________________________________________________________________________________________________

…

(end)


Enter search text (Ctrl+C to quit): 
```

## Building
Compile with Nim (v1.6.10+ needed for [proper OpenSSL 3 support](https://www.mail-archive.com/nim-general@lists.nim-lang.org/msg22302.html); use `choosenim` to upgrade if Nim already installed):
```sh
nim c -d:ssl --opt:speed get_saved_posts.nim
```

or for less verbiage:

```sh
nim c --verbosity:0 --hints:off -d:ssl --opt:speed get_saved_posts.nim
```

## TODO
- Add filter by comment or post (or both)
- Add command history for up-down arrow (like bash history)
- Add argument-parsing to alternatively use as single CLI command (e.g. `reddit_saved_search -u username -p password -r subreddit1 subreddit2 subreddit 3 ...`)
- Add `-h` flag for help
- Add `-q` (quiet) flag for no extraneous output (for piping, dumping output to file, etc)
- Make binary releases for different platforms so users don't have to compile it themselves (don't forget to compile with `-d:release`!)
- (one day) GUI app with search bar and image-previews and stuff
