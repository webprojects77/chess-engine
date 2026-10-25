# chess-engine

Motor de xadrez em Luau/Lua, sem dependências. / Chess engine in Luau/Lua, no dependencies.

Feito por 777 — Discord: 777.imt

## Português

- Movimentos legais completos: xeque, mate, afogamento, roque, en passant e promoção
- Busca negamax com alpha-beta, tabela de transposição, PVS, LMR, null-move, killers e history
- Avaliação com rei tapered, estrutura de peões, par de bispos, torres em colunas abertas e escudo do rei
- Repetição, regra dos 50 lances e material insuficiente
- FEN, SAN e parsing de lances no formato `e2e4`

```lua
local Engine = require(script.ChessEngine)
local s = Engine.new()
local move, score, depth, nodes, pv = Engine.bestMove(s, {depth = 8, time = 1.5})
print(Engine.toSAN(s, move), score)
Engine.play(s, move)
```

`score` é em centipeões do ponto de vista das brancas.

## English

- Full legal move generation: check, checkmate, stalemate, castling, en passant, promotion
- Negamax with alpha-beta, transposition table, PVS, LMR, null-move, killers and history
- Tapered evaluation, pawn structure, bishop pair, open-file rooks and king shield
- Repetition, fifty-move rule and insufficient material
- FEN, SAN and `e2e4` move parsing

`score` is in centipawns from White's point of view.
