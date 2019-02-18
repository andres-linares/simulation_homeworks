breed [ caminos camino ]
breed [ nodos nodo]

globals [
  feromona-A-B
  feromona-A-C1
  feromona-A-C2
  feromona-B-C3
  feromona-B-C4
  costo-A-B
  costo-A-C1
  costo-A-C2
  costo-B-C3
  costo-B-C4

  probabilidad-A-B
  probabilidad-A-C1
  probabilidad-A-C2
  suma-probabilidades-A-X

  probabilidad-B-C3
  probabilidad-B-C4
  suma-probabilidades-B-C

  probabilidad-C-B1
  probabilidad-C-B2
  probabilidad-C-A1
  probabilidad-C-A2
  suma-probabilidades-C-X

  rango-1
  rango-2

  rango-1-2

  rango-1-3
  rango-2-3
  rango-3-3
  rango-4-3

  aleatorio
  aleatorio-2
  aleatorio-3
]

turtles-own [
 nodo-actual ;; Nodo en que se encuentra la hormiga
 sgte-nodo ;; Siguiente nodo
 pasos
 pasos-vuelta
 primer-aleatorio-generado?
 segundo-aleatorio-generado?
 tercer-aleatorio-generado?
 recorrido-A-B?
 recorrido-A-C1?
 recorrido-A-C2?
 recorrido-B-C3?
 recorrido-B-C4?
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  show "Iniciando...-----------"
  import-pcolors "maze.png"
  set-default-shape turtles "bug"

  create-turtles POBLACION
  [ set size 3
    set color red
    set heading 0
    set pasos 0
    set pasos-vuelta 0
    set nodo-actual "A"
    set primer-aleatorio-generado? false
    set segundo-aleatorio-generado? false
    set tercer-aleatorio-generado? false
    set recorrido-A-B? false
    set recorrido-A-C1? false
    set recorrido-A-C2? false
    set recorrido-B-C3? false
    set recorrido-B-C4? false
  ]
  setup-caminos
  setup-turtles

  calcular-probabilidades-A-X
  calcular-probabilidades-B-C
  calcular-probabilidades-C-X
  reset-ticks
end

to setup-caminos
  set feromona-A-B 0.07
  set feromona-A-C1 0.16
  set feromona-A-C2 0.15
  set feromona-B-C3 0.1
  set feromona-B-C4 0.11

  set costo-A-B 60
  set costo-A-C1 480
  set costo-A-C2 490
  set costo-B-C3 170
  set costo-B-C4 360
end

to setup-turtles
  ask turtles
  [ setxy 1 -89]
end


;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;
;;;;;;;;;;;;;;;;;;;;;

to go
  ask turtles
  [ if who >= ticks [ stop ] ;; delay initial departure
    if nodo-actual = "A" [
      escoger-primer-camino
    ]
    if nodo-actual = "B" [
      siguiente-nodo
    ]
    if nodo-actual = "C" [
      escoger-camino-vuelta
    ]
  ]
  tick
end

;;;;;;;;;;;;;;;;
;;; Calculos ;;;
;;;;;;;;;;;;;;;;


to calcular-probabilidades-A-X
  set probabilidad-A-B ( feromona-A-B ^ alpha ) * ( (1 / costo-A-B ) ^ betha )
  set probabilidad-A-C1 ( feromona-A-C1 ^ alpha ) * ( (1 / costo-A-C1) ^ betha )
  set probabilidad-A-C2 ( feromona-A-C2 ^ alpha ) * ( (1 / costo-A-C2) ^ betha )
  set suma-probabilidades-A-X probabilidad-A-B + probabilidad-A-C1 + probabilidad-A-C2

  set probabilidad-A-B probabilidad-A-B / suma-probabilidades-A-X
  set probabilidad-A-C1 probabilidad-A-C1 / suma-probabilidades-A-X
  set probabilidad-A-C2 probabilidad-A-C2 / suma-probabilidades-A-X

  set rango-1 probabilidad-A-B
  set rango-2 rango-1 + probabilidad-A-C1

  show "probabilidades A-X calculadas"
end


to calcular-probabilidades-B-C
  set probabilidad-B-C3 ( feromona-B-C3 ^ alpha ) * ( ( 1 / costo-B-C3 ) ^ betha )
  set probabilidad-B-C4 ( feromona-B-C4 ^ alpha ) * ( ( 1 / costo-B-C4 ) ^ betha )
  set suma-probabilidades-B-C probabilidad-B-C3 + probabilidad-B-C4

  set probabilidad-B-C3 probabilidad-B-C3 / suma-probabilidades-B-C
  set probabilidad-B-C4 probabilidad-B-C4 / suma-probabilidades-B-C

  set rango-1-2 probabilidad-B-C3

  show "probabilidades B-C calculadas"
end

to calcular-probabilidades-C-X
  set probabilidad-C-B2 ( feromona-B-C3 ^ alpha ) * ( ( 1 / costo-B-C3 ) ^ betha )
  set probabilidad-C-B1 ( feromona-B-C4 ^ alpha ) * ( ( 1 / costo-B-C4 ) ^ betha )
  set probabilidad-C-A1 ( feromona-A-C1 ^ alpha ) * ( ( 1 / costo-A-C1 ) ^ betha )
  set probabilidad-C-A2 ( feromona-A-C2 ^ alpha ) * ( ( 1 / costo-A-C2 ) ^ betha )
  set suma-probabilidades-C-X probabilidad-C-B1 + probabilidad-C-B2 + probabilidad-C-A2 + probabilidad-C-A2

  set probabilidad-C-B2 probabilidad-C-B2 / suma-probabilidades-C-X
  set probabilidad-C-B1 probabilidad-C-B1 / suma-probabilidades-C-X
  set probabilidad-C-A1 probabilidad-C-A1 / suma-probabilidades-C-X
  set probabilidad-C-A2 probabilidad-C-A2 / suma-probabilidades-C-X

  set rango-1-3 probabilidad-C-B1
  set rango-2-3 rango-1-3 + probabilidad-C-B2
  set rango-3-3 rango-2-3 + probabilidad-C-A1
  set rango-4-3 rango-3-3 + probabilidad-C-A2

  show "probabilidades C-X calculadas"
end



to escoger-primer-camino
  if primer-aleatorio-generado? = false [
    set aleatorio random-float 1
    set primer-aleatorio-generado? true

    ifelse aleatorio < rango-1 [
      set sgte-nodo "B"
    ][
      ifelse aleatorio < rango-2 [
        set sgte-nodo "C1"
      ][
        set sgte-nodo "C2"
      ]
    ]
  ]

  siguiente-nodo
end


to escoger-segundo-camino
  if segundo-aleatorio-generado? = false [
    set aleatorio-2 random-float 1
    set segundo-aleatorio-generado? true

    ifelse aleatorio-2 < rango-1-2 [
      set sgte-nodo "C3"
    ][
      set sgte-nodo "C4"
    ]
  ]

  siguiente-nodo
end


to escoger-camino-vuelta
  if tercer-aleatorio-generado? = false [
    set aleatorio-3 random-float 1
    set tercer-aleatorio-generado? true

    ifelse aleatorio-3 < rango-1-3 [
      set sgte-nodo "B1"
    ][
      ifelse aleatorio-3 < rango-2-3 [
        set sgte-nodo "B2"
      ][
        ifelse aleatorio-3 < rango-3-3 [
          set sgte-nodo "A1"
        ][
          set sgte-nodo "A2"
        ]
      ]
    ]
  ]

  siguiente-nodo
end

to actualizar-feromonas
  ifelse recorrido-A-B? [
    set feromona-A-B ( 1 - rho ) * feromona-A-B + ( 1 / pasos )
  ][
    set feromona-A-B ( 1 - rho ) * feromona-A-B
  ]

  ifelse recorrido-A-C1? [
    set feromona-A-C1 ( 1 - rho ) * feromona-A-C1 + ( 1 / pasos )
  ][
    set feromona-A-C1 ( 1 - rho ) * feromona-A-C1
  ]

  ifelse recorrido-A-C2? [
    set feromona-A-C2 ( 1 - rho ) * feromona-A-C2 + ( 1 / pasos )
  ][
    set feromona-A-C2 ( 1 - rho ) * feromona-A-C2
  ]

  ifelse recorrido-B-C3? [
    set feromona-B-C3 ( 1 - rho ) * feromona-B-C3 + ( 1 / pasos )
  ][
    set feromona-B-C3 ( 1 - rho ) * feromona-B-C3
  ]

  ifelse recorrido-B-C4? [
    set feromona-B-C4 ( 1 - rho ) * feromona-B-C4 + ( 1 / pasos )
  ][
    set feromona-B-C4 ( 1 - rho ) * feromona-B-C4
  ]

  calcular-probabilidades-A-X
  calcular-probabilidades-B-C
  calcular-probabilidades-C-X
end


;;;;;;;;;;;;;;;;;;;
;;; Movimientos ;;;
;;;;;;;;;;;;;;;;;;;


to reiniciar-desde-nido
  actualizar-feromonas

  set primer-aleatorio-generado? false
  set segundo-aleatorio-generado? false
  set tercer-aleatorio-generado? false
  set recorrido-A-B? false
  set recorrido-A-C1? false
  set recorrido-A-C2? false
  set recorrido-B-C3? false
  set recorrido-B-C4? false
  set pasos 0
  set pasos-vuelta 0
end

to siguiente-nodo
  if nodo-actual = "A" [
    mover-desde-A
  ]

  if nodo-actual = "B" [
    mover-desde-B
  ]

  if nodo-actual = "C" [
    mover-desde-C
  ]
end

to mover-desde-A
  if sgte-nodo = "B" [
    mover-A-B
  ]
  if sgte-nodo = "C1" [
    mover-A-C1
  ]
  if sgte-nodo = "C2" [
    mover-A-C2
  ]
end

to mover-desde-B
  if sgte-nodo = "C3" [
    mover-B-C3
  ]
  if sgte-nodo = "C4" [
    mover-B-C4
  ]
  if sgte-nodo = "A3" [
    mover-B-A3
  ]
end


to mover-desde-C
  if sgte-nodo = "B1" [
    mover-C-B1
  ]
  if sgte-nodo = "B2" [
    mover-C-B2
  ]
  if sgte-nodo = "A1" [
    mover-C-A1
  ]
  if sgte-nodo = "A2" [
    mover-C-A2
  ]
end


to mover-B-A3
  if xcor = -35 [ caminar-abajo ]
  if ycor = -89 [ caminar-derecha ]
  if xcor = 1 [ set nodo-actual "A" set recorrido-A-B? true reiniciar-desde-nido]
end

to mover-C-B1
  if ycor = 86 [ caminar-izquierda ]
  if xcor = -35 [ caminar-abajo ]
  if ycor = 74 [ caminar-izquierda ]
  if ycor = 62 [ caminar-izquierda ]
  if ycor = 46 [ caminar-derecha ]
  if ycor = 33 [ caminar-izquierda ]
  if ycor = 19 [ caminar-derecha ]
  if ycor = 4 [ caminar-izquierda ]
  if ycor = -10 [ caminar-derecha ]
  if ycor = -26 [ caminar-izquierda ]
  if ycor = -47 [ caminar-derecha ]
  if xcor = -74 or xcor = -89 [ caminar-abajo ]
  if ycor = -71 [ caminar-derecha ]
  if ycor = -72 [ set nodo-actual "B" set recorrido-B-C4? true set sgte-nodo "A3" setxy -35 -70 ]
end

to mover-C-B2
  if ycor = 86 [ caminar-izquierda ]
  if xcor = -36 [ caminar-abajo ]
  if ycor = -71 [ set nodo-actual "B" set recorrido-B-C3? true set sgte-nodo "A3" setxy -35 -70]
end

to mover-C-A1
  set pasos-vuelta pasos-vuelta + 1

  if xcor = -13 and pasos-vuelta < 25 and pasos-vuelta > -1 [ caminar-abajo ]
  if ycor = 65 and pasos-vuelta < 45 and pasos-vuelta > 20 [ caminar-derecha ]
  if xcor = 9 and pasos-vuelta < 140 and pasos-vuelta > 40 [ caminar-abajo ]
  if ycor = -28  and pasos-vuelta < 150 and pasos-vuelta > 120[ caminar-derecha ]
  if xcor = 24 and pasos-vuelta < 245 and pasos-vuelta > 140 [ caminar-arriba ]
  if ycor = 65 and pasos-vuelta < 260 and pasos-vuelta > 230 [ caminar-derecha ]
  if xcor = 39 and pasos-vuelta < 370 and pasos-vuelta > 250 [ caminar-abajo ]
  if ycor = -44 and pasos-vuelta < 430 and pasos-vuelta > 360 [ caminar-izquierda ]
  if xcor = -23 and pasos-vuelta < 445 and pasos-vuelta > 420 [ caminar-abajo ]
  if ycor = -62 and pasos-vuelta < 470 and pasos-vuelta > 430 [ caminar-derecha ]
  if xcor = 1 and pasos-vuelta < 500 and pasos-vuelta > 450 [caminar-abajo ]
  if ycor = -89 [ set nodo-actual "A" set recorrido-A-C1? true reiniciar-desde-nido ]

end

to mover-C-A2
  set pasos-vuelta pasos-vuelta + 1

  if ycor = 86 and pasos-vuelta < 110 and pasos-vuelta > -1 [ caminar-derecha ]
  if xcor = 92 and pasos-vuelta < 160 and pasos-vuelta > 100 [ caminar-abajo ]
  if ycor = 36 and pasos-vuelta < 190 and pasos-vuelta > 140 [ caminar-izquierda]
  if xcor = 62 and pasos-vuelta < 210 and pasos-vuelta > 170 [ caminar-abajo ]
  if ycor = 16 and pasos-vuelta < 235 and pasos-vuelta > 200 [ caminar-derecha ]
  if xcor = 92 and pasos-vuelta < 270 and pasos-vuelta > 220 [ caminar-abajo ]
  if ycor = -19 and pasos-vuelta < 285 and pasos-vuelta > 250 [ caminar-izquierda ]
  if xcor = 77 and pasos-vuelta < 295 and pasos-vuelta > 270 [ caminar-arriba ]
  if ycor = -9 and pasos-vuelta < 310 and pasos-vuelta > 280 [ caminar-izquierda ]
  if xcor = 62 and pasos-vuelta < 330 and pasos-vuelta > 300 [ caminar-abajo ]
  if ycor = -34 and pasos-vuelta < 350 and pasos-vuelta > 320 [ caminar-derecha ]
  if xcor = 82 and pasos-vuelta < 370 and pasos-vuelta > 330 [ caminar-abajo ]
  if ycor = -52 and pasos-vuelta < 390 and pasos-vuelta > 340 [ caminar-izquierda ]
  if xcor = 62 and pasos-vuelta < 405 and pasos-vuelta > 370 [ caminar-abajo ]
  if ycor = -70 and pasos-vuelta < 425 and pasos-vuelta > 390 [ caminar-izquierda ]
  if xcor = 37 and pasos-vuelta < 445 and pasos-vuelta > 400 [ caminar-abajo ]
  if ycor = -89 and pasos-vuelta < 490 and pasos-vuelta > 420 [ caminar-izquierda ]
  if xcor = 1 and pasos-vuelta > 420 [ set nodo-actual "A" set recorrido-A-C2? true reiniciar-desde-nido ]

end


;; Izquierda -> Arriba
to mover-A-B
  if ycor = -89 [ caminar-izquierda ]
  if xcor = -36 [ caminar-arriba ]
  if ycor = -70 [
    set nodo-actual "B"
    set recorrido-A-B? true
    escoger-segundo-camino
  ]
end

;; Arriba -> Izquierda -> Arriba -> Derecha -> Arriba -> Izquierda -> Abajo -> Izquierda -> Arriba -> Izquierda -> Arriba
to mover-A-C1
  if xcor = 1   and pasos < 30 and pasos > -1 [ caminar-arriba ]
  if ycor = -62 and pasos < 60 and pasos > 20 [ caminar-izquierda ]
  if xcor = -23 and pasos < 70 and pasos > 40 [ caminar-arriba ]
  if ycor = -44 and pasos < 200 and pasos > 50 [ caminar-derecha ]
  if xcor = 39  and pasos < 300 and pasos > 100 [ caminar-arriba ]
  if ycor = 65  and pasos < 400 and pasos > 200 [ caminar-izquierda ]
  if xcor = 24  and pasos < 500 and pasos > 200 [ caminar-abajo ]
  if ycor = -28 and pasos < 600 and pasos > 300 [ caminar-izquierda ]
  if xcor = 9   and pasos < 700 and pasos > 300 [ caminar-arriba ]
  if ycor = 65 and pasos < 900 and pasos > 300 [ caminar-izquierda ]
  if xcor = -13 and pasos < 800 and pasos > 400 [ caminar-arriba ]
  if ycor = 86 [ set nodo-actual "C" set recorrido-A-C1? true ]
end

;; Derecha -> Arriba -> Derecha -> Arriba -> Derecha -> Arriba -> Izquierda -> Arriba -> Derecha -> Abajo -> Derecha -> Arriba -> Izquierda -> Arriba -> Derecha -> Arriba -> Izquierda
to mover-A-C2
  if ycor = -89 and pasos < 50 and pasos > -1 [ caminar-derecha ]
  if xcor = 37  and pasos < 80 and pasos > -1 [ caminar-arriba ]
  if ycor = -70 and pasos < 100 and pasos > 50 [ caminar-derecha ]
  if xcor = 62  and pasos < 120 and pasos > 60 [ caminar-arriba ]
  if ycor = -52 and pasos < 140 and pasos > 80 [ caminar-derecha ]
  if xcor = 82  and pasos < 160 and pasos > 100 [ caminar-arriba ]
  if ycor = -34 and pasos < 180 and pasos > 120 [ caminar-izquierda ]
  if xcor = 62 and pasos < 200 and pasos > 140 [ caminar-arriba ]
  if ycor = -9  and pasos < 200 and pasos > 180 [ caminar-derecha ]
  if xcor = 77  and pasos < 220 and pasos > 180 [ caminar-abajo ]
  if ycor = -19 and pasos < 230 and pasos > 200 [ caminar-derecha ]
  if xcor = 92 and pasos < 280 and pasos > 200 [ caminar-arriba ]
  if ycor = 16 and pasos < 310 and pasos > 250[ caminar-izquierda ]
  if xcor = 62 and pasos < 400 and pasos > 260 [ caminar-arriba ]
  if ycor = 36 and pasos < 900 and pasos > 250 [ caminar-derecha ]
  if xcor = 92 and pasos < 900 and pasos > 300 [ caminar-arriba ]
  if ycor = 86 and pasos < 900 and pasos > 250 [ caminar-izquierda ]
  if xcor = -13 [ set nodo-actual "C" set recorrido-A-C2? true ]
end

;; Arriba -> Derecha
to mover-B-C3
  if xcor = -36 [ caminar-arriba ]
  if ycor = 86 [ caminar-derecha ]
  if xcor = -13 [ set nodo-actual "C" set recorrido-B-C3? true ]
end

;; Izquierda -> Arriba -> Izquierda -> Arriba -> Derecha -> Arriba -> .... -> Arriba -> Derecha
to mover-B-C4
  if ycor = -70 [ caminar-izquierda ]
  if xcor = -74 or xcor = -89 [ caminar-arriba ]
  if ycor = -47 [ caminar-izquierda ]
  if ycor = -26 [ caminar-derecha ]
  if ycor = -10 [ caminar-izquierda ]
  if ycor = 4 [ caminar-derecha ]
  if ycor = 19 [ caminar-izquierda ]
  if ycor = 33 [ caminar-derecha ]
  if ycor = 46 [ caminar-izquierda ]
  if ycor = 62 [ caminar-derecha ]
  if ycor = 74 [ caminar-derecha ]
  if xcor = -35 [ caminar-arriba ]
  if ycor = 86 [ caminar-derecha ]
  if xcor = -13 [ set nodo-actual "C" set recorrido-B-C4? true ]
end

to caminar-arriba
  set heading 0
  fd 1
  set pasos pasos + 1
end

to caminar-abajo
  set heading 180
  fd 1
  set pasos pasos + 1
end

to caminar-izquierda
  set heading -90
  fd 1
  set pasos pasos + 1
end

to caminar-derecha
  set heading 90
  fd 1
  set pasos pasos + 1
end


;;;;;;;;;;;;;;;;;;;
;;; Miscelaneas ;;;
;;;;;;;;;;;;;;;;;;;

to sumar-feromona-A-C1
  set feromona-A-C1 feromona-A-C1 * 1.5
end

to sumar-feromona-A-C2
  set feromona-A-C2 feromona-A-C2 * 1.5
end

to sumar-feromona-A-B
  set feromona-A-B feromona-A-B * 1.5
end
@#$#@#$#@
GRAPHICS-WINDOW
259
10
791
543
-1
-1
2.61
1
10
1
1
1
0
0
0
1
-100
100
-100
100
1
1
1
ticks
30.0

BUTTON
41
71
121
104
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
131
71
206
104
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
38
20
228
53
POBLACION
POBLACION
10.0
100.0
60.0
5.0
1
Hormigas
HORIZONTAL

SLIDER
46
133
218
166
alpha
alpha
0
10
4.5
0.25
1
NIL
HORIZONTAL

SLIDER
47
181
219
214
betha
betha
0
10
1.25
0.25
1
NIL
HORIZONTAL

SLIDER
49
233
221
266
rho
rho
0
1
0.01
0.01
1
NIL
HORIZONTAL

PLOT
830
224
1206
419
Feromonas
Tiempo
Cantidad
0.0
100.0
0.0
0.2
true
true
"" ""
PENS
"Izquierda" 1.0 0 -1184463 true "" "plot feromona-A-B"
"Centro" 1.0 0 -13345367 true "" "plot feromona-A-C1"
"Derecha" 1.0 0 -2674135 true "" "plot feromona-A-C2"

TEXTBOX
1252
196
1402
238
El valor de feromonas de la izquierda solo incluye el rastro hasta la primer bifurcación\n
11
0.0
1

PLOT
828
28
1205
206
Probabilidades
Tiempo
Probabilidad
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Izquierda" 1.0 0 -1184463 true "" "plot probabilidad-A-B"
"Centro" 1.0 0 -13345367 true "" "plot probabilidad-A-C1"
"Derecha" 1.0 0 -2674135 true "" "plot probabilidad-A-C2"

BUTTON
40
372
165
405
Potenciar Centro
sumar-feromona-A-C1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
36
419
169
452
Potenciar Derecha
sumar-feromona-A-C2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
32
330
171
363
Potenciar Izquierda
sumar-feromona-A-B
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

In this project, a colony of ants forages for food. Though each ant follows a set of simple rules, the colony as a whole acts in a sophisticated way.

## HOW IT WORKS

When an ant finds a piece of food, it carries the food back to the nest, dropping a chemical as it moves. When other ants "sniff" the chemical, they follow the chemical toward the food. As more ants carry food to the nest, they reinforce the chemical trail.

## HOW TO USE IT

Click the SETUP button to set up the ant nest (in violet, at center) and three piles of food. Click the GO button to start the simulation. The chemical is shown in a green-to-white gradient.

The EVAPORATION-RATE slider controls the evaporation rate of the chemical. The DIFFUSION-RATE slider controls the diffusion rate of the chemical.

If you want to change the number of ants, move the POPULATION slider before pressing SETUP.

## THINGS TO NOTICE

The ant colony generally exploits the food source in order, starting with the food closest to the nest, and finishing with the food most distant from the nest. It is more difficult for the ants to form a stable trail to the more distant food, since the chemical trail has more time to evaporate and diffuse before being reinforced.

Once the colony finishes collecting the closest food, the chemical trail to that food naturally disappears, freeing up ants to help collect the other food sources. The more distant food sources require a larger "critical number" of ants to form a stable trail.

The consumption of the food is shown in a plot.  The line colors in the plot match the colors of the food piles.

## EXTENDING THE MODEL

Try different placements for the food sources. What happens if two food sources are equidistant from the nest? When that happens in the real world, ant colonies typically exploit one source then the other (not at the same time).

In this project, the ants use a "trick" to find their way back to the nest: they follow the "nest scent." Real ants use a variety of different approaches to find their way back to the nest. Try to implement some alternative strategies.

The ants only respond to chemical levels between 0.05 and 2.  The lower limit is used so the ants aren't infinitely sensitive.  Try removing the upper limit.  What happens?  Why?

In the `uphill-chemical` procedure, the ant "follows the gradient" of the chemical. That is, it "sniffs" in three directions, then turns in the direction where the chemical is strongest. You might want to try variants of the `uphill-chemical` procedure, changing the number and placement of "ant sniffs."

## NETLOGO FEATURES

The built-in `diffuse` primitive lets us diffuse the chemical easily without complicated code.

The primitive `patch-right-and-ahead` is used to make the ants smell in different directions without actually turning.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Ants model.  http://ccl.northwestern.edu/netlogo/models/Ants.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was developed at the MIT Media Lab using CM StarLogo.  See Resnick, M. (1994) "Turtles, Termites and Traffic Jams: Explorations in Massively Parallel Microworlds."  Cambridge, MA: MIT Press.  Adapted to StarLogoT, 1997, as part of the Connected Mathematics Project.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 1998.

<!-- 1997 1998 MIT -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
