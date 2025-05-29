local graphics = require("graphics")
local physics = require("physics")

local level = {}

function level.stop(event)
    if event.phase == "began" then
        timer.cancel(level.pointTimer)
        timer.cancel(level.fixCharacterTimer)
        timer.cancel(level.scrollGroundTimer)
        timer.cancel(level.moveObstaclesTimer)
        timer.cancel(level.fixAnimationTimer)
        level.pauseContinueButton:removeSelf()
        level.pauseFrame:removeSelf()
        level.textPause:removeSelf()
        level.homeButton:removeSelf()
        level.reloadButton:removeSelf()
        level.background:removeSelf()
        level.character:removeSelf()
        level.animation.spriteRun:removeSelf()
        level.jumpButton:removeSelf()
        if level.obstacles then
            for i = #level.obstacles, 1, -1 do
                local obs = level.obstacles[i]
                obs:removeSelf()
            end
        end
        level.firstPath:removeSelf()
        level.secondPath:removeSelf()
        level.textPoint:removeSelf()
    end
end

function level.reload(event)
    level.stop(event)
    level.start()
end

function level.start()
    level.isPause = false

    level.pauseContinueButton = display.newImageRect("/images/shared/pause_button.png", 200, 200)
    level.pauseContinueButton.x = display.contentWidth - 100
    level.pauseContinueButton.y = 200
    level. cntSpawn = 1
    function level.pauseOrContinue(event)
        if event.phase == "began" then
            if level.isPause == false then
                level.isPause = true

                physics.setGravity(0, 0)

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

                physics.setGravity(0, level.scalePhysics) 

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

            end
        end
    end
    level.pauseContinueButton:addEventListener("touch", level.pauseOrContinue)

    level.character = {}

    level.animation = {}

    level.animation.sheetOptionsRun = 
        { 
            width = 69,
            height = 44,
            numFrames = 8
        } 
    level.animation.imageSheetRun = graphics.newImageSheet("/images/first_level/chainsaw_run.png", level.animation.sheetOptionsRun) 
    level.animation.sequenceDataRun = 
        { 
            name = "run", 
            start = 1, 
            count = 8, 
            time = 600, 
            loopCount = 0,
            loopDirection = "forward" 
        }

    physics.start()
    level.animation.spriteRun = display.newSprite(level.animation.imageSheetRun, level.animation.sequenceDataRun)
    level.animation.scaleCharacter = 5 
    level.animation.spriteRun.x = display.contentCenterX
    level.animation.spriteRun.y = 0
    
    level.animation.spriteRun:scale(level.animation.scaleCharacter, level.animation.scaleCharacter)
    level.animation.spriteRun:play(1, 0, 2)

    level.characterPlace = display.contentWidth * 0.2
    level.character = display.newRect(level.characterPlace, 0, level.animation.sheetOptionsRun.height *  (level.animation.scaleCharacter - 2),level.animation.sheetOptionsRun.width *  (level.animation.scaleCharacter - 2))
    level.character:setFillColor(1, 43, 57, 0.5)
    level.fixAnimationTimer = timer.performWithDelay(1,function(self, event)
        offset = display.contentWidth * 0.04
        level.animation.spriteRun.x = level.character.x + offset
        level.animation.spriteRun.y = level.character.y 
    end, 0)
    function level.fixCharacterX()
        level.character.x = level.characterPlace
    end
    physics.addBody(level.character, "dynamic", { bounce = 0, fixedRotation = true })
    level.fixCharacterTimer = timer.performWithDelay(1, level.fixCharacterX, 0)

    level.scalePhysics = 100
    level.forceJump = -15
    physics.setGravity(0, level.scalePhysics) 
    level.isOnGround = false
    function level.onCollisionWithCharacter(event)
        if event.phase == "began" and level.isPause == false then
            if event.other.ID == "path" then
                level.isOnGround = true
                level.animation.spriteRun:play(1, 0, 2)
            end
        end
    end
    
    level.jumpButton = display.newImageRect("/images/shared/chainsaw_button.png", 100, 300)
    level.jumpButton.x = display.contentCenterX
    level.jumpButton.y = display.contentHeight * 0.9
    function level.onTouchJumpButton(event)
        if event.phase == "began" and level.isPause == false then
            if level.isOnGround == true then
                level.isOnGround = false
                level.character:applyLinearImpulse(0, level.forceJump, level.character.x, level.character.y)
                level.animation.spriteRun:setFrame(2)
                level.animation.spriteRun:pause()
            end
        end
    end

    level.character:addEventListener("collision", level.onCollisionWithCharacter)
    level.jumpButton:addEventListener("touch", level.onTouchJumpButton)

    level.firstPath = display.newImageRect("/images/first_level/path.png", display.contentWidth, 80)
    level.firstPath.ID = "path"
    level.firstPath.x = display.contentWidth * 0.5
    level.firstPath.y = display.contentCenterY
    physics.addBody(level.firstPath, "static", {bounce = 0})

    level.secondPath = display.newImageRect("/images/first_level/path.png", display.contentWidth, 80)
    level.secondPath.ID = "path"
    level.secondPath.x = display.contentWidth * 1.5
    level.secondPath.y = display.contentCenterY
    physics.addBody(level.secondPath, "static", {bounce = 0})

    level.scrollSpeed = 10

    function level.scrollGround(event)
        if level.isPause == false then
            local dx = -level.scrollSpeed 

            level.firstPath.x = level.firstPath.x + dx
            level.secondPath.x = level.secondPath.x + dx

            if level.firstPath.x < -display.contentWidth / 2 then
                level.firstPath.x = level.secondPath.x + display.contentWidth
            end
            if level.secondPath.x < -display.contentWidth / 2 then
                level.secondPath.x = level.firstPath.x + display.contentWidth
            end
        end
    end
    level.scrollGroundTimer = timer.performWithDelay(1, level.scrollGround, 0)

    level.background = display.newImageRect("/images/first_level/background.jpg", display.contentWidth, display.contentHeight)
    level.background.x = display.contentCenterX
    level.background.y = display.contentCenterY
    level.background:toBack()

    level.obstacles = {}

    function level.createObstacle()
        if level.isPause == false  then
            if #level.obstacles < 2 then
                local obstacle = display.newImageRect("/images/first_level/obstacle.png", 100, 330)
                obstacle.x = display.contentWidth
                obstacle.y = display.contentCenterY - 120
                table.insert(level.obstacles, obstacle)
                physics.addBody(obstacle, "static")
                timer.performWithDelay( math.random(1200, 1700), level.createObstacle)
            end
        end
    end

    timer.performWithDelay( math.random(1200, 1700), level.createObstacle)
    function level.moveObstacles()
        if level.isPause == false then
            for i = #level.obstacles, 1, -1 do
                local obs = level.obstacles[i]
                obs.x = obs.x - 10
                if obs.x < -50 then
                    display.remove(obs)
                    table.remove(level.obstacles, i)
                end
            end
        end
    end
    level.moveObstaclesTimer = timer.performWithDelay(1, level.moveObstacles, 0)

    level.currentPoint = 0

    level.finishPoint = 10

    level.textPoint = display.newText({
        text = "Пройдено  " .. level.currentPoint .. "/" .. level.finishPoint .. " м",
        x = 310, 
        y = 200, 
        fontSize = 60
    })
    function level.updateText()
        if level.isPause == false then
            level.currentPoint = level.currentPoint + 1
            level.textPoint.text = "Пройдено  " .. level.currentPoint .. "/" .. level.finishPoint .. " м"
            if level.currentPoint == level.finishPoint then
                timer.cancel(level.pointTimer)
            end
        end
    end
    level.pointTimer = timer.performWithDelay(1000, level.updateText, 0)
end


return level