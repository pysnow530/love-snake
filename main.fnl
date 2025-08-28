(global NODE-LENGTH 20)
(global CORNER-LENGTH CORNER-LENGTH)

;; global state
(global STATE :Welcome)

;; audio
(global move-sound nil)
(global eat-sound nil)

;; ui
(global margin-left 1)
(global margin-top 1)
(global margin-right 1)
(global margin-bottom 1)
(global play-width 20)
(global play-height 20)
(global board-width 10)
(global board-height 20)

(fn _ [...] (* NODE-LENGTH
               (accumulate [total 0
                            _ x (ipairs [...])]
                           (+ total x))))

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
      (+ (* x NODE-LENGTH) (_ margin-left))
      (+ (* y NODE-LENGTH) (_ margin-top))
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
    (var x (math.random 0 (- play-width 1)))
    (var y (math.random 0 (- play-height 1)))
    (while (>
            (length (icollect [_ [ix iy] (ipairs snake-body)]
                              (if (and (= ix x) (= iy y))
                                1)))
            0)
           (set x (math.random 0 (- play-width 1)))
           (set y (math.random 0 (- play-height 1))))
    (setmetatable {:pos [x y]} {:__index cls}))
;;;;;;;;;;;;;;;;;;;;;;;;;;; /apple ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local snake (Snake:new [1 0] [[0 (/ play-height 2)]] 0.5))
(local apples [])

(fn all-but-last [x]
    (icollect [idx item (ipairs x)]
              (if (< idx (length x))
                item)))

(fn predicate-type [[x y]]
    (let [[{:pos [apple-x apple-y]}] apples
          body (all-but-last snake.body)]
      (if (or (< x 0)
              (>= x play-width)
              (< y 0)
              (>= y play-height)) :wall
        (> (length (icollect [_ [ix iy] (ipairs body)] (if (and (= ix x) (= iy y)) 1))) 0) :body
        (and (= x apple-x) (= y apple-y)) :apple
        :else nil)))

(var total-dt 0)

(fn love.load []
    ;; window size
    (love.window.setMode (_ margin-left play-width 1 board-width 1)
                         (_ margin-top play-height margin-bottom))
    ;; init font
    (let [font (love.graphics.newFont 16)]
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

(fn love.update [dt]
    (when (= STATE :Playing)
      (if (= 0 (length apples)) (table.insert apples (Apple:new snake.body)))
      (set total-dt (+ total-dt dt))
      (if (> total-dt snake.speed)
        (do
          (set total-dt (- total-dt snake.speed))
          (let [{:body [[head-x head-y]]
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
    (love.graphics.setColor 0.8 0.2 0.2)
    (let [text "Game Over!"
          font (love.graphics.getFont)
          fontWidth (font:getWidth text)
          fontHeight (font:getHeight)
          (winWidth winHeight) (love.graphics.getDimensions)]
      (love.graphics.print text
                           (- (/ winWidth 2) (/ fontWidth 2))
                           (- (/ winHeight 2) (/ fontHeight 2)))))

(fn draw-grid []
    (love.graphics.setColor 0.4 0.4 0.4)
    (love.graphics.rectangle :line
                             (_ margin-left)
                             (_ margin-top)
                             (* play-width NODE-LENGTH)
                             (* play-height NODE-LENGTH)
                             CORNER-LENGTH
                             CORNER-LENGTH)
    (for [x 1 (- play-width 1)]
         (for [y 1 (- play-height 1)]
              (love.graphics.points
                (+ (* x NODE-LENGTH) (_ margin-left))
                (+ (* y NODE-LENGTH) (_ margin-top))))))

(fn draw-apples []
    (love.graphics.setColor 0.8 0.2 0.2)
    (each [_ {:pos [x y]} (ipairs apples)]
          (draw-box x y)))

(fn draw-snake []
    (love.graphics.setColor 0.2 0.8 0.2)
    (snake:draw))

(fn draw-board []
    (love.graphics.setColor 0.4 0.4 0.4)
    (love.graphics.rectangle :line
                             (_ margin-left 1 play-width)
                             (_ margin-top)
                             (_ board-width)
                             (_ board-height)
                             CORNER-LENGTH
                             CORNER-LENGTH))

(fn love.draw []
    (case STATE
      :Welcome (show-welcome)
      :Playing (do
                 (draw-grid)
                 (draw-apples)
                 (draw-snake)
                 (draw-board))
      :GameOver (show-game-over)))
