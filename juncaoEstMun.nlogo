;Começar apresentando a interface
;botões do usuário
;tela da execução
;Seção de monitoramento
;
;setup criação dos agentes nas escolas, escolas nas posições
;
;mostrar as funções de construção dos monitores
;todos os monitores são acionados e consequentemente atualizados.
;plotar um grafico do students-studying em tempo de execução
;
;executar cenário geral sem nova escola por 50 anos
;executar cenário geral com nova escola por 50 anos
;realizar análises dos gráficos e de saturação
;
;executar cenário municipal sem nova escola por 50 anos
;executar cenários municipal com nova escola por 50 anos
;realizar análises dos gráficos e de saturação
;
;voltar para cenário geral, executar sem limpar a tela, para parecer o processo de clusterização
;executar sem fazer com que novos alunos já escolham a escola -
;acompanhar execução de um estudante - mostrar no inspecionar, passar os anos até a classe ser atualizada
;Comentar que sempre no início da simulação a lista de estudantes é reordenada para que estudantes sem escola tenham acesso a alteração de escola.
;
;alterar a densidade de um bairro pouco populoso e mostrar dinâmica de crescimento no grafico de bairros e ao criar nova escola com e sem aumento da população.
;
;falar sobre a renda, que é atualizada anualmente, assim como as classes. Estudantes > 18 que somente começam a ter renda e ela é atualizada 90% para dissídio, que seria algo em torno de 5% com base nos últimos anos.
; documentação
extensions [gis]

globals [shapefiles ilhota ab bla ba bb bc bs bv bdb ce il mi mis pda poc sj students-percentual capacity-scale new-total-students-eligible total-first-choice]

breed [schools a-school]
breed [students a-student]

schools-own [name school-type area-name available-class capacity new-school number-students]
students-own [chosen-school previous-school start-age age income area-name class]


to setup
  clear-all
  reset-ticks
  set years 0
  set students-percentual 0.3
  setup-map
  setup-schools
  setup-students
  ask patches [
    set pcolor green
  ]
end


to go-repeat
  go
  wait 0.1
end


to go-single
  go
end


to go
  clear-drawing ; comentar para teste 1
  set total-first-choice 0
  foreach shapefiles [ shapefile ->
    gis:draw shapefile 1
  ]

  if ticks >= 100 [
    print "Limite de execucao excedido"
    stop
  ]

  ask students [
    if ticks != 0 [
       let ag age + 1
       set age ag
    ]
    if age > 18 [
      leave-school
    ]
  ]

  ; priroiza os que nao tem escola ainda
  let sorted-students sort-by [ [a b] ->
  ifelse-value ([chosen-school] of a = nobody and [chosen-school] of b != nobody)
    [true] ; Coloca no topo os que não têm escola definida
    [false]
  ] students

   let students-list sort students

   ask students [
      set class define-student-class
      set income redistribute-income [income] of self
      if age <= 18 [
        choose-school
    ]
   ]
  update-density

  tick
  set years ticks
end


to setup-map
  set ilhota gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/cidade_ilhota.shp"
  set ab gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/alto_bau.shp"
  set bla gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/barra_de_luiz_alves.shp"
  set ba gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/barranco_alto.shp"
  set bb gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/bau_baixo.shp"
  set bc gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/bau_central.shp"
  set bs gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/bau_seco.shp"
  set bv gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/boa_vista.shp"
  set bdb gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/braco_do_bau.shp"
  set ce gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/centro.shp"
  set il gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/ilhotinha.shp"
  set mi gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/minas.shp"
  set mis gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/missoes.shp"
  set pda gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/pedra_de_amolar.shp"
  set poc gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/pocinho.shp"
  set sj gis:load-dataset "C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/sao_joao.shp"
  set shapefiles (list ab bla ba bb bc bs bv bdb ce il mi mis pda poc sj)

  foreach shapefiles [ shapefile ->
    gis:draw shapefile 1
  ]

  gis:set-world-envelope (gis:envelope-of ilhota)
  gis:set-drawing-color black

  let growth 2.72
  set alto-bau-annual-growth growth
  set barra-de-luiz-alves-annual-growth growth
  set barranco-alto-annual-growth growth
  set bau-baixo-annual-growth growth
  set bau-central-annual-growth growth
  set bau-seco-annual-growth growth
  set boa-vista-annual-growth growth
  set braco-do-bau-annual-growth growth
  set centro-annual-growth growth
  set ilhotinha-annual-growth growth
  set minas-annual-growth growth
  set missoes-annual-growth growth
  set pedra-de-amolar-annual-growth growth
  set pocinho-annual-growth growth
  set sao-joao-annual-growth growth

end


to setup-schools
   set capacity-scale round(480 * scale-factor / 100)
  create-schools 1 [
    set area-name "ilhotinha"
    set school-type "municiple"
    set shape "house"
    set color brown
    set name "Escola Municipal Domingos José Machado"
    set xcor 26
    set ycor -25
    set available-class [1 2]
    set capacity capacity-scale
  ]

  create-schools 1 [
    set area-name "minas"
    set school-type "municiple"
    set shape "house"
    set color orange
    set name "Escola Municipal José Elias de Oliveira"
    set xcor 7
    set ycor -38
    set available-class [1 2]
    set capacity capacity-scale
  ]

  create-schools 1 [
    set area-name "bau-central"
    set school-type "municiple"
    set shape "house"
    set color pink
    set name "Escola Municipal Alberto Schmitt"
    set xcor -4
    set ycor 9
    set available-class [1 2]
    set capacity capacity-scale
  ]

  create-schools 1 [
    set area-name "alto-bau"
    set school-type "municiple"
    set shape "house"
    set color gray
    set name "Escola Municipal Pedro Teixeira de Melo"
    set xcor -22
    set ycor 16
    set available-class [1 2]
    set capacity capacity-scale
  ]

  set capacity-scale round(750 * scale-factor / 100)
  create-schools 1 [
    set area-name "ilhotinha"
    set school-type "state"
    set shape "house"
    set color yellow
    set name "EEB Marcos Konder"
    set xcor 18
    set ycor -21
    set available-class [1 2 3]
    set capacity capacity-scale
  ]

  create-schools 1 [
    set area-name "pedra-de-amolar"
    set school-type "state"
    set shape "house"
    set color violet
    set name "EEB Valério Gomes"
    set xcor 33
    set ycor 3
    set available-class [1 2 3]
    set capacity capacity-scale
  ]

end


to setup-students
  create-students-district ab
  create-students-district bla
  create-students-district ba
  create-students-district bb
  create-students-district bc
  create-students-district bs
  create-students-district bv
  create-students-district bdb
  create-students-district ce
  create-students-district il
  create-students-district mi
  create-students-district mis
  create-students-district pda
  create-students-district poc
  create-students-district sj
end



to create-students-district [shapefile]
  foreach gis:feature-list-of shapefile [ this-area ->
    let num-students round (scale-factor / 100 * gis:property-value this-area "densidade" * gis:property-value this-area "area") * students-percentual
    gis:create-turtles-inside-polygon this-area students num-students [
      set area-name gis:property-value this-area "bairro"
      set age distribute-age
      set start-age age
      set income 0
      set chosen-school nobody
      set previous-school nobody
      set shape define-shape
      set color white
      set class define-student-class
    ]
  ]
end


to choose-school
  let min-distance 90
  let closest-school nobody
  let first-choice true
  let school-list sort schools
  foreach school-list [
    school ->
    if school-accept-student school [
      let dist (manhattan-distance school)
      if dist < min-distance [
        set min-distance dist
        set closest-school school
      ]
     ]
   ]

  ifelse closest-school != nobody [
    if [chosen-school] of self != nobody [
      set first-choice false
      ask chosen-school [
        let students-updated number-students - 1
        set number-students students-updated
      ]

      set previous-school chosen-school
    ]
    set color [color] of closest-school
    set chosen-school closest-school
    set shape define-shape
    ask chosen-school [
      let new-students-updated number-students + 1
      set number-students new-students-updated
    ]
    pen-down
    face closest-school
    move-to closest-school
    if first-choice = true [
      set total-first-choice total-first-choice + 1
    ]
  ] [
    if [chosen-school] of self = nobody [
      set color red
    ]
  ]

end


to leave-school
  if [xcor] of self != 50 [
    if chosen-school != nobody [
      ask chosen-school [
        let students-updaed number-students - 1
        set number-students students-updaed
      ]
    ]
    set previous-school [chosen-school] of self
    set chosen-school nobody
    set pen-mode "up"
    set color green
    setxy max-pxcor max-pycor
    set shape "x"
  ]
end


to find-school
  let new-area-name nobody
  let selected-students students with [
    chosen-school = nobody and age <= 18
  ]

  if any? selected-students [
    let median-x round(mean [xcor] of selected-students)
    let median-y round(mean [ycor] of selected-students)
    let point list median-x median-y


    create-schools 1 [
      set school-type "state"
      set shape "house"
      set color 95
      set name "Nova Escola"
      set xcor median-x
      set ycor median-y
      set size 2
      set available-class [1 2 3]
      set capacity capacity-scale

      foreach shapefiles [ shapefile ->
        if gis:contains? shapefile self [
          foreach gis:feature-list-of shapefile [ this-area ->
            set new-area-name gis:property-value this-area "bairro"
            set new-school true
          ]
        ]
      ]

      set area-name new-area-name
      print(word "Nova escola criada no bairro " new-area-name)
    ]
  ]


end


to update-density
  let new-students-total 0
  foreach shapefiles [ shapefile ->
    foreach gis:feature-list-of shapefile [ this-area ->
      let district gis:property-value this-area "bairro"
      let slider-growth-name word district "-annual-growth"
      let annual-growth runresult slider-growth-name ; busca o valor do slider pelo nome
      let current-num-students students-per-area district
      let current-num-students-incremented current-num-students
      let total-students round (current-num-students-incremented * (annual-growth / 100 + 1))
      set current-num-students-incremented total-students
      let new-students current-num-students-incremented - current-num-students
      set new-students-total new-students-total + new-students
      if new-students > 0 [
        gis:create-turtles-inside-polygon this-area students new-students [
          set area-name gis:property-value this-area "bairro"
          set age 6
          set start-age age
          set income distribute-income
          set shape define-shape
          set color white
          set class 1
          set chosen-school nobody
          set previous-school nobody
          ask self [
            choose-school ; comentar para teste 2
          ]
        ]
      ]
  ]
]
set new-total-students-eligible new-students-total
end


to-report manhattan-distance [target]
  report (abs (pxcor - [pxcor] of target)) + (abs (pycor - [pycor] of target))
end


to-report school-accept-student [school]
  if [number-students] of school < [capacity] of school [
    report member? class  [available-class] of school
  ]
;  print (word "lotação total " [name] of school)
  report false
end


to-report distribute-age
  let prob random-float 1

  if prob < 0.336 [
    ;; 33,6% - Idade entre 6 e 9 anos
    report random 4 + 6
  ]
  ifelse prob < 0.661 [
    ;; 32,5% - Idade entre 10 e 14 anos
    report random 5 + 10
  ]
  [
    ;; 33,9% - Idade entre 15 e 18 anos
    report random 4 + 15
  ]
end


to-report distribute-income
  if age <= 18 [report 0]
  let prob random-float 1
  if prob < 0.70 [
    ;; 70% dos estudantes ganham menos de 2 salários mínimos
    report (random 1420 + 1420)
  ]
  ifelse prob < 0.90 [
    ;; 20% dos estudantes ganham entre 3 e 8
    report (random 5000 + 3000)
  ]
  [
    ;; 10% dos estudantes ganham entr 8 e 10
    report (random 2000 + 8000)
  ]
end


to-report redistribute-income [current-income]
  if age <= 18 [report 0]
  if income = 0 [report distribute-income]
  let amount 0
  let number random 100
  let income-inflation-updated (current-income * 0.05)
  ifelse number < 90 [ ; 90% somente dissidio
    set amount amount + income-inflation-updated
  ][
    let increment (random 1000 + 500)
    set amount amount + income-inflation-updated + increment
  ]

  report round(amount + current-income)
end


to-report define-shape
  report "person"
end


to-report define-student-class
  ifelse age >= 6 and age <= 11 [
    report 1
  ]
  [
  ifelse age >= 12 and age <= 15 [
    report 2
  ]
  [
    report 3
  ]
  ]
end


to-report students-per-area [area]
  let students-in-area students with [area-name = area]
  if any? students-in-area [
    report count students-in-area
  ]
  report 0
end


to-report students-per-school [school-name]
  let school-selected one-of schools with [name = school-name]
  if school-selected != nobody [
    report [number-students] of school-selected
  ]
  report 0
end


to-report average-income
  if any? students [
    report mean [income] of students
  ]
  report 0
end


to-report average-income-per-area [area]
  let students-in-area students with [area-name = area]
  if any? students-in-area [
    report round(mean [income] of students-in-area)
  ]
  report 0
end


to-report count-municipal-to-estadual
  let migrated count students with [
    previous-school != nobody and [school-type] of previous-school = "municiple" and [school-type] of chosen-school = "state"
  ]
  report migrated
end


to-report school-capacity [school-name]
  let school-selected one-of schools with [name = school-name]
  if school-selected = nobody [
    report 0
  ]

  let students-in-school students with [chosen-school = school-selected]
  let count-students count students-in-school
  let remaining-positions [capacity] of school-selected - count-students
  ifelse remaining-positions >= 0 [
    report remaining-positions
  ][
    report 0
  ]

end



to-report students-moved-between-areas
  let moved-students count students with [
    chosen-school != nobody and
    area-name != [area-name] of chosen-school
  ]
  report moved-students
end


to-report students-studying
  let count-students count students with [
    chosen-school != nobody and age <= 18
  ]
  report count-students
end


to-report students-not-studying
  let count-students count students with [
    chosen-school = nobody and age <= 18
  ]
  report count-students
end


to-report students-not-graduated
  let count-students count students with [
    age > 18 and chosen-school = nobody
  ]
  report count-students
end


to-report students-graduated
  let count-students count students with [
    age > 18
  ]
  report count-students
end

to-report new-students-eligible
  report new-total-students-eligible
end
@#$#@#$#@
GRAPHICS-WINDOW
249
38
1072
862
-1
-1
8.07
1
10
1
1
1
0
0
0
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
130
227
211
260
NIL
go-single
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
52
227
115
260
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

SLIDER
35
109
207
142
years
years
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
34
161
206
194
scale-factor
scale-factor
0
100
35.0
1
1
NIL
HORIZONTAL

SLIDER
323
405
415
438
alto-bau-annual-growth
alto-bau-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
268
104
360
137
bau-seco-annual-growth
bau-seco-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
685
111
777
144
braco-do-bau-annual-growth
braco-do-bau-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
429
576
521
609
bau-baixo-annual-growth
bau-baixo-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
867
232
959
265
pedra-de-amolar-annual-growth
pedra-de-amolar-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
459
641
551
674
pocinho-annual-growth
pocinho-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
989
378
1081
411
barranco-alto-annual-growth
barranco-alto-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
552
692
644
725
centro-annual-growth
centro-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
958
612
1050
645
ilhotinha-annual-growth
ilhotinha-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
982
512
1075
545
barra-de-luiz-alves-annual-growth
barra-de-luiz-alves-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
689
848
781
881
minas-annual-growth
minas-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
861
835
953
868
sao-joao-annual-growth
sao-joao-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
389
504
481
537
bau-central-annual-growth
bau-central-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

SLIDER
1010
694
1102
727
boa-vista-annual-growth
boa-vista-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

PLOT
1113
611
1538
885
População por bairro
Time
population
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"alto-bau" 1.0 0 -14454117 true "" "plot count students with [area-name = \"alto-bau\"]\n"
"bau-central" 1.0 0 -2674135 true "" "plot count students with [area-name = \"bau-central\"]"
"barra-de-luiz-alves" 1.0 0 -7500403 true "" "plot count students with [area-name = \"barra-de-luiz-alves\"]"
"barranco-alto" 1.0 0 -955883 true "" "plot count students with [area-name = \"barranco-alto\"]"
"bau-baixo" 1.0 0 -6459832 true "" "plot count students with [area-name = \"bau-baixo\"]"
"bau-seco" 1.0 0 -1184463 true "" "plot count students with [area-name = \"bau-seco\"]"
"boa-vista" 1.0 0 -10899396 true "" "plot count students with [area-name = \"boa-vista\"]"
"braco-do-bau" 1.0 0 -13840069 true "" "plot count students with [area-name = \"braco-do-bau\"]"
"centro" 1.0 0 -14835848 true "" "plot count students with [area-name = \"centro\"]"
"ilhotinha" 1.0 0 -11221820 true "" "plot count students with [area-name = \"ilhotinha\"]"
"minas" 1.0 0 -13791810 true "" "plot count students with [area-name = \"minas\"]"
"missoes" 1.0 0 -13345367 true "" "plot count students with [area-name = \"missoes\"]"
"pocinho" 1.0 0 -8630108 true "" "plot count students with [area-name = \"pocinho\"]"
"pedra-de-amolar" 1.0 0 -5825686 true "" "plot count students with [area-name = \"pedra-de-amolar\"]"
"sao-joao" 1.0 0 -2064490 true "" "plot count students with [area-name = \"sao-joao\"]"

PLOT
1296
106
1537
226
Renda média população
years
Salary
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -11085214 true "" "  if any? students [\n    plot mean [income] of students\n  ]\n"

MONITOR
1109
116
1278
161
Quantidade alunos formados
students-graduated
0
1
11

PLOT
1112
290
1594
442
Estudantes por escola
Students
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"EEB Marcos Konder" 1.0 0 -1184463 true "" "plot students-per-school \"EEB Marcos Konder\""
"EEB Valério Gomes" 1.0 0 -8630108 true "" "plot students-per-school \"EEB Valério Gomes\""
"Nova Escola" 1.0 0 -13791810 true "" "plot students-per-school \"Nova Escola\""
"EM Pedro Teixeira de Melo" 1.0 0 -7500403 true "" "plot students-per-school \"Escola Municipal Pedro Teixeira de Melo\""
"EM Alberto Schmitt" 1.0 0 -2064490 true "" "plot students-per-school \"Escola Municipal Alberto Schmitt\""
"EM José Elias de Oliveira" 1.0 0 -955883 true "" "plot students-per-school \"Escola Municipal José Elias de Oliveira\""
"EM Domingos José Machado" 1.0 0 -6459832 true "" "plot students-per-school \"Escola Municipal Domingos José Machado\""

PLOT
1113
452
1575
602
Capacidade das escolas
Escola
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"EEB Marcos Konder" 1.0 0 -1184463 true "" "plot school-capacity \"EEB Marcos Konder\""
"EEB Valério Gomes" 1.0 0 -8630108 true "" "plot school-capacity \"EEB Valério Gomes\""
"Nova Escola" 1.0 0 -13791810 true "" "plot school-capacity \"Nova Escola\""
"EM Pedro Teixeira de Melo" 1.0 0 -7500403 true "" "plot school-capacity \"Escola Municipal Pedro Teixeira de Melo\""
"EM Alberto Schmitt" 1.0 0 -2064490 true "" "plot school-capacity \"Escola Municipal Alberto Schmitt\""
"EM José Elias de Oliveira" 1.0 0 -955883 true "" "plot school-capacity \"Escola Municipal José Elias de Oliveira\""
"EM Domingos José Machado" 1.0 0 -6459832 true "" "plot school-capacity \"Escola Municipal Domingos José Machado\""

PLOT
1570
97
1770
247
Deslocamento bairro origem
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot students-moved-between-areas"

MONITOR
1111
176
1277
221
Quantidade alunos sem escola
students-not-studying
0
1
11

BUTTON
136
284
223
317
NIL
go-repeat
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1113
237
1281
282
NIL
students-studying
0
1
11

BUTTON
36
284
128
317
NIL
find-school
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1301
237
1432
282
Demanda
new-students-eligible
17
1
11

MONITOR
1450
235
1554
280
Oferta
total-first-choice
17
1
11

SLIDER
545
758
637
791
missoes-annual-growth
missoes-annual-growth
0
100
2.72
0.1
1
NIL
HORIZONTAL

PLOT
1686
471
1886
621
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot students-studying"

@#$#@#$#@
# Documentação do Modelo NetLogo

## Extensões
- **GIS**: Utilizada para carregar e manipular shapefiles e realizar operações espaciais.

## Globais
- **shapefiles**: Lista de shapefiles carregados.
- **ilhota, ab, bla, ba, bb, bc, bs, bv, bdb, ce, il, mi, mis, pda, poc, sj**: Variáveis para armazenar shapefiles específicos dos bairros.
- **students-percentual**: Percentual de estudantes em relação à densidade populacional.
- **capacity-scale**: Escala de capacidade para as escolas.
- **new-total-students-eligible**: Número de estudantes elegíveis.
- **total-first-choice**: Contador de estudantes que escolheram uma escola como primeira opção.

## Raças (Breeds)
- **schools**: Representa as escolas.
  - Propriedades:
    - **name**: Nome da escola.
    - **school-type**: Tipo da escola (municipal ou estadual).
    - **area-name**: Nome do bairro onde está localizada.
    - **available-class**: Lista de classes oferecidas.
    - **capacity**: Capacidade máxima de alunos.
    - **new-school**: Indicador se é uma nova escola.
    - **number-students**: Número atual de alunos.
- **students**: Representa os estudantes.
  - Propriedades:
    - **chosen-school**: Escola escolhida.
    - **previous-school**: Escola anterior.
    - **start-age**: Idade inicial.
    - **age**: Idade atual.
    - **income**: Renda do estudante.
    - **area-name**: Bairro de origem.
    - **class**: Classe escolar do estudante.

## Procedimentos

### `setup`
- Limpa e inicializa o modelo.
- Configura o mapa, cria escolas e estudantes.
- Define patches com cor verde.

### `go`
- Atualiza o estado do modelo a cada tick.
- Realiza operações como atualização da idade, movimentação dos estudantes, e alocação nas escolas.

### `setup-map`
- Carrega shapefiles de bairros.
- Configura o envelope mundial do GIS.
- Define taxas de crescimento populacional anuais para os bairros.

### `setup-schools`
- Cria escolas com propriedades específicas.
- Define suas localizações e capacidades.

### `setup-students`
- Cria estudantes para cada bairro com base na densidade populacional.

### `create-students-district`
- Gera estudantes dentro de polígonos representados no shapefile do bairro correspondente.

### `choose-school`
- Aloca estudantes em escolas baseando-se na distância e disponibilidade.

### `leave-school`
- Remove estudantes que atingem a idade limite (acima de 18 anos) de suas escolas.

### `find-school`
- Identifica a necessidade de criar novas escolas baseando-se na distribuição espacial de estudantes sem escola.

## Caminhos e Parâmetros Importantes
- Caminho dos shapefiles: Exemplo, `"C:/Users/Jardel/Desktop/Furb/TCC2/ProjetoTCC/dados_ibge/ilhota/bairros/cidade_ilhota.shp"`.
- Escala de capacidade de escolas: Calculada proporcionalmente à variável `scale-factor`.

## Dinâmica
- O modelo simula a escolha de escolas pelos estudantes considerando fatores como idade, renda, e proximidade.
- O crescimento populacional nos bairros impacta a densidade e, consequentemente, a distribuição de estudantes.

## Visualização
- Os shapefiles são desenhados a cada tick para ilustrar os limites dos bairros.
- Escolas são representadas como casas de diferentes cores, e estudantes movem-se em direção às escolas escolhidas.

## Observações
- O modelo inclui lógica para criação de novas escolas com base na demanda.
- A idade máxima dos estudantes no sistema é de 18 anos.
- Estudantes sem escola definida são destacados com a cor vermelha.
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
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
