#[ GUI POC for displaying Reddit posts (WIP) ]#

import nigui

from saved_searcher_for_reddit import fetchSavedPosts
from misc_utils import getPassword


when isMainModule:
    # Prompt for Reddit username & password (stdout.write instead of echo for no newline)
    stdout.write "Enter your Reddit username: "
    let reddit_username = readLine(stdin)
    stdout.write "Enter your Reddit password: "
    let reddit_password = getPassword()
    echo "\nFetching your saved posts, this may take a moment..."

    # Start app
    app.init()

    # Create main window
    let window = newWindow("Saved-Post Searcher For Reddit")
    window.iconPath = "assets/app_icon.svg"
    window.width = 800
    window.height = 600
    let main_window_container = newLayoutContainer(Layout_Vertical)
    window.add(main_window_container)

    # TODO: Make screen to enter username & password
    let saved_posts = fetchSavedPosts(reddit_username, reddit_password)   # TODO: Add error-handling
    for post in saved_posts[0..99]:   # Just 100 posts at a time (TODO: add pagination for full results)
        # Create post container
        let post_container = newLayoutContainer(Layout_Horizontal)
        post_container.widthMode = WidthMode_Expand   # expand post-width to equal window-width
        # Center post container's content
        #post_container.xAlign = XAlign_Center
        #post_container.yAlign = YAlign_Center
        post_container.frame = newFrame(post.sub)

        const font_size: float = 20   # nigui expects font size to be float

        # Add button to post container
        #[let button = newButton("Button")
        button.fontSize = font_size
        post_container.add(button)]#

        # Add label to post container
        let label = newLabel(post.main_text)
        label.fontSize = font_size
        post_container.add(label)

        # Add post to window
        main_window_container.add(post_container)

    # Finally, render window & run app
    window.show()
    app.run()
