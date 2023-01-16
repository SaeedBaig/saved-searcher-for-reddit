# Styleguide

## Syntactic
* Typical source-code file layout should be (in order): heading comment, library imports, custom imports, global constants, type definitions, function declarations, main function, and function definitions (in the order they're first called in the main function)
* Indent width is 4 spaces
* Variable/member names are `snake_case`
* Procedure/method names are `camelCase`
* Global constants are `SNAKE_CAPS`
* Custom types are `CapitalisedCamelCase`
* Line length limit is 120 chars; 128 max
* Call library procs with object syntax (`foo.bar()`), custom procs with functional syntax (`bar(foo)`)
* Differentiate between prints intended for end-user VS prints intended for debugging with `echo` VS `debugEcho`
* Procs called with no parentheses when used for side-effects (e.g. `capitalize name`), *with* parentheses when called for return value (e.g. `let name = capitalized(input)`)
* Procs should have an explanatory documentation comment above them (i.e. comment starting with `##`)
* Comments on the end of a line of code are preceded by 3 spaces (e.g. `sub: string   # subreddit`)
* Comments for readability have a leading space (e.g. `# Helper funcs`); comments commenting out potentially-useful 
  code have no leading space (e.g. `#debugEcho fmt"my_var = '{my_var}'"`)
* When using the value "returned" from a control-flow block, enclose the block in parentheses for readability (even though it's not necessary).

If the control-flow block isn't used for its expression, you can write it as normal without parentheses. E.g.
```nim
case roman_char
    of 'I':
        return 1
    of 'V':
        return 5
    of 'X':
        return 10
    ...
    else:
        quit("Error: invalid char")
```
However, when using the evaluated value of a control-flow block as an expression (e.g. as a return value, or assigning to a variable), enclose it in parentheses for readability (so it's clear you're treating this as an expression instead of just typical procedural code). E.g.
```nim
return (case roman_char
    of 'I':
        1
    of 'V':
        5
    of 'X':
        10
    ...
    else:
        quit("Error: invalid char")
  )
```
(this latter formulation would also be preferred cause it's DRYer btw - so do use parantheses where helpful).

* Use the most appropriate syntactic-sugar (e.g. use an enum to represent exhaustive fixed options rather than multiple constants; use a switch statement instead of an if-else-chain where possible)

## Semantic
* Prefer immutability to mutability (i.e. `let` over `var`)
* Limit scope of variables as much as possible (e.g. if a variable is only needed inside a for-loop, declare it inside the for-loop)
* Import only what's needed (e.g. `from base64 import encode` instead of `import std/base64`)
* Prefer unnamed expressions to single-use variables to avoid ambiguity if said variable is needed again later (e.g. `client.headers = newHttpHeaders({"User-Agent": APP_NAME})` instead of `let header = {"User-Agent": APP_NAME}; client.headers = newHttpHeaders(header)`)
* Don't repeat computations; store repeatedly-used results in variables (e.g. instead of `let title = response.parseJson()["title"]; let link = response.parseJson()["link"]`, do `let json_data = response.parseJson(); let title = json_data["title"]; let link = json_data["link"]`)
* Prefer string interpolation to concatenation for readability (e.g. `echo fmt"token = {token}"` instead of `echo "token = " & token`)
* Use the most appropriate data structure for the job (e.g. Know that list is a fixed size? Make it an array; No duplicates in that list and order not important? Make it a set)

**Golden Rule:** Use the expression that best signals the intent of the code (e.g. `inc(counter)` better signals intent than just `counter += 1`; `list.isEmpty()` better signals intent than just `list.len == 0`)

_Reminder: These are just guidelines, not laws; can deviate from any of these when you think there's a good reason to do so (e.g. may use single-use variable as an intermediate result in some complex calculation) - use your best judgement._
