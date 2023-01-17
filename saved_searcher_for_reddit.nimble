# Package

version       = "0.1.0"
author        = "Saeed Baig"
description   = "A simple app to search your saved Reddit posts"
license       = "MIT"
srcDir        = "src"
bin           = @["saved_searcher_for_reddit"]


# Dependencies

## Nim v1.6.10+ needed for proper OpenSSL 3 support
## https://www.mail-archive.com/nim-general@lists.nim-lang.org/msg22302.html
## Use choosenim to upgrade if Nim already installed
requires "nim >= 1.6.10"

## Will uncomment this line once the GUI's ready
#requires "nigui"
