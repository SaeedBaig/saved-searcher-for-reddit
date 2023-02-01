# Saved-Post Searcher For Reddit
A simple app to search your saved Reddit posts; WIP (doesn't work for other Reddit accounts yet)

## Usage
Enter your details once to fetch all your saved posts via Reddit's API, then interactively search them til you quit the program.

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
	- Show image previews for applicable posts
	- Add pagination to results (probably 100 at a time)
	- Make posts clickable links that lead to the site
	- Look into Label text getting cut off randomly in posts
	- Fix app icon (make proper/bigger size - 64 instead of 32)
