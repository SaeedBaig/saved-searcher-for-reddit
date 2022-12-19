# Saved Post Searcher For Reddit
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
- Add argument-parsing to use as single CLI command (e.g. `reddit_saved_search -u username -p password -r subreddit`)
- Make binary releases for different platforms (so users don't have to compile it themselves)
- GUI app with search bar and previews and stuff instead of little CLI script
