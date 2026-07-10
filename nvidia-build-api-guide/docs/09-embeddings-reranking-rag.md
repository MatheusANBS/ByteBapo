# 9. Embeddings, reranking e RAG

## 9.1 Embeddings

Endpoint comum:

```text
POST https://integrate.api.nvidia.com/v1/embeddings
```

Exemplo:

```bash
curl "https://integrate.api.nvidia.com/v1/embeddings" \
  -H "Authorization: Bearer $NVIDIA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "'"$NVIDIA_EMBEDDING_MODEL"'",
    "input": ["Documento A", "Documento B"],
    "input_type": "passage",
    "encoding_format": "float",
    "truncate": "END"
  }'
```

## 9.2 `input_type`

Modelos Retriever podem exigir:

- `passage`: documentos a indexar;
- `query`: consulta de busca.

Use o tipo correto em cada etapa. A assimetria faz parte do treinamento de alguns modelos.

## 9.3 Campos comuns

| Campo | Uso |
|---|---|
| `model` | Identificador |
| `input` | String ou lista |
| `input_type` | `query` ou `passage`, quando exigido |
| `encoding_format` | `float` ou `base64`, conforme suporte |
| `truncate` | Política como `NONE`, `START` ou `END` |
| `user` | Pode ser ignorado por alguns endpoints |

Dimensão e contexto são específicos do modelo.

## 9.4 Python

```python
result = client.embeddings.create(
    model=os.environ["NVIDIA_EMBEDDING_MODEL"],
    input=["Clean Architecture separa regras de negócio."],
    encoding_format="float",
    extra_body={
        "input_type": "passage",
        "truncate": "END",
    },
)

vector = result.data[0].embedding
print(len(vector))
```

## 9.5 Normalização

Antes de indexar:

- preserve o texto original;
- normalize Unicode;
- remova lixo de layout;
- guarde metadados;
- use chunking coerente;
- não faça stemming agressivo sem avaliação;
- registre versão do modelo de embedding.

Nunca misture vetores de modelos ou dimensões diferentes no mesmo índice sem separação.

## 9.6 Chunking

Ponto de partida:

- 300 a 800 tokens por chunk;
- overlap de 10% a 20%;
- respeitar títulos e parágrafos;
- não cortar tabelas no meio;
- guardar `document_id`, `chunk_id`, página e seção.

Ajuste por avaliação real.

## 9.7 Similaridade

Com embeddings normalizados, cosine similarity pode ser implementada por produto escalar:

```python
import numpy as np

def cosine(a, b):
    a = np.asarray(a, dtype=np.float32)
    b = np.asarray(b, dtype=np.float32)
    denom = np.linalg.norm(a) * np.linalg.norm(b)
    if denom == 0:
        return 0.0
    return float(np.dot(a, b) / denom)
```

## 9.8 Reranking

Fluxo:

```text
query
  -> embedding/lexical/hybrid retrieval
  -> top 20-200 candidatos
  -> reranker
  -> top 3-20
  -> prompt do LLM
```

Um reranker cross-encoder avalia a consulta junto de cada candidato. É mais caro que busca vetorial e não deve percorrer o corpus inteiro.

## 9.9 Endpoint de reranking

A URL é específica do modelo, por exemplo no padrão:

```text
POST https://ai.api.nvidia.com/v1/retrieval/<modelo>/reranking
```

Payload típico:

```json
{
  "model": "modelo-de-reranking",
  "query": {
    "text": "Como funciona o fluxo de aprovação?"
  },
  "passages": [
    {"text": "Documento 1..."},
    {"text": "Documento 2..."}
  ],
  "truncate": "END"
}
```

Não generalize o caminho ou schema sem abrir a página do reranker.

## 9.10 Pipeline RAG

```python
def answer_with_rag(question: str) -> str:
    query_vector = embed_query(question)
    candidates = vector_store.search(query_vector, limit=50)
    reranked = rerank(question, candidates)
    selected = reranked[:8]

    context = "\n\n".join(
        f"[{item['source']}]\n{item['text']}"
        for item in selected
    )

    response = client.chat.completions.create(
        model=os.environ["NVIDIA_CHAT_MODEL"],
        messages=[
            {
                "role": "system",
                "content": (
                    "Responda apenas com base no contexto. "
                    "Cite os identificadores das fontes. "
                    "Quando faltar evidência, diga que não encontrou."
                ),
            },
            {
                "role": "user",
                "content": f"CONTEXTO:\n{context}\n\nPERGUNTA:\n{question}",
            },
        ],
        temperature=0.1,
    )
    return response.choices[0].message.content
```

## 9.11 Avaliação

Meça separadamente:

- recall@k da recuperação;
- MRR ou NDCG do ranking;
- precisão factual;
- completude;
- taxa de citação correta;
- abstention quando não há evidência;
- latência;
- custo/tokens;
- resistência a prompt injection no corpus.

## 9.12 Versionamento

Ao trocar o embedding:

1. crie novo índice;
2. re-embed todo o corpus;
3. execute avaliação;
4. faça migração gradual;
5. mantenha rollback.

Não atualize metade do índice com o modelo novo.
