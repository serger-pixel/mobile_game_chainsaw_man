local main = require("levels.menu")
local menu = {}

function menu.start()
    local backgroundMusic = audio.loadStream("sounds/menu_theme.mp3")
    audio.play(backgroundMusic, { loops = -1 })
    menu.background = display.newImageRect("/images/first_menu/background.jpg", display.contentWidth, display.contentHeight)
    menu.background.x = display.contentCenterX
    menu.background.y = display.contentCenterY
    menu.background:toBack()

    menu.title = display.newImageRect("/images/first_menu/title.png", display.contentWidth * 0.7, display.contentHeight * 0.4)
    menu.title.x = display.contentCenterX
    menu.title.y = display.contentCenterY * 0.5

    menu.playButton = display.newImageRect("/images/first_menu/play_button.png", display.contentWidth * 0.2, display.contentHeight* 0.1)
    menu.playButton.x = display.contentCenterX
    menu.playButton.y = display.contentCenterY * 1.7
    menu.playButton:addEventListener("touch", function (event)
        if event.phase == "began" then
            menu.title:removeSelf()
            menu.playButton:removeSelf()
            menu.background:removeSelf()
            main.isMain = true
            main.start()
        end
        
    end)
    
end

menu.start()