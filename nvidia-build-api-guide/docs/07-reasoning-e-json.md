# 7. Reasoning e saída JSON

## 7.1 Reasoning não é uniforme

Modelos diferentes podem usar:

- `reasoning_effort`;
- `reasoning_budget`;
- `thinking_token_budget`;
- `chat_template_kwargs.enable_thinking`;
- comandos no prompt, como `/think` ou `/no_think`;
- nenhum controle exposto.

Não envie todos esses campos juntos.

## 7.2 Exemplo com campos do endpoint específico

```json
{
  "model": "modelo-que-documenta-estes-campos",
  "messages": [
    {"role": "user", "content": "Resolva o problema e explique o resultado."}
  ],
  "reasoning_effort": "low",
  "reasoning_budget": 2048,
  "max_tokens": 4096
}
```

Use apenas quando a página do modelo declarar suporte.

## 7.3 `extra_body` no SDK OpenAI

Campos que não fazem parte da tipagem padrão do SDK podem ser enviados com `extra_body`:

```python
response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[{"role": "user", "content": "Analise este algoritmo."}],
    max_tokens=2048,
    extra_body={
        "chat_template_kwargs": {
            "enable_thinking": True
        }
    },
)
```

No HTTP bruto, os campos de `extra_body` ficam no JSON principal conforme o contrato do endpoint.

## 7.4 Orçamento de tokens

Em alguns modelos:

```text
max_tokens = reasoning + resposta visível
```

Consequências:

- reasoning alto pode deixar pouco espaço para a resposta;
- JSON pode ser truncado;
- `finish_reason="length"` precisa ser tratado;
- custo e latência podem aumentar.

## 7.5 JSON object

Quando suportado:

```python
response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[
        {
            "role": "system",
            "content": "Responda somente com JSON válido."
        },
        {
            "role": "user",
            "content": "Extraia nome e idade de: Ana, 31 anos."
        },
    ],
    response_format={"type": "json_object"},
)
```

Mesmo assim:

1. faça `json.loads`;
2. valide com schema;
3. rejeite campos extras;
4. trate truncamento;
5. não execute valores diretamente.

## 7.6 JSON Schema

Alguns modelos ou backends aceitam structured output com schema. O formato exato pode variar. Exemplo conceitual:

```json
{
  "type": "json_schema",
  "json_schema": {
    "name": "pessoa",
    "strict": true,
    "schema": {
      "type": "object",
      "properties": {
        "nome": {"type": "string"},
        "idade": {"type": "integer", "minimum": 0}
      },
      "required": ["nome", "idade"],
      "additionalProperties": false
    }
  }
}
```

Confirme se a página do modelo suporta `json_schema`, apenas `json_object` ou nenhum dos dois.

## 7.7 Parsing seguro

```python
from pydantic import BaseModel, ConfigDict, Field, ValidationError

class Pessoa(BaseModel):
    model_config = ConfigDict(extra="forbid")
    nome: str = Field(min_length=1, max_length=200)
    idade: int = Field(ge=0, le=150)

try:
    pessoa = Pessoa.model_validate_json(texto)
except ValidationError as exc:
    # solicitar correção, usar fallback ou falhar explicitamente
    raise
```

## 7.8 Não dependa de raciocínio oculto

Para auditoria, solicite:

- resultado;
- premissas;
- evidências;
- cálculos verificáveis;
- nível de confiança;
- limitações.

Não trate texto de reasoning como prova de correção. Valide o resultado por código, testes ou fontes.
