# Coletânea de Prompts de Role-Playing — Personagens de Anime

Este ZIP contém prompts aprofundados em Markdown para personagens famosas de anime, com foco em:

- história pessoal;
- mundo e contexto ao redor;
- personalidade profunda;
- relações importantes;
- estilo de fala;
- comportamento em role-play;
- limites para evitar descaracterização;
- exemplos de respostas no tom da personagem;
- prompt compacto para bots locais.

## Estrutura

```text
coletanea_prompts_roleplay_personagens_anime_expandida/
├── 00_INDICE.md
├── 00_PROMPT_GLOBAL_FORMATACAO_ROLEPLAY.md
├── 01_GUIA_DE_USO.md
├── 02_REFERENCIAS_E_NOTAS.md
├── 03_CHECAGEM_WEB_QUALIDADE.md
├── README.md
├── TODOS_OS_PROMPTS.md
├── catalogo_personagens.json
├── catalogo_prompts_globais.json
└── prompts/
    ├── 01_violet_evergarden.md
    ├── 02_saber_artoria_pendragon.md
    ├── ...
    ├── 22_megumin.md
    ├── 23_monkey_d_luffy.md
    ├── 24_roronoa_zoro.md
    ├── 25_sanji.md
    ├── 26_tony_tony_chopper.md
    ├── 27_franky.md
    ├── 28_usopp.md
    └── 29_brook.md
```

## Uso recomendado

Para máxima fidelidade, use primeiro o arquivo `00_PROMPT_GLOBAL_FORMATACAO_ROLEPLAY.md` como guia de formatação e, em seguida, o arquivo individual de cada personagem como prompt principal.

Ordem recomendada:

1. Cole o prompt global de formatação.
2. Cole o prompt individual da personagem.
3. Opcionalmente, adicione instruções de cena, aventura, tom ou idioma.

Para modelos locais com pouco contexto, use apenas o prompt individual compacto no final do arquivo da personagem.

## Atualização desta versão

Esta v4 preserva a revisão web da v3 e adiciona o prompt global de formatação literária de role-play:

- `00_PROMPT_GLOBAL_FORMATACAO_ROLEPLAY.md` define fala, ações, pensamentos superficiais, Markdown, ritmo, cenas cômicas, emocionais, de ação e regras de consistência;
- o guia de uso foi ajustado para recomendar a ordem “prompt global + prompt de personagem”;
- `TODOS_OS_PROMPTS.md` agora começa pelo prompt global antes dos 29 prompts individuais;
- `catalogo_personagens.json` recebeu referência ao prompt global recomendado.

A base v3 já revisava **todos os 29 prompts** com checagem web e ajustes de fidelidade:

- cada personagem recebeu uma seção de checagem factual/narrativa;
- o bloco “Quando o usuário pedir conselho” foi personalizado por personagem;
- `02_REFERENCIAS_E_NOTAS.md` foi refeito com metodologia e revisão por personagem;
- `03_CHECAGEM_WEB_QUALIDADE.md` foi adicionado como relatório de auditoria;
- `catalogo_personagens.json` agora marca os itens como `checado_web_v3`;
- `TODOS_OS_PROMPTS.md` foi regenerado com os arquivos revisados.
