#[ GUI for displaying Reddit posts ]#

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
    window.width = 800.scaleToDpi
    window.height = 600.scaleToDpi
    let main_window_container = newLayoutContainer(Layout_Vertical)
    window.add(main_window_container)

    # TODO: Make screen to enter username & password
    let saved_posts = fetchSavedPosts(reddit_username, reddit_password)   # TODO: Add error-handling

    # Add posts to GUI
    for post in saved_posts[0..20]:   # Just 20 posts at a time for now (TODO: add pagination for full results)
        # Create post container
        let post_container = newLayoutContainer(Layout_Horizontal)
        post_container.widthMode = WidthMode_Expand   # expand post-width to equal window-width

        # Add subreddit
        post_container.frame = newFrame(post.sub)

        # Add preview image (poc)
        let control = newControl()
        post_container.add(control)
        # (necessary to specify widthMode and heightMode for it to render; TODO: Choose something other than Fill)
        control.widthMode = WidthMode_Fill
        control.heightMode = HeightMode_Fill
        let preview = newImage()
        preview.loadFromFile("assets/pepe.png")
        control.onDraw = proc (event: DrawEvent) = event.control.canvas.drawImage(preview, width=160, height=100)
        # TODO: Expand post container's height to be >= preview height

        # Add post's text
        let content = newLabel(post.main_text)
        content.fontSize = 20
        post_container.add(content)

        # Add post to window
        main_window_container.add(post_container)

    # Finally, render window & run app
    window.show()
    app.run()
