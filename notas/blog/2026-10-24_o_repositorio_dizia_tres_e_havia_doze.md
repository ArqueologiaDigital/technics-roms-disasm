# O repositório dizia "três desassemblados" — e havia doze firmwares à espera

*Uma auditoria de leitura, sem tocar em nada, do repositório `technics-roms-disasm`
em 2026-10-24: o que existe em disco, o que está no repositório, e quão bem rotulado
e comentado está o que já entrou. Seis auditores em paralelo e um crítico de
completude que refez as oito medições mais pesadas. Tudo o que está aqui tem o
comando que o produziu em `notes/repo-audit-2026-10-24/audit-2026-10-24.json`.*

## O que eu acreditava antes

O `README.md` do repositório abre dizendo que ele "agora guarda três desassemblados"
(KN5000, SX-WSA1R, SX-KN7000) e, mais abaixo, que o esforço está "em cerca de 85 %"
com o montador ASL — um texto de dezembro de 2025 que nunca foi atualizado quando
o backend LLVM virou a fonte autoritativa e as 22 imagens passaram a remontar byte a
byte (`make gate-all`, 1 min 05 s, verde no início da sessão).

O "três" é verdade sobre o que foi feito. É falso sobre o que falta fazer, e é aí
que a auditoria mudou o que eu acreditava.

## O que havia em disco e não no repositório

Nenhum destes exige abrir um instrumento. Todos estão na máquina, quase todos
regeneráveis a partir dos discos de atualização da própria Technics:

| família            | artefato                                                 | de onde vem                                   | estado em 2026-10-24                   |
|--------------------|----------------------------------------------------------|-----------------------------------------------|----------------------------------------|
| KN5000             | programa principal v5, v6, v8                            | dumps no romset privado                       | ausentes                               |
| KN5000             | sub-CPU v1.40 e v1.41 (descomprimidos e comprimidos)     | `original_ROMs/` (já versionados!)            | só o dump; nenhum Makefile os constrói |
| KN5000 / HD-AE5000 | v1.10i, v1.15i, v2.01i                                   | dumps no romset privado                       | ausentes                               |
| KN7000             | programa 893 (lido do próprio KN7000 do Felipe), 929, 935 | romset privado                                | ausentes                               |
| KN7000             | tabela 80; os 64 KiB de boot no início do IC18           | romset privado                                | ausentes                               |
| KN2400 / KN2600    | programa v1.1 (`LKG1/LKG2.SLD`)                          | instalador `kn24-11.zip`                      | ausente                                |
| KN6000             | programa v7.1 (`IK1/IK2.SLD`)                            | instalador `kn6-71.zip`                       | ausente                                |
| KN6500             | programa v1.3 (`IKV1/IKV2.SLD`)                          | instalador `kn65-13.zip`                      | ausente                                |
| HD-SX3 (KN6000)    | plug-in XAPR `hd-sx3_v1_1.bin`                           | `EXTAPR.SLD` dentro de `sx6v113a.exe`         | ausente                                |

Os quatro últimos são Panasonic MN10300, a mesma CPU do KN7000, e trazem a mesma
tabela de reflexão "MILK" que dá nomes de graça: o `gen_symbols.py` do KN7000, apontado
para as imagens certas, recupera 2.471 nomes no KN2400, 1.293 no KN6000, 1.434 no KN6500 e
98 no HD-SX3 — a maioria já conhecida do KN7000 e do KN5000. A cadeia `.exe → .SLD →
imagem` é Python puro (`sfx_extract.py`, `sld_decompress.py`, `smck_check.py`, todos já
no repositório), ao contrário do que o README do romset privado afirma ("precisa de
DOSBox").

## O que a auditoria desfez

- **v8 não é um ROM novo.** `cmp -l` entre v8 e v9 imprime uma linha: o byte em
  `0xFFFFE8`, `0x08` contra `0x09`. É o byte de versão, e vale 05/06/07/08/09/0A nas
  seis versões. Um "quarto desassemblado" do programa principal custa um símbolo.
- **`hd-ae5000.ic4` sem versão é o v1.15i**, byte a byte (SHA-1 `581fa58e…`), e é
  idêntico ao `HKEXTROM.XAP` dentro do instalador oficial `AE5-115.exe`.
- **A nota de agosto que chamava o v1.40 comprimido de "única cópia existente"
  estava errada**: o romset privado tem o v1.40 descomprimido desde 2026-07-20, e o
  repositório também o versiona.
- **Todos os 14 disquetes do KN5000 são só dados** (estilos, papéis de parede, um
  `.RCM`); idem os 9 do WSA1R. Dos discos KN6000/KN7000, só os Style Convert trazem
  programas, e esses já estavam desassemblados.
- **A tabela 80 do KN7000 é a tabela 83 do SP7001 sem o plug-in e com um byte
  diferente**, a string de build em `0x139EE9` (`'0'` contra `'3'`).
- **O dump do KN1500 é defeituoso**: 4 dos 8 blocos de 256 KiB têm todo byte ímpar
  em `0xFF`. Um esqueleto só reproduziria um dump ruim.

## O que o repositório afirma sobre si e não é

- `make rom-status` (e portanto `make website`) lê caminhos ASL que não existem mais
  e grava um diagrama em branco dentro de um diretório versionado.
- `make llvm-convert-all`, ainda documentado como passo normal, sobrescreveria as
  árvores `.s` autoritativas com conversões do arquivo ASL **pré-renomeação**.
- `.gitattributes` manda fundir `.beads/issues.jsonl` com um driver `bd` que foi
  removido da máquina em julho: toda fusão do arquivo de issues falha.
- O README do KN7000 diz "111 funções convertidas, zero escapes"; são 998 e três.
- O README do WSA1 diz 175 KB em `.incbin`; são zero.

## Quão bem rotulado está o que já entrou

Os emblemas dizem 96,95 % (KN5000) e 92,62 % (WSA1R). Não mentem — mas medem o que
veem, e há coisas que não veem:

- **Comentários de cabeçalho.** 82,6 % dos alvos de `call` do KN5000 v10 (4.397 de
  5.320) não têm um bloco de comentário acima; v9 e v7 pioram para 93 %, em parte
  porque 944 e 784 cabeçalhos escritos no v10 nunca foram copiados para eles, contra a
  própria política de sincronização entre versões.
- **Operandos numéricos.** 29.044 operandos do v10 ainda endereçam RAM por número
  (3.471 endereços; os mil mais usados cobrem 74 % das referências). No WSA1R são
  cerca de 7.000.
- **Rótulos locais invisíveis.** O HD-AE5000 tem 1.164 rótulos `.L<pfx>_<addr>` que o
  emblema não conta porque nunca chegam ao ELF — por isso marca 99,97 %.
- **KN7000 fora da régua.** O `semantic_score.py` só conhece dois modelos; o KN7000
  está em 3,88 % de fonte real e não aparece em emblema nenhum.
- **A conversão em massa do KN7000 já é exata.** Trocar o conjunto `CONVERT` do
  gerador por "todas as funções nomeadas" produz uma imagem byte a byte igual
  (194 s para gerar, 35 s para montar), região 1 de 5 % para 92 %. O que impedia não
  era o codificador: era legibilidade — 70.238 alvos de desvio numéricos e 4.992
  `func_XXXXXXXX`.

## O que decidi sem perguntar

O repositório tem um remoto público no GitHub. Dumps do KN5000 e do WSA1R já estão
commitados; o `kn7000/` nunca commitou os seus e os regenera dos discos. Para todo
alvo novo desta sessão vale a convenção do `kn7000/`: imagem de referência fora do
git, regenerada do instalador ou copiada do romset privado por regra do Makefile,
SHA-1 registrada. O dono pode mudar isso; está anotado em
`notes/repo-audit-2026-10-24/README.md`.

## O que vem a seguir

Vinte pacotes de trabalho, ordenados por valor sobre esforço, no mesmo JSON. Doze
deles entraram em execução no mesmo dia, cada um em seu próprio worktree, com um
revisor adversarial e um corretor; este texto será complementado quando eles
pousarem — e só então os números acima deixam de ser verdade.
