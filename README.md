# Saved-Post Searcher For Reddit
A simple CLI app to search your saved Reddit posts; WIP (doesn't work for other Reddit accounts yet)

## Usage
Enter your details once to fetch all your saved posts via Reddit's API, then interactively search them in a REPL til you quit the program.

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
Would you like to search for saved comments (c), posts (p) or both (b)? 

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
Compile with Nim v1.6.10+ ([needed for proper OpenSSL 3 support](https://www.mail-archive.com/nim-general@lists.nim-lang.org/msg22302.html)):
```sh
# Build main file (flags already in nim.cfg file)
cd src/
nim c saved_searcher_for_reddit.nim
```
(use `choosenim` to upgrade Nim if you already have it installed)

## TODO
- GUI app with search bar and image-previews and stuff (in other branch)
- Fix Reddit-API permissions so app can work for other users
- Make binary releases for different platforms so users don't have to compile from source (don't forget to compile with `-d:release`!)
