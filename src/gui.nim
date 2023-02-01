#[ GUI for displaying Reddit posts ]#

import nigui

from saved_searcher_for_reddit import fetchSavedPosts
from misc_utils import getPassword

const WINDOW_WIDTH = 800
const WINDOW_HEIGHT = 600
const IMAGES_HEIGHT = 100   # make all post previews 100px tall
const FONT_SIZE = 20


when isMainModule:
    # Prompt for Reddit username & password (stdout.write instead of echo for no newline)
    # TODO: Add GUI screen to enter username & password
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
    window.width = WINDOW_WIDTH.scaleToDpi
    window.height = WINDOW_HEIGHT.scaleToDpi
    let main_window_container = newLayoutContainer(Layout_Vertical)
    window.add(main_window_container)

    let saved_posts = fetchSavedPosts(reddit_username, reddit_password)   # TODO: Add error-handling

    # Add posts to GUI (just 20 posts at a time for now)
    # TODO: implement pagination for full results
    for post in saved_posts[0..20]:
        # Create post container
        let post_container = newLayoutContainer(Layout_Horizontal)
        post_container.widthMode = WidthMode_Expand   # make post.width == window.width

        # Add subreddit
        post_container.frame = newFrame(post.sub)

        # Add preview image (poc)
        let image_control = newControl()
        post_container.add(image_control)
        # have to specify widthMode and heightMode for image to render
        image_control.widthMode = WidthMode_Expand
        image_control.heightMode = HeightMode_Expand
        let image = newImage()
        image.loadFromFile("assets/pepe.png")

        let aspect_ratio = image.width / image.height
        image_control.onDraw = proc (event: DrawEvent) = 
            event.control.canvas.drawImage(image, height=IMAGES_HEIGHT, width=int(IMAGES_HEIGHT*aspect_ratio))
        post_container.height = IMAGES_HEIGHT + 35   # plus buffer that I just eyeballed to look good

        # Add post's text
        # TODO: Align text next to image
        let content = newLabel(post.main_text)
        content.fontSize = FONT_SIZE
        content.widthMode = WidthMode_Fill
        post_container.add(content)

        # Add post to window
        main_window_container.add(post_container)

    # Finally, render window & run app
    window.show()
    app.run()
