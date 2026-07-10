# 12. APIs especializadas

## 12.1 Princípio geral

APIs especializadas não devem ser encapsuladas como se fossem Chat Completions. Crie adaptadores por domínio.

```typescript
interface NvidiaAdapter<Input, Output> {
  validate(input: Input): void;
  invoke(input: Input, signal?: AbortSignal): Promise<Output>;
  normalize(raw: unknown): Output;
}
```

## 12.2 Healthcare e biologia

O catálogo pode incluir modelos e pipelines para:

- sequências genômicas;
- multiple sequence alignment;
- estrutura de proteínas;
- design de proteínas;
- docking molecular;
- geração molecular;
- imagens médicas;
- segmentação 3D.

Entradas possíveis:

- FASTA;
- PDB/mmCIF;
- SMILES;
- volumes médicos;
- máscaras;
- parâmetros científicos;
- assets.

Saídas possíveis:

- sequências;
- estruturas;
- coordenadas;
- scores;
- arquivos;
- visualizações;
- jobs assíncronos.

Boas práticas:

- valide alfabeto e tamanho das sequências;
- normalize unidades;
- preserve identificadores;
- registre versão de banco de dados;
- não trate o resultado como diagnóstico;
- mantenha revisão humana especializada;
- respeite privacidade de dados clínicos;
- siga licença e intended use do model card.

## 12.3 Clima

Endpoints de modelos climáticos podem usar domínio como:

```text
https://climate.api.nvidia.com/...
```

Entradas podem incluir:

- condição inicial;
- dataset ou sample ID;
- variáveis atmosféricas;
- área geográfica;
- horizonte;
- resolução.

Saídas podem ser arrays científicos, NetCDF, mapas ou assets. Preserve CRS, grade, unidade, timestamp e convenção de longitude.

## 12.4 Otimização com cuOpt

Endpoint hospedado pode seguir:

```text
POST https://optimize.api.nvidia.com/v1/nvidia/cuopt
```

Casos:

- vehicle routing;
- pickup and delivery;
- time windows;
- capacidades;
- custos;
- restrições.

Para instâncias grandes, use assets quando indicado. Valide:

- matriz de custos;
- simetria ou assimetria;
- índices de nós;
- unidade de tempo;
- capacidade;
- veículos;
- janelas;
- solução inviável.

## 12.5 Detecção de mídia sintética

Alguns modelos usam gRPC e recebem:

- vídeo;
- áudio;
- frames;
- metadados.

A saída é probabilística. Não use um único score como prova definitiva. Defina threshold por avaliação, mantenha trilha de auditoria e revisão humana.

## 12.6 Áudio

Famílias possíveis:

- ASR;
- tradução;
- text-to-speech;
- remoção de ruído;
- diarização;
- speaker detection.

Parâmetros recorrentes:

- sample rate;
- canais;
- codec;
- idioma;
- timestamps;
- segmentação;
- voz;
- streaming.

Sempre converta áudio para formato aceito e evite resampling repetido.

## 12.7 Safety e guardrails

Modelos de segurança podem classificar:

- prompt;
- resposta;
- imagem;
- combinação multimodal.

Arquitetura:

```text
input
 -> validação
 -> guard de entrada
 -> modelo principal
 -> guard de saída
 -> política da aplicação
 -> usuário
```

Um guard model não substitui autorização, validação de tools ou política de negócio.

## 12.8 Adaptador por endpoint

```python
from dataclasses import dataclass
from typing import Protocol, Any

class Adapter(Protocol):
    def invoke(self, payload: dict[str, Any]) -> Any: ...

@dataclass
class EndpointConfig:
    url: str
    timeout_seconds: int
    asynchronous: bool
    uses_assets: bool
    transport: str
```

Mantenha testes de contrato gravados para cada adaptador.
