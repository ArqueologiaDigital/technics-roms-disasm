# A primeira onda: doze frentes, um byte de diferença e uma régua que parou sozinha

*Continuação de [O repositório dizia "três desassemblados"](2026-10-24_o_repositorio_dizia_tres_e_havia_doze.md).
A auditoria da manhã de 2026-10-24 virou vinte pacotes de trabalho. À tarde, doze deles
rodaram em paralelo, cada um numa cópia isolada do repositório, e depois passaram por um
revisor adversarial e por uma rodada de correção antes de entrar no `main`. No fim, o
`make gate-all` rodou do zero na árvore mesclada e todas as imagens saíram idênticas byte
a byte. Os números abaixo vêm de scripts versionados; a tabela em
`notes/repo-audit-2026-10-24/README.md` diz qual script produz cada um.*

## O v8 é um byte

O programa principal v8 do KN5000 nunca tinha entrado no repositório. Quando entrou, a
diferença para o v9 cabia numa frase: um único byte, em `0xFFFFE8`, que guarda o número da
versão (`0x08` contra `0x09`). Por isso o v8 não ganhou árvore própria. Ele é montado a
partir das fontes do v9 com `--defsym FW_VERSION_BYTE=0x08`, e o dump de referência não foi
versionado: o Makefile o copia do romset privado e confere o SHA-1. Assim, uma correção no v9
vale para os dois, sem chance de as duas árvores divergirem.

O sub-CPU v1.41 seguiu um caminho parecido, mas com diferenças de verdade: 124.033 bytes diferem
do v1.42. Ele é gerado a partir do v1.42 mais uma lista de edições, e o
`make gate` falha se alguém mexer no v1.42 sem regenerar o v1.41. Uma das diferenças é
legível: o v1.42 passou a zerar, no RESET, registradores de DMA e de interrupção (`DMA0V`,
`DMA2V`, `DMAR`, `DMAB`, `INTCLR`) que o v1.41 deixava como estavam.

## Os últimos 318 KB eram seis imagens

Até de manhã, os dados de tabela do KN5000 ainda traziam 318.468 bytes copiados do dump sem
explicação. Eram as seis imagens BMP da demonstração da loja. Agora elas são reconstruídas a
partir de arquivos BMP comuns e voltam idênticas ao ROM. Com isso, as oito imagens do KN5000
estão em 99,9 % de fonte. O que ainda é cópia verbatim são 6.591 bytes, todos no v7.

## O KN7000 deixou de ser quase só `.incbin`

De manhã, 3,88 % do programa do KN7000 era assembly de verdade. O resto passava direto do
dump. A conversão em massa já tinha sido medida como exata, e agora foi feita: as 3.658
funções do programa saem como instruções MN10300, e a cobertura foi para 44,58 %. Não chega a
100 % porque os 2,3 MB da região de dados continuam como `.incbin_range`, e nem deveriam ser
"convertidos": são tabelas. O próximo passo é dar tipo a essas tabelas, e com isso os
destinos dos `switch` que elas guardam ganham nome.

Os quatro irmãos MN10300 (KN2400/KN2600, KN6000, KN6500 e o plug-in da placa de expansão do
KN6000) entraram como alvos exatos. Cada imagem é regenerada em Python puro a partir do
instalador da própria Technics, e cerca de 99 % de cada faixa de código sai como instruções.
Uma correção: o plug-in arquivado como "HD-SX3" é, muito provavelmente, o do HD-SX6. O
`install.pdf` do pacote e as strings `KEY SOFT SERVICE` apontam para isso, e o
`hdsx3/README.md` reúne as evidências. O nome da pasta ficou como está até o dono decidir.

## Quando melhorar faz um número subir

No SX-WSA1R, 12.527 chamadas de macros que emitiam bytes crus viraram instruções nativas.
Sobraram 9, que dependem de três instruções que o backend LLVM ainda não conhece. O censo de
documentação acusou a mudança como piora: os operandos numéricos subiram de 5.092 para 6.148
num ROM e de 6.246 para 8.618 no outro. Não é dívida nova. É dívida que ficava escondida
dentro dos argumentos das macros e agora o censo consegue enxergar. A regra do livro-razão é
que toda alta precisa ser explicada no commit, e foi.

O mesmo vale para o KN7000. Converter 2,3 MB de passagem direta em instruções fez surgir
milhares de rotinas sem cabeçalho e de nomes provisórios (`func_…`, `loc_…`) que antes não
existiam para a régua.

## A régua que parou sozinha

Na hora de recalcular a nota semântica, o script parou com erro. A nota do KN7000 tem uma
verificação cruzada: ela só aceita o próprio número se ele bater com o de outra ferramenta,
`coverage_score.py`. A conversão tinha transformado o `program.s` numa lista de `.include`, e
o script da nota lia só o arquivo raiz. Sem a verificação, ele teria concluído, sem reclamar,
que 100 % do programa era fonte. Com ela, apontou 4.157.185 bytes contra 1.853.232 e se
recusou a continuar. A correção foi ler os `.include` do mesmo jeito que a outra ferramenta.
A nota ficou em 91,10 % no geral e 65,29 % no KN7000, que de manhã estava em 45,67 %.

Dois revisores pegaram coisas parecidas. A nova régua de documentação contava como "rotina"
todo rótulo depois de um `ret`, e a maior parte desses rótulos era só um ramo de `switch`.
Uma correção copiou endereços de RAM do v10 para cabeçalhos do v7 sem levar em conta que o v7
guarda essas variáveis em outro lugar. Os dois erros foram corrigidos antes do merge, e é
para isso que serve o revisor adversarial.

## O que ainda não está bom

- 83 % dos alvos de `call` do v10 (4.482 de 5.408) continuam sem cabeçalho, e o v10 ainda tem cerca de 29 mil
  operandos de RAM escritos como números. São as duas maiores dívidas do KN5000, e a segunda
  onda trabalha nas duas.
- Ainda faltam no repositório o KN5000 v5 e v6, o HD-AE5000 v1.10i, v1.15i e v2.01i, o sub-CPU
  v1.40 como fonte e o programa 935 do KN7000. Os dumps estão no romset privado e a segunda
  onda começou por eles.
- O KN1500 continua bloqueado: o dump do IC15 é defeituoso.
