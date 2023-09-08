WINDOW_HEIGHT=750
WINDOW_WIDTH=1300

math.randomseed(os.time())-- will generate a random number depending on time

-------------------------------------player-----------------------------------------------
player={}
player.width=100
player.height=100
player.x=WINDOW_WIDTH/2
player.y=WINDOW_HEIGHT-player.height
player.speed=600
player.health_barwidth=150
player.health_barheight=20

-------------------------------------enemy-------------------------------------------------
function createenemies()
    local enemy={}
    enemy.width=50
    enemy.height=50
    enemy.y=-enemy.height
    enemy.x=love.math.random(0,WINDOW_WIDTH-enemy.width)-- will take random number from the range provided
    enemy.speed=240
    enemy.health_barwidth=enemy.width
    enemy.health_barheight=7
    return enemy
    
end
-------------------------------------bullet-------------------------------------------------
function createbullets()
    local bullet={}
    bullet.width=10
    bullet.height=25
    bullet.x=player.x+player.width/2-bullet.width/2
    bullet.y=WINDOW_HEIGHT-player.height-bullet.height
    bullet.speed=500
    return bullet
    
end

-------------------------------------collison function---------------------------------------
function Collision(v,k)
    return v.x<k.x+k.width and
           v.x+v.width>k.x and
           v.y<k.y+k.height and
           v.y+v.height>k.y
  end

allbullets={} --to store bullet
allenemies={} --to store enemies

-------------------------------------love load------------------------------------------------
function love.load()
    love.window.setMode(WINDOW_WIDTH,WINDOW_HEIGHT)
    
    timer=0 ---timer for bullets
    timer2=0 ---timer for enemies
    score=0 --score value

    ---game images
    main_menu=love.graphics.newImage("FD_Assets/main_menu.png")
    end_screen=love.graphics.newImage("FD_Assets/end.png")
    score_screen=love.graphics.newImage("FD_Assets/score.png")
    bg=love.graphics.newImage("FD_Assets/bg.png")
    escape_screen=love.graphics.newImage("FD_Assets/end.png")
    canon=love.graphics.newImage("FD_Assets/canon final.png")
    zombie=love.graphics.newImage("FD_Assets/Zombie final.png")
    cannonball=love.graphics.newImage("FD_Assets/cannon ball_1.png")

    ---game sounds
    main_sound=love.audio.newSource("FD_Assets/background_sound.mp3","stream")
    mainmenu_sound=love.audio.newSource("FD_Assets/mainmenu_sound.mp3","stream")
    endsound=love.audio.newSource("FD_Assets/endmusic.mp3","stream")
    killsound=love.audio.newSource("FD_Assets/enemykill.mp3","static")
    cannonshots=love.audio.newSource("FD_Assets/gunshots.mp3","static")

    --Defining states of the game(Main menu,Escape,End)
    state="Main menu"
  
end
-------------------------------------love update----------------------------------------------
function love.update(dt)

    timer=timer+dt   ---here as we need to respown enemies and bullets then we need to increase timer values by dt
    timer2=timer2+dt

    if state=="Main menu" then

        --plays the bg music and stops other music
        mainmenu_sound:play()
        main_sound:stop()
        endsound:stop()

        --to enter the play state
        if love.keyboard.isDown("space") then
            state="Play"
        end    

    -- defining play state 
    elseif state=="Play" then

        --to enter ecsape state
        if love.keyboard.isDown("e") then
            state="Escape"
            
        end

        --plays the bg music
        main_sound:play()
        mainmenu_sound:stop()
        endsound:stop()


        if love.keyboard.isDown("d") and player.x<WINDOW_WIDTH-player.width then --it restricts its movement beyond the screen
            player.x=player.x+player.speed*dt 
        end

        if love.keyboard.isDown("a") and player.x>0 then --it restricts its movement beyond the screen
            player.x=player.x-player.speed*dt   
        end

        -- for bullets
        if timer>=0.1 then
            table.insert(allbullets,createbullets())
            -- cannonshots:play()
            timer=0
        end

        -- for enemy
        if timer2>=1 then
            table.insert(allenemies,createenemies())
            timer2=0
        end

        --for movement of bullets
        for k, v in pairs(allbullets) do
            v.y=v.y-v.speed*dt
            
        end

        --for movement of enemy
        for k, v in pairs(allenemies) do
            v.y=v.y+v.speed*dt
            
        end
        
        -- to delete extra bullets
        for k, v in pairs(allbullets) do
            if v.y<-v.height then
                table.remove(allbullets,k)  
            end
        end

        -- to delete extra enemy
        for k, v in pairs(allenemies) do
            if v.y>WINDOW_HEIGHT then
                table.remove(allenemies,k) 
            end
        end

        --for collison and deletion of enemy and bullets
        for key, value in pairs(allenemies) do
            for k, v in pairs(allbullets) do
                if Collision(value,v) then
                    killsound:play()
                    table.remove(allbullets,k)
                    score=score+1
                    value.health_barwidth=value.health_barwidth-value.width/4
                    if value.health_barwidth==0 then
                        table.remove(allenemies,key)
                        
                    end
                
                end 
            end
            
        --for collison of enemy and player
        for k, v in pairs(allenemies) do
            if Collision(v,player) then
                table.remove(allenemies,k)
                player.health_barwidth=player.health_barwidth-20

            end
            
        end
        
        end

        --to stop the game as health reaches 0
        if player.health_barwidth<=0 then
            state="End" 
        end
    
    --defining end state 
    elseif state=="End" then
        endsound:play()
        main_sound:stop()
        mainmenu_sound:stop()

        if love.keyboard.isDown("space") then
            state="Play"
            player.health_barwidth=150
            score=0
        end

    --defining escape state
    elseif state=="Escape" then

        endsound:stop()
        main_sound:stop()
        mainmenu_sound:stop()

        if love.keyboard.isDown("space") then
            state="Play"
        end

    end

end
-----------------------------------love draw------------------------------------------------------

function love.draw()

    --things to draw in main menu
    if state=="Main menu" then
        love.graphics.draw(main_menu,0,0,0,1.05,1.05)
    
    --things to draw in Play state
    elseif state=="Play" then
        love.graphics.draw(bg,0,0,0,1.5,1)
        -- love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)

        --to draw canon
        love.graphics.draw(canon,player.x+player.width/2-canon:getWidth()/2-10,player.y,0,1.5,1.5)
        -- love.graphics.setColor(0,1,1)
        -- love.graphics.rectangle("line",player.x,player.y,player.width,player.height)

        --new font
        font1=love.graphics.newFont("Akira Expanded Demo.otf",10)
        font2=love.graphics.newFont("Akira Expanded Demo.otf",30)

        --to draw cannon balls
        for k, v in pairs(allbullets) do
            love.graphics.setColor(0,0,0)
            love.graphics.circle("fill",v.x,v.y,8)
        end

        --to draw zombies
        for k, v in pairs(allenemies) do
            love.graphics.setColor(1,1,1)
            love.graphics.draw(zombie,v.x,v.y)
            -- love.graphics.setColor(1,1,1)
            -- love.graphics.rectangle("line",v.x,v.y,v.width,v.height)
        end

        --to make players health
        love.graphics.setFont(font1)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Player's Health",30,30)

        --player health bar
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("fill",30,50,player.health_barwidth,player.health_barheight)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("line",30,50,150,20)

        --enemy health bar
        for k, v in pairs(allenemies) do
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("fill",v.x,v.y-20,v.health_barwidth,v.health_barheight)
            
        end

        --score
        love.graphics.setFont(font2)
        love.graphics.setColor(1,1,1)
        love.graphics.print(score,WINDOW_WIDTH/2,20)

    
    --things to draw in end of game
    elseif state=="End" then
        love.graphics.draw(score_screen,WINDOW_WIDTH/2-score_screen:getWidth()/2,0,0,1.1,1.1)
        -- love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
        love.graphics.print(score,WINDOW_WIDTH/2,570)
        -- love.graphics.print(text,x,y,r,sx,sy,ox,oy)

    --things to draw in escape menu
    elseif state=="Escape" then
        love.graphics.draw(escape_screen,0,0,0,1.1,1.1)
    end
      
end


--Note:

-- to get dimensions of any image imported or any thing
-- use name:getWidth()or getHeight()