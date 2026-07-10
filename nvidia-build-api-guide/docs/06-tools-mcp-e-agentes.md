# 6. Tools, MCP e agentes

## 6.1 Conceito

O modelo não executa funções por conta própria. Ele produz uma intenção estruturada. Sua aplicação:

1. envia schemas de tools;
2. recebe `tool_calls`;
3. valida os argumentos;
4. autoriza a ação;
5. executa o código;
6. adiciona o resultado ao histórico;
7. chama o modelo novamente.

## 6.2 Definição de tool

```json
{
  "type": "function",
  "function": {
    "name": "consultar_clima",
    "description": "Consulta o clima atual de uma cidade.",
    "parameters": {
      "type": "object",
      "properties": {
        "cidade": {
          "type": "string",
          "description": "Cidade e estado ou país."
        }
      },
      "required": ["cidade"],
      "additionalProperties": false
    }
  }
}
```

## 6.3 Requisição

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "somar",
            "description": "Soma dois números.",
            "parameters": {
                "type": "object",
                "properties": {
                    "a": {"type": "number"},
                    "b": {"type": "number"},
                },
                "required": ["a", "b"],
                "additionalProperties": False,
            },
        },
    }
]

response = client.chat.completions.create(
    model=os.environ["NVIDIA_MODEL"],
    messages=[{"role": "user", "content": "Quanto é 19,5 + 7?"}],
    tools=tools,
    tool_choice="auto",
)
```

## 6.4 Loop completo

```python
import json

def somar(a: float, b: float) -> dict:
    return {"resultado": a + b}

handlers = {"somar": somar}
messages = [{"role": "user", "content": "Quanto é 19,5 + 7?"}]

for _ in range(8):
    response = client.chat.completions.create(
        model=os.environ["NVIDIA_MODEL"],
        messages=messages,
        tools=tools,
        tool_choice="auto",
    )

    assistant = response.choices[0].message
    messages.append(assistant.model_dump(exclude_none=True))

    if not assistant.tool_calls:
        print(assistant.content)
        break

    for call in assistant.tool_calls:
        name = call.function.name
        args = json.loads(call.function.arguments)

        if name not in handlers:
            result = {"error": "tool_desconhecida"}
        else:
            try:
                result = handlers[name](**args)
            except Exception as exc:
                result = {"error": type(exc).__name__}

        messages.append(
            {
                "role": "tool",
                "tool_call_id": call.id,
                "content": json.dumps(result, ensure_ascii=False),
            }
        )
else:
    raise RuntimeError("Limite de iterações do agente atingido")
```

## 6.5 Controles obrigatórios

Não confie nos argumentos gerados. Implemente:

- validação JSON Schema;
- allowlist de tools;
- limite de iterações;
- timeout por tool;
- tamanho máximo do resultado;
- sandbox para shell ou código;
- path normalization para arquivos;
- aprovação humana para efeitos irreversíveis;
- idempotency key para ações repetíveis;
- auditoria;
- redaction de secrets.

## 6.6 Prompt injection

Conteúdo de:

- páginas web;
- arquivos;
- e-mails;
- resultados de busca;
- respostas de MCP;

é dado não confiável. Não permita que o conteúdo altere políticas do agente.

Separe:

```text
Instruções do sistema
Política de autorização
Solicitação do usuário
Dados externos não confiáveis
```

## 6.7 MCP

NVIDIA NIM não se conecta diretamente ao MCP. O cliente ou framework deve:

1. conectar ao servidor MCP;
2. executar `tools/list`;
3. converter os schemas para o formato OpenAI `tools`;
4. enviar esses schemas ao modelo;
5. receber `tool_calls`;
6. executar `tools/call`;
7. devolver o resultado ao modelo.

Pseudocódigo:

```python
mcp_tools = await mcp_session.list_tools()
openai_tools = [convert_mcp_tool(t) for t in mcp_tools.tools]

response = client.chat.completions.create(
    model=model,
    messages=messages,
    tools=openai_tools,
)

for call in response.choices[0].message.tool_calls or []:
    result = await mcp_session.call_tool(
        call.function.name,
        json.loads(call.function.arguments),
    )
```

## 6.8 NIM self-hosted e parser de tools

Em NIM local, o servidor pode precisar de:

- auto tool choice habilitado;
- parser compatível com a família do modelo;
- versão NIM que suporte o modelo e o parser.

Exemplos de conceito:

```text
--enable-auto-tool-choice
--tool-call-parser <parser-compatível>
```

Não escolha o parser por tentativa cega. Siga a documentação do modelo e da versão NIM.

## 6.9 Estratégias de agente

### ReAct

Modelo alterna análise, tool e observação. Bom para tarefas exploratórias, mas exige limite de passos.

### Plan-and-execute

Um planejador cria etapas e um executor usa tools. Bom para tarefas longas; precisa replanejamento controlado.

### Workflow determinístico

O código decide a sequência e usa o modelo em pontos específicos. É a opção mais previsível para processos empresariais.

## 6.10 Aprovação

Classifique tools:

| Classe | Exemplo | Política |
|---|---|---|
| Leitura | consultar arquivo | automática com escopo |
| Escrita reversível | criar rascunho | automática ou aprovação |
| Escrita externa | enviar e-mail | aprovação |
| Destrutiva | excluir dados | aprovação forte |
| Execução | shell | sandbox + allowlist |
| Financeira | compra/pagamento | confirmação explícita |
