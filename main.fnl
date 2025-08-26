(global NODE-LENGTH 15)
(global WIDTH 20)
(global HEIGHT 10)

(global STATE :Welcome)

;; audio
(global move-sound nil)
(global eat-sound nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;; snake ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(local Snake {})

(fn Snake.new [cls dir body speed]
    (local obj (setmetatable
                 {: dir : body : speed :new-dir dir}
                 {:__index cls}))
    obj)

(fn Snake.eat [self sound]
    (set self.dir self.new-dir)
    (let [{:body [[head-x head-y]] :dir [dir-x dir-y]} self
          new-x (+ head-x dir-x)
          new-y (+ head-y dir-y)]
      (table.insert self.body 1 [new-x new-y])
      (love.audio.play sound)))

(fn Snake.move [self sound]
    ;; apply new dir
    (set self.dir self.new-dir)
    (let [{:body [[head-x head-y]] :dir [dir-x dir-y]} self
          new-x (+ head-x dir-x)
          new-y (+ head-y dir-y)]
      (table.insert self.body 1 [new-x new-y])
      (table.remove self.body)
      (love.audio.play sound)))

(fn Snake.turn-left [self]
    (let [[x y] self.dir]
      (set self.new-dir [y (- x)])))

(fn Snake.turn-right [self]
    (let [[x y] self.dir]
      (set self.new-dir [(- y) x])))

(fn draw-box [x y]
    (love.graphics.rectangle
      :fill
      (* x NODE-LENGTH) 
      (* y NODE-LENGTH)
      NODE-LENGTH
      NODE-LENGTH
      (* NODE-LENGTH 0.3)
      (* NODE-LENGTH 0.3)))

(fn Snake.draw [self]
    (each [_ [x y] (ipairs self.body)]
          (draw-box x y)))
;;;;;;;;;;;;;;;;;;;;;;;;;;; /snake ;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;; apple ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(local Apple {})

(fn Apple.new [cls snake-body]
    (var x (math.random 0 (- WIDTH 1)))
    (var y (math.random 0 (- HEIGHT 1)))
    (while (>
            (length (icollect [_ [ix iy] (ipairs snake-body)]
                              (if (and (= ix x) (= iy y))
                                1)))
            0)
           (set x (math.random 0 (- WIDTH 1)))
           (set y (math.random 0 (- HEIGHT 1))))
    (setmetatable {:pos [x y]} {:__index cls}))
;;;;;;;;;;;;;;;;;;;;;;;;;;; /apple ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local snake (Snake:new [1 0] [[0 (/ HEIGHT 2)]] 0.5))
(local apples [])

(fn all-but-last [x]
    (icollect [idx item (ipairs x)]
              (if (< idx (length x))
                item)))

(fn predicate-type [[x y]]
    (let [[{:pos [apple-x apple-y]}] apples
          body (all-but-last snake.body)]
      (if (or (< x 0)
              (>= x WIDTH)
              (< y 0)
              (>= y HEIGHT)) :wall
        (> (length (icollect [_ [ix iy] (ipairs body)] (if (and (= ix x) (= iy y)) 1))) 0) :body
        (and (= x apple-x) (= y apple-y)) :apple
        :else nil)))

(var total-dt 0)

(fn love.load []
    ;; init font
    (let [font (love.graphics.newFont 32)]
      (love.graphics.setFont font))
    ;; init audio
    (set move-sound (love.audio.newSource "audio/move.wav" :static))
    (set eat-sound (love.audio.newSource "audio/eat.wav" :static)))

(fn love.keypressed [key _ _]
    (case STATE
      :Welcome (if (= key :j) (set STATE :Playing))
      :Playing (case key
                 :j (snake:turn-left)
                 :k (snake:turn-right))))

(fn print2 [x]
    (print (.. "["
               (table.concat (icollect [_ [ix iy] (ipairs x)]
                                       (.. "[" ix " " iy "]"))
                             " ")
               "]")))

(fn love.update [dt]
    (when (= STATE :Playing)
      (if (= 0 (length apples)) (table.insert apples (Apple:new snake.body)))
      (set total-dt (+ total-dt dt))
      (if (> total-dt snake.speed)
        (do
          (set total-dt (- total-dt snake.speed))
          (let [{:body [[head-x head-y]]
                 :dir [dir-x dir-y]
                 :new-dir [new-dir-x new-dir-y]} snake
                new-x (+ head-x new-dir-x )
                new-y (+ head-y new-dir-y)
                next-pos-type (predicate-type [new-x new-y])]
            (case next-pos-type
              :wall (set STATE :GameOver)
              :body (set STATE :GameOver)
              :apple (do (snake:eat eat-sound) (table.remove apples))
              nil (snake:move move-sound)))))))

(fn show-welcome []
    (love.graphics.print "Welcome to snake, powered by love2d!" 100 100)
    (love.graphics.print "Press j to start game :-p" 100 200))

(fn show-game-over []
    (let [text "Game Over!"
          font (love.graphics.getFont)
          fontWidth (font:getWidth text)
          fontHeight (font:getHeight)
          (winWidth winHeight) (love.graphics.getDimensions)]
      (love.graphics.print "Game Over!"
                           (- (/ winWidth 2) (/ fontWidth 2))
                           (- (/ winHeight 2) (/ fontHeight 2)))))

(fn draw-apples []
    (love.graphics.setColor 0.8 0.2 0.2)
    (each [_ {:pos [x y]} (ipairs apples)]
          (draw-box x y)))

(fn draw-snake []
    (love.graphics.setColor 0.2 0.8 0.2)
    (snake:draw))

(fn love.draw []
    (case STATE
      :Welcome (show-welcome)
      :Playing (do
                 (draw-apples)
                 (draw-snake))
      :GameOver (show-game-over)))
