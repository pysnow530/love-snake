(global NODE-LENGTH 30)
(global CORNER-LENGTH (* NODE-LENGTH 0.3))
(global SPEED-GAP-MAX 0.50)
(global SPEED-GAP-MID 0.22) ;; bellow this speed, zip audio clip
(global SPEED-GAP-MIN 0.20)
(global FULL-SPEED-LENGTH 20) ;; after exceed length, come to the SPEED-GAP-MAX

;; ui
(global margin-left 1)
(global margin-top 1)
(global margin-right 1)
(global margin-bottom 1)
(global play-width 20)
(global play-height 20)
(global board-width 10)
(global board-height 20)

(fn sum [...] (accumulate [total 0 _ v (ipairs [...])] (+ total v)))
(fn $ [...] (* NODE-LENGTH (sum ...)))

(global WIN-WIDTH ($ margin-left play-width 1 board-width 1))
(global WIN-HEIGHT ($ margin-top play-height margin-bottom))

(fn clamp [x min max]
    (if
      (< x min) min
      (> x max) max
      true x))

;; speed function
;; y = -(SPEED-GAP-MAX - SPEED-GAP-MIN) / FULL-SPEED-LENGTH * x + SPEED-GAP-MAX -> clamp [SPEED-GAP-MIN SPEED-GAP-MAX]
(fn speed [len]
    (let [y (- SPEED-GAP-MAX (/ (* (- SPEED-GAP-MAX SPEED-GAP-MIN) len) FULL-SPEED-LENGTH))]
      (clamp y SPEED-GAP-MIN SPEED-GAP-MAX)))

;; global state
(global STATE :Welcome)
(var elapsed 0)

;; audio
(global move-sound nil)
(global move2-sound nil)
(global eat-sound nil)
(global gg-sound nil)

;; imgs
(global bg-img nil)
(global playground-img nil)
(global playground-frame {:left 45 :right 35 :top 45 :bottom 40})
(global board-img nil)
(global board-frame {:left 55 :right 60 :top 30 :bottom 58})

(global move-count 0)

(global DIRS {:up [0 -1] :right [1 0] :down [0 1] :left [-1 0]})
(local COLORS {:white [1 1 1 1] :gray [0.5 0.5 0.5 1] :black [0.2 0.2 0.2 1] :red [0.8 0.2 0.2 1]})
(local SIZES {:title 18 :subtitle 16 :text 14})

(fn lst= [lst1 lst2]
    (and (= (length lst1) (length lst2))
         (= (length lst1) (length (icollect [k v (ipairs lst1)]
                                            (if (= (. lst2 k) v)
                                              true))))))

(fn in [x lst]
    (let [eq (if (= (type x) :table)
               lst=
               (fn [x y] (= x y)))]
      (> (length (icollect [_ v (ipairs lst)]
                           (if (eq x v)
                             1)))
         0)))

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
      (set self.speed (speed (length self.body)))
      (love.audio.play sound)))

(fn Snake.move [self sound]
    ;; apply new dir
    (set self.dir self.new-dir)
    (let [{:body [[head-x head-y]] :dir [dir-x dir-y]} self
          new-x (+ head-x dir-x)
          new-y (+ head-y dir-y)]
      (table.insert self.body 1 [new-x new-y])
      (table.remove self.body)
      (when (not= nil sound) (love.audio.play sound))))

(fn Snake.turn-left [self]
    (let [[x y] self.dir]
      (set self.new-dir [y (- x)])))

(fn Snake.turn-right [self]
    (let [[x y] self.dir]
      (set self.new-dir [(- y) x])))

(fn draw-unit [x y]
    "Draw box in playground."
    (love.graphics.rectangle
      :fill
      (+ (* x NODE-LENGTH) ($ margin-left))
      (+ (* y NODE-LENGTH) ($ margin-top))
      NODE-LENGTH
      NODE-LENGTH
      CORNER-LENGTH
      CORNER-LENGTH))

(fn Snake.draw [self]
    (each [_ [x y] (ipairs self.body)]
          (draw-unit x y)))
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

(local snake (Snake:new [1 0] [[0 (/ play-height 2)]] SPEED-GAP-MAX))
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
    (love.window.setMode WIN-WIDTH WIN-HEIGHT)

    ;; init audio
    (set move-sound (love.audio.newSource "audio/move.wav" :static))
    (set move2-sound (love.audio.newSource "audio/move2.wav" :static))
    (set eat-sound (love.audio.newSource "audio/eat.wav" :static))
    (set gg-sound (love.audio.newSource "audio/gg.wav" :static))

    ;; imgs
    (set bg-img (love.graphics.newImage "imgs/bg.jpg"))
    (set playground-img (love.graphics.newImage "imgs/playground.png"))
    (set board-img (love.graphics.newImage "imgs/board.png")))

(fn love.keypressed [key _ _]
    (let [{: up : right : down : left} DIRS
          {: dir} snake]
      (case STATE
        :Welcome (if (= key :space) (set STATE :Playing) (set elapsed 0))
        :Playing (case key
                   :j (snake:turn-left)
                   :k (snake:turn-right)
                   :up (if (in dir [left up right]) (set snake.new-dir up))
                   :right (if (in dir [up right down]) (set snake.new-dir right))
                   :down (if (in dir [right down left]) (set snake.new-dir down))
                   :left (if (in dir [down left up]) (set snake.new-dir left))))))

(macro inc [x] `(set ,x (+ ,x 1)))

(fn love.update [dt]
    (when (= STATE :Playing)
      (set elapsed (+ elapsed dt))
      (if (= 0 (length apples)) (table.insert apples (Apple:new snake.body)))
      (set total-dt (+ total-dt dt))
      (if (> total-dt snake.speed)
        (do
          (set total-dt (- total-dt snake.speed))
          (let [{:body [[head-x head-y]]
                 :new-dir [new-dir-x new-dir-y]
                 : speed} snake
                new-x (+ head-x new-dir-x)
                new-y (+ head-y new-dir-y)
                next-pos-type (predicate-type [new-x new-y])]
            (case next-pos-type
              :wall (do (love.audio.play gg-sound) (set STATE :GameOver))
              :body (do (love.audio.play gg-sound) (set STATE :GameOver))
              :apple (do (inc move-count) (snake:eat eat-sound) (table.remove apples))
              nil (do (inc move-count) (snake:move (if (= 0 (% move-count 4))
                                                     move2-sound
                                                     (if (> speed SPEED-GAP-MID) move-sound nil))))))))))

(macro half [x] `(* ,x 0.5))

(fn print-text [str x y h-mode v-mode size [r g b a]]
    "h-mode: :left or :center, v-mode: :top or :middle"
    (let [font (love.graphics.newFont size)
          width (font:getWidth str)
          height (font:getHeight str)
          new-x (if
                  (= h-mode :left) x
                  (= h-mode :center) (- x (half width)))
          new-y (if
                  (= v-mode :top) y
                  (= v-mode :middle) (- y (half height)))
          old-color (love.graphics.getColor)]
      (love.graphics.setColor r g b a)
      (love.graphics.setFont font)
      (love.graphics.print str new-x new-y)))

(fn show-welcome []
    (let [line-space 0.4]
      (print-text "Welcome to snake, powered by love2d!"
                  (half WIN-WIDTH)
                  (- (half WIN-HEIGHT) (half SIZES.title) (* SIZES.title line-space 0.5))
                  :center :middle SIZES.title COLORS.red)
      (print-text "Press [SPACE] to start game"
                  (half WIN-WIDTH) (+ (half WIN-HEIGHT) (half SIZES.subtitle) (* SIZES.subtitle line-space 0.5))
                  :center :middle SIZES.subtitle COLORS.red)))

(fn show-game-over []
    (print-text "Game Over!" (half WIN-WIDTH) (half WIN-HEIGHT)
                :center :middle 18 COLORS.red))

(fn draw-playground-frame [img frame margin-left margin-top play-width play-height]
    "Draw playground image."
    (let [img-width (img:getWidth)
          img-height (img:getHeight)
          scale-x (/ ($ play-width) (- img-width frame.left frame.right))
          scale-y (/ ($ play-height) (- img-height frame.top frame.bottom))
          origin-x ($ margin-left)
          origin-y ($ margin-top)
          new-x (- origin-x (* frame.left scale-x))
          new-y (- origin-y (* frame.top scale-x))]
      (love.graphics.setColor COLORS.white)
      (love.graphics.draw img new-x new-y 0 scale-x scale-y)))

(fn draw-grid []
    (draw-playground-frame playground-img playground-frame
                           margin-left margin-top play-width play-height)
    (love.graphics.setColor 0.4 0.4 0.4)
    (for [x 1 (- play-width 1)]
         (for [y 1 (- play-height 1)]
              (love.graphics.points ($ x margin-left) ($ y margin-top)))))

(fn draw-apples []
    (love.graphics.setColor 0.8 0.2 0.2)
    (each [_ {:pos [x y]} (ipairs apples)]
          (draw-unit x y)))

(fn draw-snake []
    (love.graphics.setColor 0.2 0.8 0.2)
    (snake:draw))

(fn draw-board []
    (draw-playground-frame board-img board-frame
                           (+ margin-left play-width 1) margin-top board-width  board-height)
    (print-text (.. "Time elipsed: " (string.format "%.0f" elapsed))
                ($ margin-left play-width 1 1)
                ($ margin-top 1)
                :left :top
                SIZES.text COLORS.black)
    (print-text (.. "Score: " (* (length snake.body) 10))
                ($ margin-left play-width 1 1)
                (+ ($ margin-top 1) (* SIZES.text 1.4))
                :left :top
                SIZES.text COLORS.black))

(fn draw-background []
    "Draw background, by extremely use the bg image."
    (let [bg-width (bg-img:getWidth)
          bg-height (bg-img:getHeight)
          scale-x (/ WIN-WIDTH bg-width)
          scale-y (/ WIN-HEIGHT bg-height)]
      (love.graphics.setColor COLORS.white)
      (love.graphics.draw bg-img 0 0 0 scale-x scale-y)))

(fn love.draw []
    (draw-background)
    (print-text (.. "fps: " (love.timer.getFPS)) 0 0 :left :top 14 COLORS.black)
    (case STATE
      :Welcome (show-welcome)
      :Playing (do
                 (draw-grid)
                 (draw-apples)
                 (draw-snake)
                 (draw-board))
      :GameOver (show-game-over)))
