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
        post_container.widthMode = WidthMode_Expand

        # Add subreddit
        post_container.frame = newFrame(post.sub)

        # Add preview image (poc)
        let image_control = newControl()
        post_container.add(image_control)
        # Necessary to specify widthMode and heightMode for image to render
        image_control.widthMode = WidthMode_Expand
        image_control.heightMode = HeightMode_Expand
        let image = newImage()
        image.loadFromFile("assets/pepe.png")
        const image_height = 100
        image_control.onDraw = proc (event: DrawEvent) = 
            # TODO: Auto-calculate width based on height to maintain image aspect ratio
            event.control.canvas.drawImage(image, width=160, height=image_height)
        
        post_container.height = image_height + 35   # buffer

        # Add post's text
        # TODO: Align text next to image
        let content = newLabel(post.main_text)
        content.fontSize = 20
        content.widthMode = WidthMode_Fill
        post_container.add(content)

        # Add post to window
        main_window_container.add(post_container)

    # Finally, render window & run app
    window.show()
    app.run()
