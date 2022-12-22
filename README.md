# Saved-Post Searcher For Reddit
A simple app to search your saved Reddit posts (WIP)

Compile with Nim >=1.6.10:
```sh
nim c -d:ssl --opt:speed get_saved_posts.nim
```
_(1.6.10+ needed for [proper OpenSSL 3 support](https://www.mail-archive.com/nim-general@lists.nim-lang.org/msg22302.html); use `choosenim` to upgrade if Nim already installed)._

Or for less verbiage...

```sh
nim c --verbosity:0 --hints:off -d:ssl --opt:speed get_saved_posts.nim
```

TODO:
- Add filter by subreddit or post-text (or both)
- Add filter by comment or post (or both)
- Add argument-parsing to alternatively use as single CLI command (e.g. `reddit_saved_search -u username -p password -r subreddit1 subreddit2 subreddit 3 ...`)
- Add `-h` flag for help
- Add `-q` (quiet) flag for no extraneous output (for piping, dumping output to file, etc)
- Make binary releases for different platforms so users don't have to compile it themselves (don't forget to compile with `-d:release`!)
- (one day) GUI app with search bar and image-previews and stuff
