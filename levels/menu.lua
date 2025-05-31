local graphics = require("graphics")
local physics = require("physics")
local main = {}
local physics = require("physics")

local thirdLevel = {}
thirdLevel.status = false
thirdLevel.isPlay = false


function thirdLevel.stop(event)
    if event.phase == "began" then
        thirdLevel.background:removeSelf()
        thirdLevel.rightButton:removeSelf()
        thirdLevel.leftButton:removeSelf()
        thirdLevel.textPoint:removeSelf()
        for i = #thirdLevel.obstacles, 1, -1 do
            thirdLevel.obstacles[i]:removeSelf()
        end

        for i = #thirdLevel.points, 1, -1 do
            if thirdLevel.points[i] and thirdLevel.points[i].removeSelf then
                thirdLevel.points[i]:removeSelf()
            end
        end
        thirdLevel.character:removeSelf()
        thirdLevel.bottomWall:removeSelf()
        thirdLevel.pauseFrame:removeSelf()
        thirdLevel.textPause:removeSelf()
        thirdLevel.homeButton:removeSelf()
        thirdLevel.reloadButton:removeSelf()
        thirdLevel.textPoint:removeSelf()
        thirdLevel.pauseContinueButton:removeSelf()
        thirdLevel.isPlay = false
        physics.stop()
    end
    audio.stop()
end

function  thirdLevel.reload(event)
    thirdLevel.stop(event)
    thirdLevel.start()
end

function thirdLevel.start()
    thirdLevel.isPause = false
    thirdLevel.isPlay = true
    physics.start()
    thirdLevel.backgroundMusic = audio.loadStream("sounds/third_level_theme.mp3")
    audio.play(thirdLevel.backgroundMusic, { loops = -1 })

    physics.setGravity(0, 9.8)

    thirdLevel.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
    thirdLevel.pauseContinueButton.x = display.contentWidth - 100
    thirdLevel.pauseContinueButton.y = 200

    thirdLevel.radius = 80

    thirdLevel.obstacles = {}
    thirdLevel.points = {}

    local startY = display.contentHeight * 0.15
    local position = math.random(0, 1)
    local textX = display.contentWidth * 0.2
    local textY = display.contentHeight * 0.1

    thirdLevel.currentPoint = 0
    thirdLevel.finishPoint = 5

    thirdLevel.textPoint = display.newText({
        text = "Счет:  " .. thirdLevel.currentPoint .. "/" .. thirdLevel.finishPoint,
        x =  textX,
        y = textY, 
        fontSize = 100
    })
    thirdLevel.textPoint:setFillColor(0,0,0)
    thirdLevel.updateTextTimer = timer.performWithDelay(1, function (event)
        thirdLevel.textPoint.text = "Счет:  " .. thirdLevel.currentPoint .. "/" .. thirdLevel.finishPoint
    end, 0)

    for i = 1, 5, 1 do
        local width = math.random(display.contentWidth * 0.6, display.contentWidth * 0.8)
        local height = math.random(display.contentHeight * 0.02, display.contentHeight * 0.06)
        local x
        if position == 1 then
            x =  display.contentWidth - width/2
            position = 0
        else
            x = width/2
            position = 1
        end
        local y = startY + height
        startY = startY + height/2
        local obstacle = display.newImageRect("/images/third_level/colone.png", width, height)
        obstacle.x = x
        obstacle.y = y
        local point = display.newImageRect("/images/third_level/point.png", thirdLevel.radius, thirdLevel.radius)
        if position == 0 then
            point.x = x + width/2 - thirdLevel.radius
        else
            point.x = x - width/2 + thirdLevel.radius
        end
        point.y = y - height/2 - thirdLevel.radius
        table.insert(thirdLevel.obstacles, obstacle)
        table.insert(thirdLevel.points, point)
        physics.addBody(obstacle, "static", {bounce = 0})
        physics.addBody(point, "static")
        point:addEventListener("collision", function(event)
            if event.other == thirdLevel.character then
                local sound = audio.loadSound("/sounds/point.wav")
                audio.play(sound)
                thirdLevel.currentPoint = thirdLevel.currentPoint  + 1
                event.target:removeSelf()
                if thirdLevel.currentPoint == thirdLevel.finishPoint then
                    thirdLevel.isPause = true
                
                    physics.setGravity(0, 0)

                    thirdLevel.pauseContinueButton:removeSelf()
                    thirdLevel.pauseContinueButton = display.newImageRect("/images/shared/resume_button.png", 200, 200)
                    thirdLevel.pauseContinueButton.x = display.contentWidth - 100
                    thirdLevel.pauseContinueButton.y = 200
                    thirdLevel.pauseContinueButton:addEventListener("touch", thirdLevel.pauseOrContinue)

                    thirdLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                    thirdLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                    thirdLevel.textPause = display.newText({
                        text = "Пауза",
                        x = display.contentCenterX, 
                        y = display.contentCenterY * 0.6, 
                        fontSize = 60
                    })

                    thirdLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                    thirdLevel.homeButton.x = display.contentCenterX - 200
                    thirdLevel.homeButton.y = display.contentCenterY
                    thirdLevel.homeButton:addEventListener("touch", thirdLevel.stop)
                    
                    thirdLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                    thirdLevel.reloadButton.x = display.contentCenterX + 200
                    thirdLevel.reloadButton.y = display.contentCenterY
                    thirdLevel.reloadButton:addEventListener("touch", thirdLevel.reload)
                    thirdLevel.status = true
                    event = {}
                    event.phase = "began"
                    thirdLevel.stop(event)
                    physics.stop()
                    main.start()
                end
            end
        end)
        startY = startY + height/2 + thirdLevel.radius * 3
    end

    thirdLevel.character = display.newCircle(display.pixelWidth - 200, display.pixelHeight -200, thirdLevel.radius)
    thirdLevel.character.x = display.contentWidth * 0.5
    thirdLevel.character.y = display.contentHeight * 0.8
    local paint = {
        type = "image",
        filename = "/images/third_level/character.png"
    }
    thirdLevel.character.fill = paint
    physics.addBody(thirdLevel.character, "dinamic", {bounce = 0})

    thirdLevel.topWall = display.newRect(display.contentCenterX, 0, display.contentWidth, display.contentHeight * 0.01)
    thirdLevel.topWall:setFillColor(0, 0, 0, 0)
    physics.addBody(thirdLevel.topWall, "static", {bounce = 0})

    thirdLevel.bottomWall = display.newImageRect("/images/third_level/colone.png", display.contentWidth, display.contentHeight * 0.01)
    thirdLevel.bottomWall.x = display.contentCenterX
    thirdLevel.bottomWall.y = display.contentHeight * 0.9
    physics.addBody(thirdLevel.bottomWall, "static", {bounce = 0})

    thirdLevel.leftWall = display.newRect(0, display.contentCenterY, display.contentWidth * 0.02, display.contentHeight)
    thirdLevel.leftWall:setFillColor(0, 0, 0, 0)
    physics.addBody(thirdLevel.leftWall, "static",{bounce = 0})

    thirdLevel.rightWall = display.newRect(display.contentWidth, display.contentCenterY, display.contentWidth * 0.02, display.contentHeight)
    thirdLevel.rightWall:setFillColor(0, 0, 0, 0)
    physics.addBody(thirdLevel.rightWall, "static", {bounce = 0})

    thirdLevel.rightButton = display.newImageRect("/images/third_level/right_button.png", 300, 200)
    thirdLevel.rightButton.x = display.contentCenterX + display.contentWidth * 0.13
    thirdLevel.rightButton.y = display.contentHeight * 0.95
    thirdLevel.rightButton:rotate(-20)

    thirdLevel.leftButton = display.newImageRect("/images/third_level/left_button.png", 300, 200)
    thirdLevel.leftButton.x = display.contentCenterX - display.contentWidth * 0.13
    thirdLevel.leftButton.y = display.contentHeight * 0.95
    thirdLevel.leftButton:rotate(20)


    thirdLevel.animation = {}

    local function left(event)
        thirdLevel.animation.sheetOptionsWindLeft = 
        { 
            width = 150,
            height = 150,
            numFrames = 40
        } 
        thirdLevel.animation.imageSheetWindLeft = graphics.newImageSheet("/images/third_level/wind_left_sprite.png", thirdLevel.animation.sheetOptionsWindLeft) 
        thirdLevel.animation.sequenceDataWindLeft = 
        { 
            name = "run", 
            start = 1, 
            count = 40, 
            time = 600, 
            loopCount = 1,
        }
        thirdLevel.animation.spriteWindLeft = display.newSprite(thirdLevel.animation.imageSheetWindLeft, thirdLevel.animation.sequenceDataWindLeft)
        thirdLevel.animation.scale= 5 
        thirdLevel.animation.spriteWindLeft:scale(5, 5)
        thirdLevel.animation.spriteWindLeft:rotate(30)
        thirdLevel.animation.spriteWindLeft:play(1, 0, 2)
        thirdLevel.animation.spriteWindLeft.x = display.contentCenterX - display.contentWidth * 0.13
        thirdLevel.animation.spriteWindLeft.y = display.contentHeight * 0.86
        thirdLevel.animation.spriteWindLeft:addEventListener("sprite", function(event)
            if event.phase == "ended" then
                event.target:removeSelf()
            end
        end)

        thirdLevel.character:applyLinearImpulse(-0.6, -0.6, thirdLevel.character.x, thirdLevel.character.y)

    end

    local function right(event)
        thirdLevel.animation.sheetOptionsWindRight = 
        { 
            width = 150,
            height = 150,
            numFrames = 40
        } 
        thirdLevel.animation.imageSheetWindRight = graphics.newImageSheet("/images/third_level/wind_right_sprite.png", thirdLevel.animation.sheetOptionsWindRight) 
        thirdLevel.animation.sequenceDataWindRight = 
        { 
            name = "run", 
            start = 1, 
            count = 40, 
            time = 600, 
            loopCount = 1,
            frames = {40, 39, 38, 37, 36, 35, 34, 33, 32, 31,
            30, 29, 28, 27, 26, 25, 24, 23, 22, 21,
            20, 19, 18, 17, 16, 15, 14, 13, 12, 11,
            10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
        }
        thirdLevel.character:applyLinearImpulse(0.6, -0.6, thirdLevel.character.x, thirdLevel.character.y)
        thirdLevel.animation.spriteWindRight = display.newSprite(thirdLevel.animation.imageSheetWindRight, thirdLevel.animation.sequenceDataWindRight)
        thirdLevel.animation.scale= 5 
        thirdLevel.animation.spriteWindRight.x = display.contentCenterX + display.contentWidth * 0.13
        thirdLevel.animation.spriteWindRight.y = display.contentHeight * 0.86
        thirdLevel.animation.spriteWindRight:scale(5, 5)
        thirdLevel.animation.spriteWindRight:rotate(-30)
        thirdLevel.animation.spriteWindRight:play(1, 0, 2)
        thirdLevel.animation.spriteWindRight:addEventListener("sprite", function(event)
            if event.phase == "ended" then
                event.target:removeSelf()
            end
        end)
    end

    thirdLevel.rightButton:addEventListener("tap", right)
    thirdLevel.leftButton:addEventListener("tap", left)

    thirdLevel.background = display.newImageRect("/images/third_level/background.jpg", display.contentWidth, display.contentHeight)
    thirdLevel.background.x = display.contentCenterX
    thirdLevel.background.y = display.contentCenterY
    thirdLevel.background:toBack()

    function thirdLevel.pauseOrContinue(event)
        if event.phase == "began" then
            if thirdLevel.isPause == false then
                thirdLevel.isPause = true
                
                physics.setGravity(0, 0)

                thirdLevel.pauseContinueButton:removeSelf()
                thirdLevel.pauseContinueButton = display.newImageRect("/images/shared/resume_button.png", 200, 200)
                thirdLevel.pauseContinueButton.x = display.contentWidth - 100
                thirdLevel.pauseContinueButton.y = 200
                thirdLevel.pauseContinueButton:addEventListener("touch", thirdLevel.pauseOrContinue)

                thirdLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                thirdLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                thirdLevel.textPause = display.newText({
                    text = "Пауза",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                thirdLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                thirdLevel.homeButton.x = display.contentCenterX - 200
                thirdLevel.homeButton.y = display.contentCenterY
                thirdLevel.homeButton:addEventListener("touch", function (event)
                    thirdLevel.stop(event)
                    main.start()
                end)
                
                thirdLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                thirdLevel.reloadButton.x = display.contentCenterX + 200
                thirdLevel.reloadButton.y = display.contentCenterY
                thirdLevel.reloadButton:addEventListener("touch", thirdLevel.reload)
            else 
                thirdLevel.isPause = false

                physics.setGravity(0, 9.8) 

                thirdLevel.pauseContinueButton:removeSelf()
                thirdLevel.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
                thirdLevel.pauseContinueButton.x = display.contentWidth - 100
                thirdLevel.pauseContinueButton.y = 200
                thirdLevel.pauseContinueButton:addEventListener("touch", thirdLevel.pauseOrContinue)

                thirdLevel.pauseFrame:removeSelf()
                thirdLevel.homeButton:removeSelf()
                thirdLevel.reloadButton:removeSelf()
                thirdLevel.textPause:removeSelf()
            end
        end
    end
    thirdLevel.pauseContinueButton:addEventListener("touch", thirdLevel.pauseOrContinue)
end



local graphics = require("graphics")
local physics = require("physics")

local secondLevel = {}
secondLevel.status = false
secondLevel.isPlay = false

function secondLevel.stop(event)
    if event.phase == "began" then
        secondLevel.pauseContinueButton:removeSelf()
        secondLevel.pauseFrame:removeSelf()
        secondLevel.background:removeSelf()
        secondLevel.leftWall:removeSelf()
        secondLevel.rightWall:removeSelf()
        secondLevel.rightButton:removeSelf()
        secondLevel.leftButton:removeSelf()
        secondLevel.path:removeSelf()
        secondLevel.character:removeSelf()
        secondLevel.animation.spriteRun:removeSelf()
        for i = #secondLevel.creatures, 1, -1 do
            local creat = secondLevel.creatures[i]
            if creat and creat.removeSelf then
                creat:removeSelf()
            end
        end
        secondLevel.textPause:removeSelf()
        secondLevel.homeButton:removeSelf()
        secondLevel.reloadButton:removeSelf()
        secondLevel.textPoint:removeSelf()
        timer.cancel(secondLevel.generateTimer)
        timer.cancel(secondLevel.fixAnimationTimer)
        timer.cancel(secondLevel.checkWinTimer)
        physics.stop()
        secondLevel.isPlay = false
        physics.stop()
    end
    audio.stop()
end

function secondLevel.reload(event)
    secondLevel.stop(event)
    secondLevel.start()
end

function secondLevel.start()
    secondLevel.isPause = false
    secondLevel.isPlay = true
    secondLevel.backgroundMusic = audio.loadStream("sounds/second_level_theme.mp3")
    audio.play(secondLevel.backgroundMusic, { loops = -1 })

    physics.start()
    physics.setGravity(0, 9.8)
    secondLevel.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
    secondLevel.pauseContinueButton.x = display.contentWidth - 100
    secondLevel.pauseContinueButton.y = 200

    secondLevel.background = display.newImageRect("/images/second_level/background.jpg", display.contentWidth, display.contentHeight)
    secondLevel.background.x = display.contentCenterX
    secondLevel.background.y = display.contentCenterY
    secondLevel.background:toBack()

    secondLevel.leftWall = display.newRect(0, display.contentCenterY, display.contentWidth * 0.01, display.contentHeight)
    secondLevel.leftWall:setFillColor(0,0,0,0)
    physics.addBody(secondLevel.leftWall, "static", { bounce = 0})

    secondLevel.rightWall = display.newRect(display.contentWidth, display.contentCenterY, display.contentWidth * 0.01, display.contentHeight)
    secondLevel.rightWall:setFillColor(0,0,0,0)
    physics.addBody(secondLevel.rightWall, "static", { bounce = 0})

    function secondLevel.pauseOrContinue(event)
        if event.phase == "began" then
            if secondLevel.isPause == false then
                secondLevel.isPause = true

                for i = #secondLevel.creatures, 1, -1 do
                    local creat = secondLevel.creatures[i]
                    if creat and creat.setLinearVelocity then
                        creat:setLinearVelocity(0,  0) 
                    end
                end
                
                physics.setGravity(0, 0)

                secondLevel.character:setLinearVelocity(0,0)

                timer.cancel(secondLevel.generateTimer)

                secondLevel.animation.spriteRun:pause()

                secondLevel.pauseContinueButton:removeSelf()
                secondLevel.pauseContinueButton = display.newImageRect("/images/shared/resume_button.png", 200, 200)
                secondLevel.pauseContinueButton.x = display.contentWidth - 100
                secondLevel.pauseContinueButton.y = 200
                secondLevel.pauseContinueButton:addEventListener("touch", secondLevel.pauseOrContinue)

                secondLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                secondLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                secondLevel.textPause = display.newText({
                    text = "Пауза",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                secondLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                secondLevel.homeButton.x = display.contentCenterX - 200
                secondLevel.homeButton.y = display.contentCenterY
                secondLevel.homeButton:addEventListener("touch", function(event)
                    secondLevel.stop(event)
                    main.start()
                end)
                
                secondLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                secondLevel.reloadButton.x = display.contentCenterX + 200
                secondLevel.reloadButton.y = display.contentCenterY
                secondLevel.reloadButton:addEventListener("touch", secondLevel.reload)
            else 
                secondLevel.isPause = false

                physics.setGravity(0, 9.8) 

                secondLevel.animation.spriteRun:play(1, 0, 2)

                timer.performWithDelay( math.random(4000, 7000), secondLevel.createObstacle)

                secondLevel.pauseContinueButton:removeSelf()
                secondLevel.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
                secondLevel.pauseContinueButton.x = display.contentWidth - 100
                secondLevel.pauseContinueButton.y = 200
                secondLevel.pauseContinueButton:addEventListener("touch", secondLevel.pauseOrContinue)

                secondLevel.pauseFrame:removeSelf()
                secondLevel.homeButton:removeSelf()
                secondLevel.reloadButton:removeSelf()
                secondLevel.textPause:removeSelf()

                secondLevel.character:setLinearVelocity(secondLevel.currentSpeed,0)

                secondLevel.generateTimer = timer.performWithDelay(1000, secondLevel.generateCreatures, 0)
                for i = #secondLevel.creatures, 1, -1 do
                    local creat = secondLevel.creatures[i]
                    if creat and creat.setLinearVelocity then
                        creat:setLinearVelocity(0,  secondLevel.speedDown) 
                    end
                end

            end
        end
    end
    secondLevel.pauseContinueButton:addEventListener("touch", secondLevel.pauseOrContinue)

    secondLevel.character = {}

    secondLevel.animation = {}

    secondLevel.animation.sheetOptionsRunRight = 
        { 
            width = 69,
            height = 44,
            numFrames = 8
        } 
    secondLevel.animation.imageSheetRunRight = graphics.newImageSheet("/images/second_level/chainsaw_run_right.png", secondLevel.animation.sheetOptionsRunRight) 
    secondLevel.animation.sequenceDataRunRight = 
        { 
            name = "run", 
            start = 1, 
            count = 8, 
            time = 600, 
            loopCount = 0,
            loopDirection = "forward" 
        }



    secondLevel.animation.sheetOptionsRunLeft = 
        { 
            width = 69,
            height = 44,
            numFrames = 8
        } 
    secondLevel.animation.imageSheetRunLeft = graphics.newImageSheet("/images/second_level/chainsaw_run_left.png",  secondLevel.animation.sheetOptionsRunLeft) 
    secondLevel.animation.sequenceDataRunLeft = 
        { 
            name = "run", 
            frames = {8, 7, 6, 5, 4, 3, 2, 1},
            time = 600,
            loopCount = 0
        }

    secondLevel.animation.spriteRun = display.newSprite(secondLevel.animation.imageSheetRunRight, secondLevel.animation.sequenceDataRunRight)
    secondLevel.animation.scaleCharacter = 5 
    secondLevel.animation.spriteRun.x = display.contentCenterX
    secondLevel.animation.spriteRun.y = 0
    
    secondLevel.animation.spriteRun:scale(secondLevel.animation.scaleCharacter, secondLevel.animation.scaleCharacter)
    secondLevel.animation.spriteRun:play(1, 0, 2)

    secondLevel.characterPlace = display.contentWidth * 0.5
    secondLevel.character = display.newRect(secondLevel.characterPlace, 0, secondLevel.animation.sheetOptionsRunRight.height *  (secondLevel.animation.scaleCharacter - 2),secondLevel.animation.sheetOptionsRunRight.width *  (secondLevel.animation.scaleCharacter - 2.7))
    secondLevel.character:setFillColor(1, 43, 57, 0.5)
    secondLevel.character.y = display.contentCenterY* 1.3
    secondLevel.offset = display.contentWidth * 0.04
    secondLevel.fixAnimationTimer = timer.performWithDelay(1,function(self, event)
        secondLevel.animation.spriteRun.x = secondLevel.character.x + secondLevel.offset
        secondLevel.animation.spriteRun.y = secondLevel.character.y - display.contentHeight * 0.01
    end, 0)
    physics.addBody(secondLevel.character, "dynamic", { bounce = 0, fixedRotation = true, linearDamping = 1 })


    secondLevel.currentSpeed = 400

    secondLevel.rightButton = display.newImageRect("/images/second_level/right_button.png", display.contentWidth * 0.2, display.contentWidth * 0.2)
    secondLevel.rightButton.x = display.contentCenterX + display.contentWidth * 0.1
    secondLevel.rightButton.y = display.contentCenterY* 1.6

    function secondLevel.moveRight(event)
        if event.phase == "began" then
            secondLevel.currentSpeed = 400
            secondLevel.offset = display.contentWidth * 0.04
            secondLevel.animation.spriteRun:removeSelf()
            secondLevel.animation.spriteRun = display.newSprite(secondLevel.animation.imageSheetRunRight, secondLevel.animation.sequenceDataRunRight)
            secondLevel.animation.scaleCharacter = 5 
            secondLevel.animation.spriteRun:scale(secondLevel.animation.scaleCharacter, secondLevel.animation.scaleCharacter)
            secondLevel.animation.spriteRun:play(1, 0, 2)

            secondLevel.character:setLinearVelocity(secondLevel.currentSpeed, 0)
        end 
    end
    secondLevel.rightButton:addEventListener("touch", secondLevel.moveRight)

    secondLevel.leftButton = display.newImageRect("/images/second_level/left_button.png", display.contentWidth * 0.2, display.contentWidth * 0.2)
    secondLevel.leftButton.x = display.contentCenterX - display.contentWidth * 0.1
    secondLevel.leftButton.y = display.contentCenterY* 1.6

    function secondLevel.moveLeft(event)
        if event.phase == "began" then
            secondLevel.currentSpeed = -400
            secondLevel.offset = -1 * display.contentWidth * 0.04
            secondLevel.animation.spriteRun:removeSelf()
            secondLevel.animation.spriteRun = display.newSprite(secondLevel.animation.imageSheetRunLeft, secondLevel.animation.sequenceDataRunLeft)
            secondLevel.animation.scaleCharacter = 5 
            secondLevel.animation.spriteRun:scale(secondLevel.animation.scaleCharacter, secondLevel.animation.scaleCharacter)
            secondLevel.animation.spriteRun:play(1, 0, 2)

            secondLevel.character:setLinearVelocity(secondLevel.currentSpeed, 0)
        end
    end
    secondLevel.leftButton:addEventListener("touch", secondLevel.moveLeft)

    secondLevel.path = display.newRect(display.contentCenterX, display.contentCenterY * 1.5, display.contentWidth,  display.contentHeight * 0.02)
    secondLevel.path:setFillColor(255, 255, 255, 0.4)
    physics.addBody(secondLevel.path, "static" , {bounce = 0, linearDamping = 1})


    secondLevel.peoples = {"/images/second_level/first_people.png", "/images/second_level/second_people.png", "/images/second_level/third_people.png"}
    secondLevel.demons = {"/images/second_level/first_demon.png", "/images/second_level/second_demon.png", "/images/second_level/third_demon.png"}

    secondLevel.speedDown = 500
    secondLevel.creatures = {}
    function secondLevel.generateCreatures()
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
                filename = secondLevel.peoples[randomPicture]
            }
            circle.ID = "people"
        else
            paint = {
                type = "image",
                filename = secondLevel.demons[randomPicture]
            }
            circle:setFillColor(255, 0, 0, 1)
            circle.ID = "demon"
        end
        circle.fill = paint
        physics.addBody(circle, "dynamic")
        circle:setLinearVelocity(0,  secondLevel.speedDown)
        circle.isSensor = 0
        function table.find(t, target)
            for i = 1, #t do
                if t[i] == target then
                    return i
                end
            end
            return nil
        end
        secondLevel.path:addEventListener("collision", function (event)
                if event.other.ID == "people" or event.other.ID == "demon" then
                    event.other:removeSelf()
                end
        end)
        table.insert(secondLevel.creatures, circle)

    end
    secondLevel.generateTimer = timer.performWithDelay(1000, secondLevel.generateCreatures, 0)

    secondLevel.currentPoint = 0

    secondLevel.finishPoint = 10

    secondLevel.textPoint = display.newText({
        text = "Уничтожен  " .. secondLevel.currentPoint .. "/" .. secondLevel.finishPoint,
        x = 310, 
        y = 200, 
        fontSize = 60
    })

    secondLevel.textPoint:setFillColor(0,0,0)

    function secondLevel.updateText()
        if secondLevel.isPause == false then
            secondLevel.textPoint.text = "Уничтожено  " .. secondLevel.currentPoint .. "/" .. secondLevel.finishPoint
            if secondLevel.currentPoint < 0 then
                secondLevel.isPause = true

                physics.setGravity(0, 0)
                secondLevel.character:setLinearVelocity(0,0)
                timer.cancel(secondLevel.generateTimer)

                secondLevel.animation.spriteRun:pause()



                secondLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                secondLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                secondLevel.textPause = display.newText({
                    text = "Вы проиграли",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                secondLevel.pauseContinueButton:removeSelf()
                secondLevel.pauseContinueButton = display.newImageRect("/images/shared/resume_button.png", 200, 200)
                secondLevel.pauseContinueButton.x = display.contentWidth - 100
                secondLevel.pauseContinueButton.y = 200

                secondLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                secondLevel.homeButton.x = display.contentCenterX - 200
                secondLevel.homeButton.y = display.contentCenterY
                secondLevel.homeButton:addEventListener("touch", function(event)
                    secondLevel.stop(event)
                    main.start()
                end)
                
                secondLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                secondLevel.reloadButton.x = display.contentCenterX + 200
                secondLevel.reloadButton.y = display.contentCenterY
                secondLevel.reloadButton:addEventListener("touch", secondLevel.reload)

            end
        end
        secondLevel.checkWinTimer = timer.performWithDelay(1, function(even)
            if secondLevel.currentPoint == secondLevel.finishPoint and secondLevel.isPlay == true then
                secondLevel.isPause = true
                secondLevel.isPlay = false

                physics.setGravity(0, 0)
                secondLevel.character:setLinearVelocity(0,9.8)
                for i = #secondLevel.creatures, 1, -1 do
                    local creat = secondLevel.creatures[i]
                    if creat and creat.setLinearVelocity then
                        creat:setLinearVelocity(0,  0) 
                    end
                end
                timer.cancel(secondLevel.generateTimer)

                secondLevel.animation.spriteRun:pause()

                secondLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                secondLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                secondLevel.textPause = display.newText({
                    text = "Вы победили",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                secondLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                secondLevel.homeButton.x = display.contentCenterX - 200
                secondLevel.homeButton.y = display.contentCenterY
                secondLevel.homeButton:addEventListener("touch", function(event)
                    secondLevel.stop(event)
                    main.start()
                end)
                
                secondLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                secondLevel.reloadButton.x = display.contentCenterX + 200
                secondLevel.reloadButton.y = display.contentCenterY
                secondLevel.reloadButton:addEventListener("touch", secondLevel.reload)
                physics.setGravity(0, 9.8)
                local event = {}
                event.phase = "began"
                secondLevel.stop(event)
                secondLevel.status = true
                thirdLevel.start()
            end
        end)
    end

    secondLevel.character:addEventListener("collision", function (event)
        if event.phase == "began" then
            if event.other.ID == "people" then
                secondLevel.currentPoint = secondLevel.currentPoint - 1
                local sound = audio.loadSound("/sounds/attack.wav")
                    audio.play(sound)
                    timer.performWithDelay(1000, function()
                        audio.stop(sound)
                    end)
            end
            if event.other.ID == "demon" then
                secondLevel.currentPoint = secondLevel.currentPoint + 1
                local sound = audio.loadSound("/sounds/attack.wav")
                    audio.play(sound)
            end
        end
            secondLevel.updateText()
    end)
end





local firstLevel = {}
firstLevel.status = false
firstLevel.isPlay = false

function firstLevel.stop(event)
    if event.phase == "began" then
        timer.cancel(firstLevel.pointTimer)
        timer.cancel(firstLevel.fixCharacterTimer)
        timer.cancel(firstLevel.scrollGroundTimer)
        timer.cancel(firstLevel.moveObstaclesTimer)
        timer.cancel(firstLevel.fixAnimationTimer)
        if firstLevel.pauseContinueButton:removeSelf() then
            firstLevel.pauseContinueButton:removeSelf()
        end
        firstLevel.pauseFrame:removeSelf()
        firstLevel.textPause:removeSelf()
        firstLevel.homeButton:removeSelf()
        firstLevel.reloadButton:removeSelf()
        firstLevel.background:removeSelf()
        firstLevel.character:removeSelf()
        firstLevel.animation.spriteRun:removeSelf()
        firstLevel.jumpButton:removeSelf()
        if firstLevel.obstacles then
            for i = #firstLevel.obstacles, 1, -1 do
                local obs = firstLevel.obstacles[i]
                obs:removeSelf()
            end
        end
        firstLevel.firstPath:removeSelf()
        firstLevel.secondPath:removeSelf()
        firstLevel.textPoint:removeSelf()
        firstLevel.isPlay = false
    end
    audio.stop()
end

function firstLevel.reload(event)
    firstLevel.stop(event)
    firstLevel.isPlay = true
    firstLevel.start()
end

function firstLevel.start()
    audio.stop(firstLevel.backgroundMusic)
    firstLevel.backgroundMusic = audio.loadStream("sounds/first_level_theme.mp3")
    audio.setVolume(0.5)
    audio.play(firstLevel.backgroundMusic, { loops = -1 })
    firstLevel.isPause = false
    firstLevel.isPlay = true

    firstLevel.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
    firstLevel.pauseContinueButton.x = display.contentWidth - 100
    firstLevel.pauseContinueButton.y = 200
    firstLevel. cntSpawn = 1
    function firstLevel.pauseOrContinue(event)
        if event.phase == "began" then
            if firstLevel.isPause == false then
                firstLevel.isPause = true

                physics.setGravity(0, 0)
                firstLevel.character:setLinearVelocity(0,0)

                firstLevel.animation.spriteRun:pause()

                firstLevel.pauseContinueButton:removeSelf()
                firstLevel.pauseContinueButton = display.newImageRect("/images/shared/resume_button.png", 200, 200)
                firstLevel.pauseContinueButton.x = display.contentWidth - 100
                firstLevel.pauseContinueButton.y = 200
                firstLevel.pauseContinueButton:addEventListener("touch", firstLevel.pauseOrContinue)

                firstLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                firstLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                firstLevel.textPause = display.newText({
                    text = "Пауза",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                firstLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                firstLevel.homeButton.x = display.contentCenterX - 200
                firstLevel.homeButton.y = display.contentCenterY
                firstLevel.homeButton:addEventListener("touch", function (event)
                    audio.stop(firstLevel.backgroundMusic)
                    firstLevel.stop(event)
                    main.start()
                end)
                
                firstLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                firstLevel.reloadButton.x = display.contentCenterX + 200
                firstLevel.reloadButton.y = display.contentCenterY
                firstLevel.reloadButton:addEventListener("touch", firstLevel.reload)

                
                
            else 
                firstLevel.isPause = false

                physics.setGravity(0, firstLevel.scalePhysics)
                firstLevel.character:setLinearVelocity(0,firstLevel.scalePhysics)

                firstLevel.animation.spriteRun:play(1, 0, 2)

                timer.performWithDelay( math.random(4000, 7000), firstLevel.createObstacle)

                firstLevel.pauseContinueButton:removeSelf()
                firstLevel.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
                firstLevel.pauseContinueButton.x = display.contentWidth - 100
                firstLevel.pauseContinueButton.y = 200
                firstLevel.pauseContinueButton:addEventListener("touch", firstLevel.pauseOrContinue)

                firstLevel.pauseFrame:removeSelf()
                firstLevel.homeButton:removeSelf()
                firstLevel.reloadButton:removeSelf()
                firstLevel.textPause:removeSelf()

            end
        end
    end
    firstLevel.pauseContinueButton:addEventListener("touch", firstLevel.pauseOrContinue)

    firstLevel.character = {}

    firstLevel.animation = {}

    firstLevel.animation.sheetOptionsRun = 
        { 
            width = 69,
            height = 44,
            numFrames = 8
        } 
    firstLevel.animation.imageSheetRun = graphics.newImageSheet("/images/first_level/chainsaw_run.png", firstLevel.animation.sheetOptionsRun) 
    firstLevel.animation.sequenceDataRun = 
        { 
            name = "run", 
            start = 1, 
            count = 8, 
            time = 600, 
            loopCount = 0,
            loopDirection = "forward" 
        }

    physics.start()
    firstLevel.animation.spriteRun = display.newSprite(firstLevel.animation.imageSheetRun, firstLevel.animation.sequenceDataRun)
    firstLevel.animation.scaleCharacter = 5 
    firstLevel.animation.spriteRun.x = display.contentCenterX
    firstLevel.animation.spriteRun.y = 0
    
    firstLevel.animation.spriteRun:scale(firstLevel.animation.scaleCharacter, firstLevel.animation.scaleCharacter)
    firstLevel.animation.spriteRun:play(1, 0, 2)

    firstLevel.characterPlace = display.contentWidth * 0.2
    firstLevel.character = display.newRect(firstLevel.characterPlace, 0, firstLevel.animation.sheetOptionsRun.height *  (firstLevel.animation.scaleCharacter - 2),firstLevel.animation.sheetOptionsRun.width *  (firstLevel.animation.scaleCharacter - 2))
    firstLevel.character:setFillColor(1, 43, 57, 0.5)
    firstLevel.fixAnimationTimer = timer.performWithDelay(1,function(self, event)
        offset = display.contentWidth * 0.04
        firstLevel.animation.spriteRun.x = firstLevel.character.x + offset
        firstLevel.animation.spriteRun.y = firstLevel.character.y 
    end, 0)
    function firstLevel.fixCharacterX()
        firstLevel.character.x = firstLevel.characterPlace
    end
    physics.addBody(firstLevel.character, "dynamic", { bounce = 0, fixedRotation = true })
    firstLevel.fixCharacterTimer = timer.performWithDelay(1, firstLevel.fixCharacterX, 0)

    firstLevel.scalePhysics = 100
    firstLevel.forceJump = -15
    physics.setGravity(0, firstLevel.scalePhysics) 
    firstLevel.isOnGround = false
    function firstLevel.onCollisionWithCharacter(event)
        if event.phase == "began" and firstLevel.isPause == false then
            if event.other.ID == "path" then
                firstLevel.isOnGround = true
                firstLevel.animation.spriteRun:play(1, 0, 2)
            end
        end
    end
    
    firstLevel.jumpButton = display.newImageRect("/images/shared/chainsaw_button.png", 100, 300)
    firstLevel.jumpButton.x = display.contentCenterX
    firstLevel.jumpButton.y = display.contentHeight * 0.9
    function firstLevel.ontouchJumpButton(event)
        if event.phase == "began" and firstLevel.isPause == false then
            if firstLevel.isOnGround == true then
                local sound = audio.loadSound("/sounds/jump.wav")
                audio.play(sound)
                firstLevel.isOnGround = false
                firstLevel.character:applyLinearImpulse(0, firstLevel.forceJump, firstLevel.character.x, firstLevel.character.y)
                firstLevel.animation.spriteRun:setFrame(2)
                firstLevel.animation.spriteRun:pause()
            end
        end
    end

    firstLevel.character:addEventListener("collision", firstLevel.onCollisionWithCharacter)
    firstLevel.jumpButton:addEventListener("touch", firstLevel.ontouchJumpButton)

    firstLevel.firstPath = display.newImageRect("/images/first_level/path.png", display.contentWidth, 80)
    firstLevel.firstPath.ID = "path"
    firstLevel.firstPath.x = display.contentWidth * 0.5
    firstLevel.firstPath.y = display.contentCenterY
    physics.addBody(firstLevel.firstPath, "static", {bounce = 0})

    firstLevel.secondPath = display.newImageRect("/images/first_level/path.png", display.contentWidth, 80)
    firstLevel.secondPath.ID = "path"
    firstLevel.secondPath.x = display.contentWidth * 1.5
    firstLevel.secondPath.y = display.contentCenterY
    physics.addBody(firstLevel.secondPath, "static", {bounce = 0})

    firstLevel.scrollSpeed = 10

    function firstLevel.scrollGround(event)
        if firstLevel.isPause == false then
            local dx = -firstLevel.scrollSpeed 

            firstLevel.firstPath.x = firstLevel.firstPath.x + dx
            firstLevel.secondPath.x = firstLevel.secondPath.x + dx

            if firstLevel.firstPath.x < -display.contentWidth / 2 then
                firstLevel.firstPath.x = firstLevel.secondPath.x + display.contentWidth
            end
            if firstLevel.secondPath.x < -display.contentWidth / 2 then
                firstLevel.secondPath.x = firstLevel.firstPath.x + display.contentWidth
            end
        end
    end
    firstLevel.scrollGroundTimer = timer.performWithDelay(1, firstLevel.scrollGround, 0)

    firstLevel.background = display.newImageRect("/images/first_level/background.jpg", display.contentWidth, display.contentHeight)
    firstLevel.background.x = display.contentCenterX
    firstLevel.background.y = display.contentCenterY
    firstLevel.background:toBack()

    firstLevel.obstacles = {}

    function firstLevel.createObstacle()
        if firstLevel.isPause == false  then
            if #firstLevel.obstacles < 2 then
                local obstacle = display.newImageRect("/images/first_level/obstacle.png", 100, 330)
                obstacle.x = display.contentWidth
                obstacle.y = display.contentCenterY - 120
                table.insert(firstLevel.obstacles, obstacle)
                physics.addBody(obstacle, "static")
                timer.performWithDelay( math.random(1200, 1700), firstLevel.createObstacle)
                obstacle.ID = "obstacle"
            end
        end
    end

    timer.performWithDelay( math.random(1200, 1700), firstLevel.createObstacle)
    function firstLevel.moveObstacles()
        if firstLevel.isPause == false then
            for i = #firstLevel.obstacles, 1, -1 do
                local obs = firstLevel.obstacles[i]
                obs.x = obs.x - 10
                if obs.x < -50 then
                    display.remove(obs)
                    table.remove(firstLevel.obstacles, i)
                end
            end
        end
    end
    firstLevel.moveObstaclesTimer = timer.performWithDelay(1, firstLevel.moveObstacles, 0)

    firstLevel.currentPoint = 0

    firstLevel.finishPoint = 10

    firstLevel.textPoint = display.newText({
        text = "Пройдено  " .. firstLevel.currentPoint .. "/" .. firstLevel.finishPoint .. " м",
        x = 310, 
        y = 200, 
        fontSize = 60
    })
    function firstLevel.updateText()
        if firstLevel.isPause == false then
            firstLevel.currentPoint = firstLevel.currentPoint + 1
            firstLevel.textPoint.text = "Пройдено  " .. firstLevel.currentPoint .. "/" .. firstLevel.finishPoint .. " м"
            if firstLevel.currentPoint == firstLevel.finishPoint then
                firstLevel.isPause = true

                physics.setGravity(0, 0)
                firstLevel.character:setLinearVelocity(0,0)

                firstLevel.animation.spriteRun:pause()

                firstLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                firstLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                firstLevel.textPause = display.newText({
                    text = "Вы победили",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                firstLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                firstLevel.homeButton.x = display.contentCenterX - 200
                firstLevel.homeButton.y = display.contentCenterY
                firstLevel.homeButton:addEventListener("touch", firstLevel.stop)
                
                firstLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                firstLevel.reloadButton.x = display.contentCenterX + 200
                firstLevel.reloadButton.y = display.contentCenterY
                firstLevel.reloadButton:addEventListener("touch", firstLevel.reload)
                physics.setGravity(0, 9.8)
                firstLevel.status = true
                local event = {}
                event.phase = "began"
                firstLevel.stop(event)
                secondLevel.start()
            end
        end
    end
    firstLevel.pointTimer = timer.performWithDelay(1000, firstLevel.updateText, 0)

    firstLevel.character:addEventListener("collision", function (event) 
        if event.phase == "began" and event.other.ID == "obstacle"then
            firstLevel.isPause = true

                physics.setGravity(0, 0)
                firstLevel.character:setLinearVelocity(0,0)

                firstLevel.animation.spriteRun:pause()



                firstLevel.pauseFrame = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight * 0.5)
                firstLevel.pauseFrame:setFillColor(0, 0, 0, 0.8)

                firstLevel.textPause = display.newText({
                    text = "Вы проиграли",
                    x = display.contentCenterX, 
                    y = display.contentCenterY * 0.6, 
                    fontSize = 60
                })

                firstLevel.pauseContinueButton:removeSelf()
                firstLevel.pauseContinueButton = display.newImageRect("/images/shared/resume_button.png", 200, 200)
                firstLevel.pauseContinueButton.x = display.contentWidth - 100
                firstLevel.pauseContinueButton.y = 200

                firstLevel.homeButton = display.newImageRect("/images/shared/home_button.png", 200, 200)
                firstLevel.homeButton.x = display.contentCenterX - 200
                firstLevel.homeButton.y = display.contentCenterY
                firstLevel.homeButton:addEventListener("touch",  function(event)
                    firstLevel.stop(event)
                    main.start()
                end)
                
                firstLevel.reloadButton = display.newImageRect("/images/shared/reload_button.png", 200, 200)
                firstLevel.reloadButton.x = display.contentCenterX + 200
                firstLevel.reloadButton.y = display.contentCenterY
                firstLevel.reloadButton:addEventListener("touch", firstLevel.reload)
                physics.setGravity(0, 9.8)
        end
    end)
end





function main.clear()
    main.background:removeSelf()
    main.firstLevelButton:removeSelf()
    main.secondLevelButton:removeSelf()
    main.thirdLevelButton:removeSelf()
    main.textFirst:removeSelf()
    main.textSecond:removeSelf()
    main.textThird:removeSelf()
    main.textPoint:removeSelf()
    audio.stop()
end

function main.start()
    main.isDisplay = 
    audio.stop()
    local backgroundMusic = audio.loadStream("sounds/menu_theme.mp3")
    audio.play(backgroundMusic, { loops = -1 })

    main.currentPoint = 0
    main.finishPoint = 3

    main.background = display.newImageRect("/images/first_menu/background.jpg", display.contentWidth, display.contentHeight)
    main.background.x = display.contentCenterX
    main.background.y = display.contentCenterY
    main.background:toBack()

    main.currentLevel = 0

    main.firstLevelButton = display.newCircle(display.contentCenterX, display.contentHeight * 0.2, 250) 
    main.firstLevelButton:setFillColor(0,0,0)
    main.textFirst = display.newText({
        text = "1",
        x = display.contentCenterX, 
        y = display.contentHeight * 0.2, 
        fontSize = 100
    })
    main.firstLevelButton:addEventListener("touch", function (event)
        if event.phase == "began" and firstLevel.isPlay == false then
            main.clear()
            firstLevel.start()
        end
    end)

    main.secondLevelButton = display.newCircle(display.contentCenterX, display.contentHeight * 0.5,250)
    main.secondLevelButton:setFillColor(0,0,0)
    main.textSecond = display.newText({
        text = "2",
        x = display.contentCenterX, 
        y = display.contentHeight * 0.5, 
        fontSize = 100
    })
    main.secondLevelButton:addEventListener("touch", function (event)
        if event.phase == "began"and secondLevel.isPlay == false then
            main.clear()
            secondLevel.start()
        end
    end)

    main.thirdLevelButton = display.newCircle(display.contentCenterX, display.contentHeight * 0.8,250)
    main.thirdLevelButton:setFillColor(0,0,0)
    main.textThird = display.newText({
        text = "3",
        x = display.contentCenterX, 
        y = display.contentHeight * 0.8, 
        fontSize = 100
    })
    main.thirdLevelButton:addEventListener("touch", function (event)
        if event.phase == "began" and thirdLevel.isPlay == false then
            main.clear()
            thirdLevel.start()
        end
    end)


    main.textPoint = display.newText({
        text = "Пройдено " .. main.currentPoint .. " из " .. main.finishPoint,
        x = display.contentCenterX, 
        y = display.contentHeight * 0.96,
        fontSize = 80
    })

    function main.updateStatus()
        if main.currentLevel ~= 0 then
            if main.currentLevel == first and first.status == "Complete" then
                main.firstStatus = true
            end

            if main.currentLevel == second and second.status == "Complete" then
                main.firstStatus = true
            end

            if main.currentLevel == third and third.status == "Complete" then
                main.firstStatus = true
            end
        end 
    end

    function main.updateText()
        main.currentPoint = 0
        if firstLevel.status == true then
            main.currentPoint = main.currentPoint + 1
        end

        if secondLevel.status == true then
            main.currentPoint = main.currentPoint + 1
        end

        if thirdLevel.status == true then
            main.currentPoint = main.currentPoint + 1
        end
        main.textPoint.text = "Пройдено " .. main.currentPoint .. " из " .. main.finishPoint
    end
    main.updateText()
end



















return main