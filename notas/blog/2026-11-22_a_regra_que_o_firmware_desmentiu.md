# A regra que o próprio firmware desmentiu

*Continuação de [Programas aleatórios contra o modelo](2026-11-10_programas_aleatorios_contra_o_modelo.md). O
contexto é o plano de 2026-11-22, `notes/cc900-feedback-plan-2026-11-22/README.md`: usar o que o trabalho de
reescrever o firmware em C ensinou para modelar o compilador da Toshiba que a Technics usou, com o objetivo final de
um substituto em LLVM. Os números vêm de `z2_veto.py` e `z2.md`, no mesmo diretório.*

## O ponto de partida

Não temos o compilador com que o firmware do KN5000 foi compilado. Temos três parentes dele: o cc900 V4.23, um de
2003 e um de 2009. Com o V4.23, numa máquina virtual, já se reconstroem em C 12.783 funções do firmware, byte a byte
(16,66 % de todo o código das ROMs). A pergunta que sobra é em que o compilador da Technics difere do V4.23.

Até hoje, a resposta mais firme era uma regra, a da recarga depois de um armazenamento. Quando o código guarda um
registrador numa variável da pilha e lê de volta a mesma variável na instrução seguinte, o V4.23 escreve a leitura,
e o compilador de 2003 a omite, porque o valor já está no registrador. Três rotinas da biblioteca C ligada ao
firmware (`_ldiv`, `_ultoa`, `_ldexp`) têm a forma de 2003. Por isso a regra estava anotada como "o compilador da
Technics faz como o de 2003".

## O teste que faltava

A evidência a favor da regra vinha só da biblioteca. Faltava o teste contrário: há função do próprio firmware que
o V4.23 reproduz exatamente *e* que contém o par armazenar-e-recarregar? Se houver, a ROM tem a recarga ali, e o
compilador da Technics não a omitiu.

O teste custa pouco, porque não precisa compilar nada. As listagens que o V4.23 produziu para cada tentativa já
estão guardadas, e o índice de quase-acertos diz quais delas batem com a ROM. Basta procurar o par dentro de cada
função que bate.

## O resultado

- **290 funções** que o V4.23 reconstrói byte a byte têm o par, somando 59.257 bytes, em todas as imagens: as seis
  versões do programa principal, as três do sub-CPU e as quatro do HD-AE5000. Na ROM, a recarga está lá.
- Do outro lado, 51 das 824 funções ainda não reconstruídas têm o par na melhor tentativa. Tirá-lo (como faria o
  compilador de 2003) faz **uma** delas bater, melhora outra, piora 27 e não muda as demais 22.

Ou seja, a regra não vale para o C do firmware. A forma de 2003 nas três rotinas da biblioteca diz algo sobre quem
compilou a biblioteca, que veio pronta, e não sobre quem compilou o código da Technics. `rules.md` foi corrigido no
mesmo commit.

## Por que isso importa

Era a única diferença confirmada entre o compilador da Technics e o V4.23. Sem ela, o compilador da Technics fica,
até prova em contrário, muito mais perto do V4.23 do que se pensava. A consequência prática é que o melhor
investimento é o modelo do próprio V4.23, que precisa ficar exato, mais do que uma lista de regras específicas da
Technics. O plano já previa esse risco; agora ele tem número.

A lição de método também fica. Uma regra tirada de três rotinas pode explicar essas três e estar errada no resto,
e o teste que a derruba já existia nos nossos próprios dados. Por isso o plano trata as funções que já batem como
**conjunto de veto**: elas não confirmam uma regra, mas qualquer uma delas pode derrubá-la.
