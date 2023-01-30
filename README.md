# Saved-Post Searcher For Reddit
A simple CLI app to search your saved Reddit posts; WIP (doesn't work for other Reddit accounts yet)

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
```sh
# Install dependencies (specified in .nimble file)
nimble install -dy
# Build main file (flags already in nim.cfg file)
cd src/
nim c gui.nim
```

## TODO
- GUI app with search bar and image-previews and stuff
	- Fix app icon (make proper/bigger size - 64 instead of 32)
