# Styleguide

## Syntactic
- indentation is 4 spaces long
- variable/member names are `snake_case`
- proc/method names are `camelCase`
- configurable constants (e.g. app name) are `SNAKE_CAPS`
- line length limit should be 120 chars; 128 max
- call library procs with object syntax (`foo.bar()`), custom procs with functional syntax (`bar(foo)`)
- differentiate between prints intended for end-user VS for debugging with `echo` VS `debugEcho`
- comments on the same line as code are separated by 3 spaces (e.g. `sub: string   # subreddit`)
- comments for readability have a leading space (e.g. `# Helper funcs`); comments commenting out potentially-useful 
  code have no leading space (e.g. `#debugEcho fmt"my_var = '{my_var}'"`)

## Semantic
- Prefer immutability to mutability (i.e. `let` over `var`)
- Import only what's needed (e.g. `from base64 import encode` instead of `import std/base64`)
- Prefer temporary objects to single-use objects (e.g. `client.headers = newHttpHeaders({"User-Agent": APP_NAME})` instead of `let headers = {"User-Agent": APP_NAME}; client.headers = newHttpHeaders(headers)`)

_Note: These are all jus guidelines and may be deviated from if there's a strong reason as you see fit._
