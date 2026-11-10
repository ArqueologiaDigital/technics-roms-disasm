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

## Onde isso deixa o modelo

No fechamento do dia: as 674 funções do corpus pequeno exatas nas quatro combinações de
opções; a biblioteca de 1997 em 186 de 248 funções exatas; 223 pares de rotinas do
firmware reconstruídos byte a byte pelo nosso próprio toolchain; o primeiro corpus
aleatório sem nenhum veredito de código errado; o segundo com os vereditos restantes
revisados um a um em `model/semcheck_review.tsv` (quase todos são leituras fora do vetor,
comportamento indefinido em C em que o modelo e o original estendem o índice de maneiras
diferentes), e um caso aberto, um laço contado sob `-O3 -XS`.

A taxa de funções aleatórias *exatas* continua baixa (2 a 4 %): o modelo ainda recusa dois
terços delas por construtos que não conhece, e as que compila diferem do original na ordem
em que avaliam operandos e nos registradores que escolhem. O critério da fase é 95 %. A
lição do dia não é o número: é que a métrica que importa para um compilador é a semântica,
e que só programas que ninguém escreveu de propósito a testam de verdade.
