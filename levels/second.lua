local graphics = require("graphics")
local physics = require("physics")

local level = {}

function level.stop(event)
    if event.phase == "began" then
        level.pauseContinueButton:removeSelf()
        level.pauseFrame:removeSelf()
        level.background:removeSelf()
        level.leftWall:removeSelf()
        level.rightWall:removeSelf()
        level.rightButton:removeSelf()
        level.leftButton:removeSelf()
        level.path:removeSelf()
        level.character:removeSelf()
        level.animation.spriteRun:removeSelf()
        for i = #level.creatures, 1, -1 do
            local creat = level.creatures[i]
            if creat then
                creat:removeSelf()
            end
        end
        level.textPause:removeSelf()
        level.homeButton:removeSelf()
        level.reloadButton:removeSelf()
        level.textPoint:removeSelf()
        timer.cancel(level.generateTimer)
        timer.cancel(level.fixAnimationTimer)
        physics.stop()
    end
end

function level.reload(event)
    level.stop(event)
    level.start()
end

function level.start()
    level.isPause = false

    physics.start()

    level.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
    level.pauseContinueButton.x = display.contentWidth - 100
    level.pauseContinueButton.y = 200

    level.background = display.newImageRect("/images/second_level/background.jpg", display.contentWidth, display.contentHeight)
    level.background.x = display.contentCenterX
    level.background.y = display.contentCenterY
    level.background:toBack()

    level.leftWall = display.newRect(0, display.contentCenterY, display.contentWidth * 0.01, display.contentHeight)
    level.leftWall:setFillColor(0,0,0,0)
    physics.addBody(level.leftWall, "static", { bounce = 0})

    level.rightWall = display.newRect(display.contentWidth, display.contentCenterY, display.contentWidth * 0.01, display.contentHeight)
    level.rightWall:setFillColor(0,0,0,0)
    physics.addBody(level.rightWall, "static", { bounce = 0})

    function level.pauseOrContinue(event)
        if event.phase == "began" then
            if level.isPause == false then
                level.isPause = true

                for i = #level.creatures, 1, -1 do
                    local creat = level.creatures[i]
                    if creat and creat.setLinearVelocity then
                        creat:setLinearVelocity(0,  0) 
                    end
                end
                
                physics.setGravity(0, 0)

                level.character:setLinearVelocity(0,0)

                timer.cancel(level.generateTimer)

                level.animation.spriteRun:pause()

                level.pauseContinueButton:removeSelf()
                level.pauseContinueButton = display.newImageRect("/images/shared/resume_button.png", 200, 200)
                level.pauseContinueButton.x = display.contentWidth - 100
                level.pauseContinueButton.y = 200
                level.pauseContinueButton:addEventListener("touch", level.pauseOrContinue)

                level.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                level.pauseFrame:setFillColor(0, 0, 0, 0.8)

                level.textPause = display.newText({
                    text = "Пауза",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                level.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                level.homeButton.x = display.contentCenterX - 200
                level.homeButton.y = display.contentCenterY
                level.homeButton:addEventListener("touch", level.stop)
                
                level.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                level.reloadButton.x = display.contentCenterX + 200
                level.reloadButton.y = display.contentCenterY
                level.reloadButton:addEventListener("touch", level.reload)
            else 
                level.isPause = false

                physics.setGravity(0, 9.8) 

                level.animation.spriteRun:play(1, 0, 2)

                timer.performWithDelay( math.random(4000, 7000), level.createObstacle)

                level.pauseContinueButton:removeSelf()
                level.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
                level.pauseContinueButton.x = display.contentWidth - 100
                level.pauseContinueButton.y = 200
                level.pauseContinueButton:addEventListener("touch", level.pauseOrContinue)

                level.pauseFrame:removeSelf()
                level.homeButton:removeSelf()
                level.reloadButton:removeSelf()
                level.textPause:removeSelf()

                level.character:setLinearVelocity(level.currentSpeed,0)

                level.generateTimer = timer.performWithDelay(1000, level.generateCreatures, 0)
                for i = #level.creatures, 1, -1 do
                    local creat = level.creatures[i]
                    if creat and creat.setLinearVelocity then
                        creat:setLinearVelocity(0,  level.speedDown) 
                    end
                end

            end
        end
    end
    level.pauseContinueButton:addEventListener("touch", level.pauseOrContinue)

    level.character = {}

    level.animation = {}

    level.animation.sheetOptionsRunRight = 
        { 
            width = 69,
            height = 44,
            numFrames = 8
        } 
    level.animation.imageSheetRunRight = graphics.newImageSheet("/images/second_level/chainsaw_run_right.png", level.animation.sheetOptionsRunRight) 
    level.animation.sequenceDataRunRight = 
        { 
            name = "run", 
            start = 1, 
            count = 8, 
            time = 600, 
            loopCount = 0,
            loopDirection = "forward" 
        }



    level.animation.sheetOptionsRunLeft = 
        { 
            width = 69,
            height = 44,
            numFrames = 8
        } 
    level.animation.imageSheetRunLeft = graphics.newImageSheet("/images/second_level/chainsaw_run_left.png",  level.animation.sheetOptionsRunLeft) 
    level.animation.sequenceDataRunLeft = 
        { 
            name = "run", 
            frames = {8, 7, 6, 5, 4, 3, 2, 1},
            time = 600,
            loopCount = 0
        }

    level.animation.spriteRun = display.newSprite(level.animation.imageSheetRunRight, level.animation.sequenceDataRunRight)
    level.animation.scaleCharacter = 5 
    level.animation.spriteRun.x = display.contentCenterX
    level.animation.spriteRun.y = 0
    
    level.animation.spriteRun:scale(level.animation.scaleCharacter, level.animation.scaleCharacter)
    level.animation.spriteRun:play(1, 0, 2)

    level.characterPlace = display.contentWidth * 0.5
    level.character = display.newRect(level.characterPlace, 0, level.animation.sheetOptionsRunRight.height *  (level.animation.scaleCharacter - 2),level.animation.sheetOptionsRunRight.width *  (level.animation.scaleCharacter - 2.7))
    level.character:setFillColor(1, 43, 57, 0.5)
    level.character.y = display.contentCenterY* 1.3
    level.offset = display.contentWidth * 0.04
    level.fixAnimationTimer = timer.performWithDelay(1,function(self, event)
        level.animation.spriteRun.x = level.character.x + level.offset
        level.animation.spriteRun.y = level.character.y - display.contentHeight * 0.01
    end, 0)
    physics.addBody(level.character, "dynamic", { bounce = 0, fixedRotation = true, linearDamping = 1 })


    level.currentSpeed = 400

    level.rightButton = display.newImageRect("/images/second_level/right_button.png", display.contentWidth * 0.2, display.contentWidth * 0.2)
    level.rightButton.x = display.contentCenterX + display.contentWidth * 0.1
    level.rightButton.y = display.contentCenterY* 1.6

    function level.moveRight(event)
        if event.phase == "began" then
            level.currentSpeed = 400
            level.offset = display.contentWidth * 0.04
            level.animation.spriteRun:removeSelf()
            level.animation.spriteRun = display.newSprite(level.animation.imageSheetRunRight, level.animation.sequenceDataRunRight)
            level.animation.scaleCharacter = 5 
            level.animation.spriteRun:scale(level.animation.scaleCharacter, level.animation.scaleCharacter)
            level.animation.spriteRun:play(1, 0, 2)

            level.character:setLinearVelocity(level.currentSpeed, 0)
        end 
    end
    level.rightButton:addEventListener("touch", level.moveRight)

    level.leftButton = display.newImageRect("/images/second_level/left_button.png", display.contentWidth * 0.2, display.contentWidth * 0.2)
    level.leftButton.x = display.contentCenterX - display.contentWidth * 0.1
    level.leftButton.y = display.contentCenterY* 1.6

    function level.moveLeft(event)
        if event.phase == "began" then
            level.currentSpeed = -400
            level.offset = -1 * display.contentWidth * 0.04
            level.animation.spriteRun:removeSelf()
            level.animation.spriteRun = display.newSprite(level.animation.imageSheetRunLeft, level.animation.sequenceDataRunLeft)
            level.animation.scaleCharacter = 5 
            level.animation.spriteRun:scale(level.animation.scaleCharacter, level.animation.scaleCharacter)
            level.animation.spriteRun:play(1, 0, 2)

            level.character:setLinearVelocity(level.currentSpeed, 0)
        end
    end
    level.leftButton:addEventListener("touch", level.moveLeft)

    level.path = display.newRect(display.contentCenterX, display.contentCenterY * 1.5, display.contentWidth,  display.contentHeight * 0.02)
    level.path:setFillColor(255, 255, 255, 0.4)
    physics.addBody(level.path, "static" , {bounce = 0, linearDamping = 1})


    level.peoples = {"images/second_level/first_people.png", "images/second_level/second_people.png", "images/second_level/third_people.png"}
    level.demons = {"images/second_level/first_demon.png", "images/second_level/second_demon.png", "images/second_level/third_demon.png"}

    level.speedDown = 500
    level.creatures = {}
    function level.generateCreatures()
        local paint
        local radius = math.random(100,200)
        local leftBorder = radius
        local rightBorder = display.pixelWidth - radius
        local centerX = math.random(leftBorder, rightBorder)
        local centerY = 400
        local colorNumb = math.random(0,1)
        local circle = display.newCircle(centerX, centerY, radius)
        local randomPicture = math.random(1, 3)
        if colorNumb == 0 then
            circle:setFillColor(0, 255, 0, 1)
            paint = {
                type = "image",
                filename = level.peoples[randomPicture]
            }
            circle.ID = "people"
        else
            paint = {
                type = "image",
                filename = level.demons[randomPicture]
            }
            circle:setFillColor(255, 0, 0, 1)
            circle.ID = "demon"
        end
        circle.fill = paint
        physics.addBody(circle, "dynamic")
        circle:setLinearVelocity(0,  level.speedDown)
        circle.isSensor = 0
        function table.find(t, target)
            for i = 1, #t do
                if t[i] == target then
                    return i
                end
            end
            return nil
        end
        level.path:addEventListener("collision", function (event)
                if event.other.ID == "people" or event.other.ID == "demon" then
                    event.other:removeSelf()
                end
        end)
        table.insert(level.creatures, circle)

    end
    level.generateTimer = timer.performWithDelay(1000, level.generateCreatures, 0)

    level.currentPoint = 0

    level.finishPoint = 10

    level.textPoint = display.newText({
        text = "Уничтожен  " .. level.currentPoint .. "/" .. level.finishPoint,
        x = 310, 
        y = 200, 
        fontSize = 60
    })

    level.textPoint:setFillColor(0,0,0)

    function level.updateText()
        if level.isPause == false then
            level.textPoint.text = "Уничтожено  " .. level.currentPoint .. "/" .. level.finishPoint
        end
    end

    level.character:addEventListener("collision", function (event)
        if event.phase == "began" then
            if event.other.ID == "people" then
                level.currentPoint = level.currentPoint - 1
            end
            if event.other.ID == "demon" then
                level.currentPoint = level.currentPoint + 1
            end
            level.updateText()
        end
    end)
end


return level