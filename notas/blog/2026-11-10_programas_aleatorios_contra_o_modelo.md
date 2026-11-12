# Programas aleatórios contra o modelo do compilador: o que as sondas escritas à mão não viam

*Continuação de [A primeira onda](2026-10-24_a_primeira_onda.md). O contexto é o plano
`notes/cc900-compat-plan-2026-11-08/PLAN.md`: ensinar o nosso backend LLVM para TLCS-900 a
gerar exatamente o código que o compilador da Toshiba (cc900 V4.23) gerou para o firmware
dos teclados, instrução por instrução. A fase 3a é um modelo de referência em Python,
`scripts/analysis/cc900/model/`, conferido linha a linha contra as listagens do compilador
original, que só roda numa máquina virtual isolada. Os números abaixo vêm do portão do
modelo (`sh model/ledger.sh`, `model/semcheck.py --ledger`, `model/pairs_model.py`), cujos
resultados estão em `scripts/analysis/cc900/results/`.*

## Dois jeitos de estar errado

Um modelo de compilador pode errar de dois jeitos. Pode escrever o código *diferente* do
original, e isso a comparação de listagens pega: a linha difere, a função não é "exata".
Ou pode escrever código que *calcula outra coisa*, e isso a comparação de listagens também
pega, mas trata igual a qualquer outra diferença, perdida no meio de centenas de funções
que só diferem na ordem de dois operandos. Para o objetivo do projeto, as duas são
diferentes: a primeira é trabalho pendente; a segunda é um compilador quebrado.

Desde 2026-11-09 há um verificador semântico, `model/semcheck.py`: ele interpreta o
código do modelo e o código do original com os mesmos valores de entrada (48 sorteios por
função, entre eles valores pequenos, extremos e cheios) e compara o que cada um devolveu,
escreveu na memória e passou às funções que chamou. "DIFFERENT" quer dizer código errado,
não só código diferente.

## O corpus escrito à mão estava limpo. O aleatório, não.

As 674 funções do corpus pequeno (`corpus/micro/`) e as sondas (`corpus/probes/`) são
exatas nas quatro combinações de opções do compilador há dias, e o verificador semântico
as dá por iguais. Com isso parecia razoável acreditar que o gerador do modelo estava certo
onde chegava a gerar.

Em 2026-11-10 entrou um gerador de programas aleatórios, `corpus/gen_random.py`: 200
funções de C89 por semente, cada uma misturando os construtos que as sondas exercitam um
por vez (índices que são `char`, ponteiros para membros de struct, atribuições encadeadas,
`?:`, chamadas como operandos, laços contados). O compilador original compilou as duas
primeiras sementes na máquina virtual; o modelo foi conferido contra elas.

O resultado da primeira semente: o modelo chegou a compilar cerca de 60 das 200 funções em
cada combinação de opções, e **47 vereditos de código errado** entre elas. A segunda
semente, depois de todas as correções da primeira: **81 vereditos**. Nenhum desses erros
aparecia nas 674 funções escritas à mão, porque cada sonda isola um construto e os erros
estavam nas interações: um valor deixado num registrador enquanto a instrução seguinte
carregava um ponteiro no mesmo registrador; uma cópia de variável em `C` que um
deslocamento `sla 0x2,C` tinha destruído; um parâmetro em `WA` sobrescrito por um
`lda XWA,_gia` do cálculo de um endereço; os pops dos argumentos de uma chamada soltos no
meio dos pushes da chamada seguinte, o que jogava fora um argumento já empilhado; um
`switch` cujo último braço deixava os pops para depois do rótulo de junção, que os outros
braços também alcançavam, desequilibrando a pilha.

## O que o compilador original faz, visto de perto

Imitar o compilador inclui imitar o que ele faz de errado, porque o firmware foi montado
com isso. Dois exemplos que os programas aleatórios trouxeram e que uma sonda dedicada
(`corpus/probes/chidx.c`, 50 funções) confirmou:

- um índice que é `char` com sinal fica num byte onde o modo de endereçamento aceita um
  registrador de 8 bits: `gia[c]` vira `ld A,(c) / add A,(c) / lda XBC,_gia / ld HL,(XBC+A)`;
  e a expressão `gia[u * 2]`, com `u` um `unsigned char`, é calculada no byte, de modo que
  o programa lê o elemento `(u * 2) & 0xff`. É um defeito do compilador de 1997; o modelo
  o reproduz, e o verificador semântico passou a dar as duas versões por iguais;
- `gu % gu` com `gu` um `unsigned int` é dobrado para zero, enquanto `gul / gul` com
  `unsigned long` chama a rotina de divisão.

## O guarda de parâmetros vivos

A terceira rodada de correções acrescentou uma rede de segurança que não existia: sob
`-Xr`, quando os três primeiros parâmetros chegam em `WA`, `BC` e `DE`, qualquer instrução
que escreva num desses registradores enquanto o parâmetro ainda vai ser lido por um
comando posterior faz o modelo recusar a função em vez de emitir código errado. Para o
objetivo do projeto, recusar é aceitável e errar não é: uma função recusada aparece como
"unsupported" nos números e espera uma regra; uma função errada passaria pelo portão e
viraria firmware diferente do original.

## A ordem dos operandos, medida de uma vez

Os três primeiros corpora aleatórios tinham uma diferença recorrente que não era erro: em `a - (b - c)` o
compilador original calculava primeiro o lado direito; em `(256 - a) | !*p`, primeiro o esquerdo. "O operando
mais pesado primeiro" era a hipótese. Em vez de continuar ajustando caso a caso, uma sonda de 507 funções
(`corpus/probes/evorder.c`) combinou treze tipos de operando dos dois lados de `-`, `^` e `*`, com o lado
esquerdo lendo variáveis `g*` e o direito `h*`, de modo que a listagem diz sozinha quem foi calculado antes.
A regra que saiu é a mesma nas quatro combinações de opções: um operando é o acumulador (HL; XWA na
multiplicação) e o outro é a fonte da instrução. Na subtração o acumulador é sempre o esquerdo; nos operadores
comutativos, um valor que precisa de cálculo vira o acumulador, uma constante nunca, dois operandos endereçados
fazem o da direita vencer, e no resto fica o esquerdo. Os endereços vêm na ordem do texto, depois o valor da
fonte, depois o acumulador, depois o operador; e os registradores seguem uma fila fixa, com o índice de um vetor
tomando WA e XBC antes de todo o resto. Com a regra no modelo, a sonda passou de 118 para 442 funções exatas
sem opções e de 115 para 383 com `-O3 -XS`.

A mesma sonda, repetida para a divisão (`evorder_d.c`), para as comparações (`cmpord.c`) e para as rotinas
auxiliares de `long` (`evorder_lh.c`), mostrou que a regra é uma só e que o que muda é o lugar de cada operando
na instrução final. Numa comparação, um lado calculado vai para `WA` e um lado que é variável fica na memória
(`cp (_gi),WA` para `<`, `cp WA,(_gi)` para `==`); dois lados calculados comparam `cp BC,WA`, com o direito
primeiro; um `*p` à esquerda fica `(XBC)`. E há um detalhe que só uma sonda sistemática pegaria: em
`if (!gi == 7)` o compilador compara `!gi` com o *valor lógico* de 7, isto é, com 1, enquanto em `x = !gi == 7`
o 7 fica inteiro. Nas rotinas auxiliares de `long`, o esquerdo vai em `XWA` e o direito em `XBC`, os endereços
dos ponteiros primeiro, as constantes por último e as cargas dos ponteiros por último, no lugar. As três sondas
passaram, respectivamente, de 86 para 252, de 0 para 429 e de 30 para 246 funções exatas sem opções.

## Onde mora uma variável local

Dois terços das funções aleatórias eram recusadas inteiras, e uma recusa esconde as outras: a função tem oito
comandos e o modelo desiste no primeiro que não sabe compilar. Um pequeno bissector (`stmt_bisect.py`, no
`research-scratch`) compila cada comando de uma função recusada sozinho e diz qual deles é o culpado. O campeão,
de longe, era a declaração de uma variável local com valor inicial: `int *t = gpi;`, `unsigned long t = gula[5];`,
`unsigned char t = guc + 212;`. O modelo só sabia duas coisas sobre elas: dobrar a variável no único uso, ou
guardá-la em `IZ` quando sobrevive a uma chamada.

A sonda `loc0.c` (512 funções: oito tipos, quatro inicializadores, quatro comandos intermediários, quatro usos)
mostrou a regra inteira, igual nas quatro combinações de opções. Uma local cujo valor não atravessa nenhuma chamada
é um *temporário em registrador*: fica em `WA` quando só os próprios usos a seguem; senão vai para o mais baixo de
`BC`, `DE`, `HL` que o código intermediário não escreve; o resultado de uma chamada fica em `HL` e recebe o operador
ali mesmo (`cal _ri / add HL,(_hi)`); um `char` ocupa a metade baixa (`ld C,(_gc)`), mas um `char` calculado passa
por `A` antes; a soma de ponteiro passa por `XWA`. O modelo tenta os candidatos em ordem e deixa a própria guarda de
registradores vivos acusar quando o código intermediário escreve a casa escolhida, recomeçando com a seguinte.
A sonda passou de 116 para 510 funções exatas sem opções, e as funções aleatórias recusadas inteiras caíram de 546
para 497 em 800.

## O endereço antes do valor, menos quando não

A segunda recusa mais comum era "o valor sobrescreve o endereço da atribuição": o modelo calculava o endereço de
`gps->i = gps->a[a] % a` em `XWA`, e a divisão, que precisa de `XWA`, o destruía. Em vez de adivinhar, outra sonda
(`stord.c`, 432 funções: oito formas de lado esquerdo, dezoito de lado direito, em `int`, `long` e `char`) mediu a
ordem e os registradores de cada combinação. O compilador original calcula o endereço primeiro e o valor depois,
exceto depois de uma chamada, quando o endereço vem depois (`cal _ri / ld XWA,(_gps) / ld (XWA+0x2),HL`). Um `*p`
simples vai para `XBC` com o valor em `WA`, seja qual for o valor; um membro com deslocamento vai para `XBC` antes de
um valor carregado em `WA`, mas para `XWA` antes de um valor calculado em `BC` (`ld XWA,(_gps) / ld BC,(_hi) /
sub BC,(_hj) / ld (XWA+0x2),BC`); um elemento de vetor global usa `BC` e `XDE`, ou `WA` e `XBC` com o valor em `DE`
quando o valor é uma subtração; a rotina auxiliar de `long` guarda o endereço em `XIZ` através da chamada. O modelo
ganhou um planejador de atribuições com essa tabela; a sonda foi de 212 para 337 funções exatas sem opções.

O verificador semântico pagou de novo: ao compilar funções que antes recusava, o modelo errou em seis formas novas,
entre elas um temporário destruído dentro do próprio comando que o lia e uma comparação de byte com constante de
dezesseis bits (`cp A,0xffc2`). Todas foram corrigidas antes de o lote entrar.

## Comparar longs e chars

Com as variáveis locais e as atribuições no lugar, a recusa mais comum que sobrou nos
programas aleatórios foi "operando de comparação complexo": o modelo sabia comparar dois
inteiros de 16 bits em todas as combinações (a sonda `cmpord.c`, de manhã), mas não dois
longs nem dois chars. A sonda `cmpordl.c` repete a tabela para esses dois tamanhos: catorze
tipos de operando para long (constante, global, membro, ponteiro, elemento, `!x`, `-x`,
diferença, `256L - x`, `?:`, deslocamento, membro via ponteiro, chamada), doze para char,
cada um de cada lado de `<` e de `==`, 680 funções.

A tabela é a dos inteiros com os registradores de 32 e de 8 bits, e três coisas que os
inteiros não tinham mostrado. Primeiro, `==` não é `<` com outro salto: quando os dois
lados são memória ou endereço, é o *direito* que é carregado (`ld XWA,(_hs + 0x4) /
cp XWA,(_gs + 0x4)`), e quando o direito é um valor calculado ou uma chamada, a instrução
inverte os operandos (`cal _hfl / cp XHL,(_gl)` em vez do `cp (_gl),XHL` do `<`). Segundo,
um `?:` como operando mantém a forma com desvio, e o outro lado tem o endereço tomado
*antes* dela (`lda XBC,_gs + 0x4`, depois os dois braços em XWA, depois `cp (XBC),XWA`).
Terceiro, e este é o tipo de coisa que só se vê medindo: dois operandos derivados de chars
são comparados no byte, embora o C os promova a int (`-gc < hc` vira `ld A,(_gc) / neg A /
cp A,(_hc)`), exceto um `!c`, que é comparado como palavra contra o outro lado estendido
com sinal.

A sonda sai de 158 para 674 das 680 funções exatas sem otimização. As seis que faltam são
duas chamadas de função dos dois lados (o original guarda o primeiro resultado em XIZ) e a
comparação de duas constantes, que o modelo compila certo mas com um rótulo a mais. Sob
`-O3 -XS` o original gera o mesmo código em 553 das 680; o modelo passa a aplicar a regra
também ali na rodada seguinte.

## O operando endereçado, e o que o compilador faz com um cast

A sonda seguinte, `evorder_ad.c`, cruza os operandos "endereçados" (um ponteiro desreferenciado,
um membro via ponteiro, um elemento de vetor, uma chamada) com os oito operadores binários, em
int, long e char: 1.116 funções. A regra que sai é a mesma das comparações, agora para somas e
produtos: o endereço do operando da direita é calculado antes, o da esquerda é carregado depois
(`ld XBC,(_hpi) / ld WA,(_gi) / sub WA,(XBC)`), um ponteiro à esquerda tem a própria carga antes
de tudo, e uma operação comutativa entre dois operandos endereçados carrega o da *direita* e deixa
o da esquerda como operando de memória, exatamente como o `==`. Uma chamada vem primeiro e é o
acumulador (`cal _gfi / sub HL,(_hi)`). O modelo sobe de 590 para 954 das 1.116 funções.

Duas descobertas vieram de fora das tabelas. A primeira: duas chamadas numa operação de long
("gfl() + hfl()") eram compiladas pelo caminho antigo guardando o primeiro resultado em IZ, um
registrador de 16 bits; a verificação semântica pegou, e agora o resultado vai para XIZ, como no
original.

Tabelas medidas por sondas têm um defeito previsível: o programa aleatório sempre traz o par que a
sonda não trouxe. Por isso as duas regras novas ganharam uma guarda. Cada endereço e cada valor que
montam fica anotado com a linha em que ficou pronto, e uma instrução que lê um deles depois que
outra linha escreveu num registrador de que ele depende é recusada. Na primeira rodada a guarda
encontrou três formas de código errado que nenhuma sonda continha. Encontrou também uma colisão
antiga, que só agora ficou alcançável: o código de ponto flutuante usava XIZ para endereçar um
elemento de vetor dentro de um laço cujo contador morava justamente em IZ. A segunda veio da sonda das comparações de segunda leva (`cmpordl2.c`, 572
funções com casts, índices locais, vetores em structs via ponteiro): o compilador original trata
um cast *explícito* que alarga (`(long)gc < 7L`) como uma conversão de verdade, com `exts WA /
exts XWA`, enquanto a promoção implícita do mesmo char é comparada no byte. O frontend passa a
marcar os casts escritos no fonte. E uma variável local inicializada e nunca usada ainda é
calculada, em WA, e jogada fora: era a recusa "local t" que aparecia em dezenas de programas
aleatórios.

## Depois do desligamento: atribuições encadeadas

O computador foi desligado no meio de um lote; a nota de retomada, escrita antes, bastou para
reconstruir a cópia de trabalho a partir do patch e conferir que ela era idêntica à salva. O lote
voltou ao portão e entrou.

A sonda seguinte veio de uma forma que os programas aleatórios produzem e que nenhuma sonda tinha
medido: a atribuição usada como valor de outra (`*gpl = (gla[3] = gs.l)`) e como valor de retorno
(`return gla[t] = gl`). O compilador original resolve os dois casos com uma regra de alocação
simples: o endereço de fora primeiro, o de dentro depois, o valor por último, e os registradores
WA, BC, DE e HL distribuídos nessa ordem entre o ponteiro externo (quando é um membro via ponteiro),
o endereço interno, o elemento externo, o valor e o ponteiro externo simples. Um valor calculado
inverte a ordem: guarda-se primeiro no destino de dentro e só então se monta o endereço de fora.
Para chars a regra muda, porque o endereço de um elemento de vetor de chars passa por XWA. O
modelo saiu de 49 para 321 das 392 funções da primeira sonda e de 28 para 264 das 280 da segunda.

## O índice que mora num registrador

As sondas anteriores indexavam vetores sempre pelo parâmetro `c`, que sem otimização fica na
pilha. Nos programas aleatórios o índice costuma ser outra coisa: o contador de um laço, uma
variável que sobrevive a uma chamada e por isso mora em IZ, ou uma variável temporária que o
modelo pôs num registrador. A sonda `idxloc.c` cruza essas três moradas com doze formas de
comando. Ela mostrou que o compilador original usa o registrador do índice diretamente no
endereçamento de um vetor de chars (`ld A,(XWA+IZ)`), e mostrou também um erro antigo do modelo:
uma variável local lida uma única vez era "dobrada" no comando seguinte mesmo quando esse comando
chamava uma função antes de lê-la, de modo que `int t = gi; gia[t] = ri();` lia `gi` depois da
chamada. A verificação semântica pegou; o modelo agora mantém a variável.

## Onde isso deixa o modelo

No fechamento do dia: as 674 funções do corpus pequeno exatas nas quatro combinações de
opções; a biblioteca de 1997 em 186 de 248 funções exatas; 223 pares de rotinas do
firmware reconstruídos byte a byte pelo nosso próprio toolchain; o primeiro corpus
aleatório sem nenhum veredito de código errado; o segundo com os vereditos restantes
revisados um a um em `model/semcheck_review.tsv` (todos são leituras fora do vetor,
comportamento indefinido em C em que o modelo e o original estendem o índice de maneiras
diferentes); o laço contado sob `-O3 -XS` que ficara aberto, fechado na madrugada seguinte.

Uma terceira semente, compilada logo depois, trouxe mais 52 vereditos, e dois deles valem
registro porque nenhuma sonda os teria pego: uma variável local usada uma única vez, dentro
de um `switch` ou de um laço que também chama uma função, era "dobrada" no ponto de uso,
de modo que o modelo relia a variável global *depois* da chamada que podia tê-la alterado;
e o `return` que segue um `switch` sem `default` era içado para junto da cadeia de
comparações, de modo que um braço com `break` chegava ao fim da função sem calcular o valor
de retorno. Um lote de correções deixou a terceira semente com três vereditos, todos
revisados como comportamento indefinido.

A taxa de funções aleatórias *exatas* continua baixa (2 a 4 %): o modelo ainda recusa dois
terços delas por construtos que não conhece, e as que compila diferem do original na ordem
em que avaliam operandos e nos registradores que escolhem. O critério da fase é 95 %. A
lição do dia não é o número: é que a métrica que importa para um compilador é a semântica,
e que só programas que ninguém escreveu de propósito a testam de verdade.

Em 12 de novembro, uma regra inofensiva expôs um erro antigo. Sob `-O`, o original não
calcula o inicializador de uma variável local que nunca é lida; ensinar isso ao modelo
fez uma função aleatória (`r2_05_16`, com `-O3 -XS -Xr`) seguir adiante em vez de ser
recusada, e a verificação semântica acusou código errado na linha seguinte:
`gu = ~(gs.u + a)` carregava `gs.u` no registrador WA, onde estava o parâmetro `a`, e somava
WA a si mesmo. O defeito estava no modelo desde antes desta série de regras: com `-Xr`,
`gi = gi + a` já saía como `ld WA,(_gi) / add WA,WA`. Nenhuma sonda o pegara porque nenhuma
escrevia um global somado a um parâmetro em registrador. A correção usa a forma do próprio
original (`add WA,(_gi)`, o operando de memória somado ao parâmetro no lugar) e recusa o
resto.
