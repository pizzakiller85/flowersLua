function love.load()
    -- Initialize flowers array
    flowers = {}
    local numFlowers = 40
    print(love.graphics.getWidth()) 
    for i = 1, numFlowers do
        local flower = {
            x = love.math.random(5, love.graphics.getWidth() - 5),
            y = love.graphics.getHeight() / 2,
            size = love.math.random(25, 50),
            petals = love.math.random(6, 10),
            stemLength = love.math.random(200, 350),
            stemWidth = love.math.random(2, 5),
            windOffset = love.math.random() * math.pi * 2, -- Random starting phase
            windSpeed = love.math.random(1.0, 2.0),
            windStrength = love.math.random(15, 35),
            petalColor = {
                love.math.random(0.8, 1.0), 
                love.math.random(0.6, 0.9), 
                love.math.random(0.7, 1.0), 
                1
            },
            centerColor = {
                love.math.random(0.9, 1.0), 
                love.math.random(0.9, 1.0), 
                love.math.random(0.2, 0.4), 
                1
            },
            stemColor = {
                love.math.random(0.1, 0.3), 
                love.math.random(0.7, 0.9), 
                love.math.random(0.1, 0.3), 
                1
            },
            leafColor = {
                love.math.random(0.2, 0.4), 
                love.math.random(0.8, 1.0), 
                love.math.random(0.2, 0.4), 
                1
            }
        }
        table.insert(flowers, flower)
    end
    
    -- Background gradient colors
    bgColors = {
        top = {0.7, 0.9, 1, 1}, -- Light blue sky
        bottom = {0.9, 1, 0.9, 1} -- Light green ground
    }
    
    -- Particle system for floating petals
    particles = love.graphics.newParticleSystem(love.graphics.newCanvas(4, 4))
    particles:setParticleLifetime(3, 6)
    particles:setLinearAcceleration(-20, -10, 20, -5)
    particles:setColors(1, 0.8, 0.9, 1, 1, 0.8, 0.9, 0)
    particles:setEmissionRate(2)
    particles:setSizeVariation(0.5)
    particles:setLinearDamping(0.5)
    
    -- Create particle texture
    local particleCanvas = love.graphics.newCanvas(8, 8)
    love.graphics.setCanvas(particleCanvas)
    love.graphics.setColor(1, 0.8, 0.9, 1)
    love.graphics.circle("fill", 4, 4, 3)
    love.graphics.setCanvas()
    particles:setTexture(particleCanvas)
    
    -- Initialize bees
    bees = {}
    local numBees = 20
    
    for i = 1, numBees do
        local bee = {
            x = love.math.random(50, love.graphics.getWidth() - 50),
            y = love.math.random(100, love.graphics.getHeight() - 200),
            targetX = 0,
            targetY = 0,
            speed = love.math.random(150, 250),
            size = love.math.random(8, 12),
            wingOffset = love.math.random() * math.pi * 2,
            wingSpeed = love.math.random(15, 25),
            currentFlower = nil,
            visitTime = 0,
            maxVisitTime = love.math.random(2, 4),
            color = {1, 0.8, 0, 1}, -- Yellow
            wingColor = {0.9, 0.7, 0, 1} -- Darker yellow
        }
        table.insert(bees, bee)
    end
    
    -- Set initial targets for all bees after all bees are created
    for i, bee in ipairs(bees) do
        findNewTarget(bee)
    end
    

    

end

function love.update(dt)
    -- Update wind animation for all flowers
    for i, flower in ipairs(flowers) do
        flower.windOffset = flower.windOffset + flower.windSpeed * dt
    end
    

    
    -- Update particles
    particles:update(dt)
    
    -- Emit particles from random flowers
    if love.math.random() < 0.3 then -- 30% chance each frame
        local randomFlower = flowers[love.math.random(1, #flowers)]
        local bottomX = randomFlower.x
        local bottomY = love.graphics.getHeight() - 50
        local windAngle = math.sin(randomFlower.windOffset) * 0.3
        local topX = bottomX + math.sin(windAngle) * randomFlower.stemLength * 0.3
        local topY = bottomY - randomFlower.stemLength
        
        particles:setPosition(topX, topY)
        particles:setLinearAcceleration(-20, -10, 20, -5)
    end
    
    -- Update bees
    for i, bee in ipairs(bees) do
        updateBee(bee, dt)
    end
end

function love.draw()
    -- Draw background gradient
    drawGradientBackground()
    
    -- Draw all flower stems
    for i, flower in ipairs(flowers) do
        drawStem(flower)
    end
    
    -- Draw all flowers
    for i, flower in ipairs(flowers) do
        drawFlower(flower)
    end
    
    -- Draw particles
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(particles)
    
    -- Draw bees
    for i, bee in ipairs(bees) do
        drawBee(bee)
    end
end

function drawGradientBackground()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    for i = 0, height do
        local ratio = i / height
        local r = bgColors.top[1] * (1 - ratio) + bgColors.bottom[1] * ratio
        local g = bgColors.top[2] * (1 - ratio) + bgColors.bottom[2] * ratio
        local b = bgColors.top[3] * (1 - ratio) + bgColors.bottom[3] * ratio
        local a = bgColors.top[4] * (1 - ratio) + bgColors.bottom[4] * ratio
        
        love.graphics.setColor(r, g, b, a)
        love.graphics.line(0, i, width, i)
    end
end

function drawStem(flower)
    love.graphics.setColor(unpack(flower.stemColor))
    love.graphics.setLineWidth(flower.stemWidth)
    
    -- Fixed bottom position
    local bottomX = flower.x
    local bottomY = love.graphics.getHeight() - 50
    
    -- Top position with wind swing
    local windAngle = math.sin(flower.windOffset) * 0.3 -- Swing angle
    local topX = bottomX + math.sin(windAngle) * flower.stemLength * 0.3
    local topY = bottomY - flower.stemLength
    
    -- Create smooth curved stem path
    local segments = 20
    local points = {}
    for i = 0, segments do
        local t = i / segments
        -- Create a natural curve that's fixed at bottom and swings at top
        local curveX = bottomX + (topX - bottomX) * t + math.sin(t * math.pi) * 10
        local curveY = bottomY - flower.stemLength * t
        table.insert(points, curveX)
        table.insert(points, curveY)
    end
    
    love.graphics.line(points)
    
    -- Draw leaves along the stem
    drawLeaves(flower, bottomX, bottomY, topX, topY)
end

function drawLeaves(flower, bottomX, bottomY, topX, topY)
    love.graphics.setColor(unpack(flower.leafColor))
    
    -- Calculate stem direction for leaf positioning
    local stemAngle = math.atan2(topY - bottomY, topX - bottomX)
    
    -- Draw leaves at different positions along the stem
    local leafPositions = {0.3, 0.6, 0.8} -- Positions along stem (0 = bottom, 1 = top)
    
    for i, pos in ipairs(leafPositions) do
        local leafX = bottomX + (topX - bottomX) * pos
        local leafY = bottomY - flower.stemLength * pos
        
        -- Alternate leaf sides
        local side = (i % 2 == 0) and 1 or -1
        local leafOffset = 15 * side
        
        -- Position leaf perpendicular to stem
        local leafAngle = stemAngle + (math.pi/2 * side) + math.sin(flower.windOffset * 0.5 + i) * 0.2
        local finalX = leafX + math.cos(leafAngle) * leafOffset
        local finalY = leafY + math.sin(leafAngle) * leafOffset
        
        drawLeaf(finalX, finalY, leafAngle, side, flower.leafColor)
    end
end

function drawLeaf(x, y, angle, direction, leafColor)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    
    -- Draw leaf shape
    local leafLength = 25
    local leafWidth = 8
    
    love.graphics.setColor(unpack(leafColor))
    love.graphics.ellipse("fill", 0, 0, leafWidth, leafLength)
    
    -- Leaf vein
    love.graphics.setColor(0.1, 0.6, 0.1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(0, -leafLength, 0, leafLength)
    
    love.graphics.pop()
end

function drawFlower(flower)
    -- Position flower at the top of the swinging stem
    local bottomX = flower.x
    local bottomY = love.graphics.getHeight() - 50
    local windAngle = math.sin(flower.windOffset) * 0.3
    local topX = bottomX + math.sin(windAngle) * flower.stemLength * 0.3
    local topY = bottomY - flower.stemLength
    
    love.graphics.push()
    love.graphics.translate(topX, topY)
    
    -- Draw petals
    love.graphics.setColor(unpack(flower.petalColor))
    for i = 1, flower.petals do
        local angle = (i - 1) * (2 * math.pi / flower.petals)
        local petalLength = flower.size * 1.5
        local petalWidth = flower.size * 0.6
        
        -- Add individual petal wind effects
        local petalWindOffset = flower.windOffset + (i * 0.5)  -- Each petal has different timing
        local petalWindAngle = math.sin(petalWindOffset) * 0.2  -- Petal swing angle
        local petalWindBend = math.sin(petalWindOffset * 0.7) * 0.1  -- Petal bend effect
        
        love.graphics.push()
        love.graphics.rotate(angle + petalWindAngle)  -- Add wind swing to petal angle
        
        -- Draw petal with wind curve
        local petalPoints = {}
        for j = 0, 10 do
            local t = j / 10
            local curve = math.sin(t * math.pi) * 5
            local windCurve = math.sin(t * math.pi) * petalWindBend * petalLength  -- Wind bend effect
            local x = t * petalLength
            local y = math.sin(t * math.pi) * petalWidth + curve + windCurve
            table.insert(petalPoints, x)
            table.insert(petalPoints, y)
        end
        
        love.graphics.polygon("fill", petalPoints)
        love.graphics.pop()
    end
    
    -- Draw flower center
    love.graphics.setColor(unpack(flower.centerColor))
    love.graphics.circle("fill", 0, 0, flower.size * 0.4)
    
    -- Draw center details
    love.graphics.setColor(1, 0.9, 0.2, 1)
    love.graphics.circle("fill", 0, 0, flower.size * 0.2)
    
    love.graphics.pop()
end

function updateBee(bee, dt)
    -- Update wing animation
    bee.wingOffset = bee.wingOffset + bee.wingSpeed * dt
    
    -- If bee is visiting a flower
    if bee.currentFlower then
        bee.visitTime = bee.visitTime + dt
        
        -- Follow the flower's center as it swings
        local bottomX = bee.currentFlower.x
        local bottomY = love.graphics.getHeight() - 50
        local windAngle = math.sin(bee.currentFlower.windOffset) * 0.3
        local topX = bottomX + math.sin(windAngle) * bee.currentFlower.stemLength * 0.3
        local topY = bottomY - bee.currentFlower.stemLength
        
        -- Smoothly move bee to flower center
        local followSpeed = 5  -- How fast bee moves to center
        local dx = topX - bee.x
        local dy = topY - bee.y
        bee.x = bee.x + dx * followSpeed * dt
        bee.y = bee.y + dy * followSpeed * dt
        
        if bee.visitTime >= bee.maxVisitTime then
            -- Finished visiting, find new target
            bee.currentFlower = nil
            bee.visitTime = 0
            findNewTarget(bee)
        end
    else
        -- Move towards target
        local dx = bee.targetX - bee.x
        local dy = bee.targetY - bee.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance < 10 then
            -- Reached target, start visiting
            bee.currentFlower = bee.targetFlower
            bee.visitTime = 0
            bee.maxVisitTime = love.math.random(2, 4)
        else
            -- Move towards target with wavy pattern
            local baseDirX = dx / distance
            local baseDirY = dy / distance
            
            -- Add more pronounced wavy pattern perpendicular to movement direction
            local waveOffset = math.sin(bee.wingOffset * 3) * 80 * dt  -- Increased amplitude and frequency
            local perpX = -baseDirY  -- Perpendicular vector
            local perpY = baseDirX
            
            -- Combine straight movement with wavy pattern
            local moveDistance = bee.speed * dt
            local moveX = baseDirX * moveDistance + perpX * waveOffset
            local moveY = baseDirY * moveDistance + perpY * waveOffset
            
            bee.x = bee.x + moveX
            bee.y = bee.y + moveY
        end
    end
end

function findNewTarget(bee)
    -- Find a random flower to visit
    local randomFlower = flowers[love.math.random(1, #flowers)]
    local bottomX = randomFlower.x
    local bottomY = love.graphics.getHeight() - 50
    local windAngle = math.sin(randomFlower.windOffset) * 0.3
    local topX = bottomX + math.sin(windAngle) * randomFlower.stemLength * 0.3
    local topY = bottomY - randomFlower.stemLength
    
    bee.targetX = topX + love.math.random(-20, 20)
    bee.targetY = topY + love.math.random(-20, 20)
    bee.targetFlower = randomFlower
    bee.maxVisitTime = love.math.random(2, 4)
end

function drawBee(bee)
    love.graphics.push()
    love.graphics.translate(bee.x, bee.y)
    
    -- Draw bee body
    love.graphics.setColor(unpack(bee.color))
    love.graphics.circle("fill", 0, 0, bee.size)
    
    -- Draw bee stripes
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(-bee.size * 0.8, 0, -bee.size * 0.3, 0)
    love.graphics.line(bee.size * 0.3, 0, bee.size * 0.8, 0)
    
    -- Draw wings
    love.graphics.setColor(unpack(bee.wingColor))
    local wingAngle = math.sin(bee.wingOffset) * 0.3
    local wingSize = bee.size * 0.8
    
    -- Left wing
    love.graphics.push()
    love.graphics.rotate(wingAngle)
    love.graphics.ellipse("fill", -bee.size * 0.5, -bee.size * 0.3, wingSize * 0.5, wingSize)
    love.graphics.pop()
    
    -- Right wing
    love.graphics.push()
    love.graphics.rotate(-wingAngle)
    love.graphics.ellipse("fill", bee.size * 0.5, -bee.size * 0.3, wingSize * 0.5, wingSize)
    love.graphics.pop()
    
    -- Draw antennae
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(-bee.size * 0.3, -bee.size * 0.5, -bee.size * 0.6, -bee.size * 0.8)
    love.graphics.line(bee.size * 0.3, -bee.size * 0.5, bee.size * 0.6, -bee.size * 0.8)
    
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end


