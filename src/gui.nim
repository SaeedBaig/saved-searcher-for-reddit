#[ GUI POC for displaying Reddit posts (WIP) ]#

import nigui
from strformat import fmt

when isMainModule:
    # Start app
    app.init()

    # Create main window
    let window = newWindow("Saved-Post Searcher For Reddit")
    window.iconPath = "assets/app_icon.svg"
    window.width = 500
    window.height = 600
    let main_window_container = newLayoutContainer(Layout_Vertical)
    window.add(main_window_container)

    # Add posts
    for i in 1..15:
        # Create post container
        let post_container = newLayoutContainer(Layout_Horizontal)
        post_container.widthMode = WidthMode_Expand   # expand post-width to equal window-width
        # Center post container's content
        #post_container.xAlign = XAlign_Center
        #post_container.yAlign = YAlign_Center
        post_container.frame = newFrame(fmt"Post #{i}")

        let font_size: float = 20   # nigui expects fontsizes to be float

        # Add button to post container
        let button = newButton("Button")
        button.fontSize = font_size
        post_container.add(button)

        # Add label to post container
        let label = newLabel("Label")
        label.fontSize = font_size
        post_container.add(label)

        # Add post to window
        main_window_container.add(post_container)

    # Finally, render window & run app
    window.show()
    app.run()
