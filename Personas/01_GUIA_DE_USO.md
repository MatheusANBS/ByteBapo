# Guia de Uso da Coletânea

## Como usar

1. Abra `00_PROMPT_GLOBAL_FORMATACAO_ROLEPLAY.md`.
2. Cole esse prompt global como guia de formatação.
3. Abra o arquivo Markdown da personagem desejada.
4. Copie a seção inteira **Prompt principal** ou use o arquivo completo como prompt base.
5. Cole em um bot, personagem local, Ollama, SillyTavern, Character Card, Open WebUI, LM Studio, Jan, AnythingLLM ou outro ambiente de RP.
6. Para conversas mais curtas, use a seção **Prompt compacto para colar em bots**.

## Como adaptar

### Para RP de aventura
Adicione ao final do prompt:

```text
Priorize cenas de exploração, decisões de jornada, perigos ambientais, interação com aliados e progressão narrativa. Sempre ofereça ganchos para a próxima ação do usuário.
```

### Para RP emocional
Adicione:

```text
Priorize conversas íntimas, memória, conflitos internos, vulnerabilidade e evolução lenta da confiança. Evite resolver emoções de forma rápida.
```

### Para chat curto estilo personagem
Adicione:

```text
Responda em mensagens curtas, naturais e conversacionais, mantendo a voz da personagem. Evite monólogos longos, exceto quando o usuário pedir.
```

### Para bot local com baixa capacidade de contexto
Use apenas estas partes do arquivo:

- Identidade central
- Personalidade profunda
- Estilo de fala
- Comportamento em role-play
- Limites de descaracterização
- Exemplos de respostas

## Recomendações de temperatura

- Personagens caóticas: 0.85 a 1.05 — Power, Megumin, Usagi.
- Personagens analíticas: 0.55 a 0.75 — Kurisu, Motoko, Riza, Makima.
- Personagens contemplativas: 0.60 a 0.80 — Frieren, Violet, Rei, Homura.
- Personagens de ação: 0.65 a 0.90 — Mikasa, Saber, Yoruichi, Tsunade.

## Formato sugerido de system prompt

```text
[cole aqui o conteúdo de 00_PROMPT_GLOBAL_FORMATACAO_ROLEPLAY.md]

[cole aqui o prompt da personagem]

Instrução final: a personalidade da personagem tem prioridade sobre a formatação. Use a formatação apenas para deixar a cena legível, natural e literária.
```
