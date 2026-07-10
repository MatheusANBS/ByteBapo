# 2. Autenticação e segurança

## 2.1 Obtenção da chave

Na página de um modelo do catálogo:

1. entre com sua conta NVIDIA;
2. participe do NVIDIA Developer Program quando solicitado;
3. abra a guia **API**;
4. selecione **Get API Key**;
5. copie a chave.

O prefixo frequentemente observado é `nvapi-`, mas não valide a chave apenas pelo prefixo.

## 2.2 Header padrão

```http
Authorization: Bearer nvapi-...
Content-Type: application/json
```

Exemplo:

```bash
curl --request POST \
  --url "https://integrate.api.nvidia.com/v1/chat/completions" \
  --header "Authorization: Bearer $NVIDIA_API_KEY" \
  --header "Content-Type: application/json" \
  --data '{
    "model": "'"$NVIDIA_MODEL"'",
    "messages": [{"role": "user", "content": "Olá"}]
  }'
```

## 2.3 Onde guardar a chave

### Desenvolvimento local

Use `.env` fora do Git:

```dotenv
NVIDIA_API_KEY=nvapi-...
```

`.gitignore`:

```gitignore
.env
.env.*
!.env.example
```

### Produção

Use secret manager:

- Kubernetes Secret com criptografia e controle de acesso;
- HashiCorp Vault;
- AWS Secrets Manager;
- Azure Key Vault;
- Google Secret Manager;
- secret store da plataforma de CI/CD.

### Nunca coloque a chave em

- React/Vite compilado;
- JavaScript executado no navegador;
- aplicativo mobile distribuído;
- Electron renderer;
- repositório;
- log;
- screenshot;
- parâmetro de URL;
- mensagem de erro enviada ao usuário.

## 2.4 Arquitetura recomendada para frontend

```text
Browser ou app
    |
    | autenticação da sua aplicação
    v
Seu backend / API gateway
    |
    | NVIDIA_API_KEY no servidor
    v
NVIDIA API
```

O backend deve aplicar:

- autenticação do seu usuário;
- quotas internas;
- validação de payload;
- timeout;
- limite de tamanho;
- auditoria;
- filtragem de conteúdo quando aplicável.

## 2.5 Rotação e incidente

Ao suspeitar de vazamento:

1. revogue ou substitua a chave;
2. remova a chave do histórico do Git;
3. invalide caches e artefatos de CI;
4. procure uso indevido nos logs;
5. gere uma chave nova;
6. atualize os secrets;
7. documente o incidente.

## 2.6 Escopos NVCF

Fluxos de assets e funções NVCF podem exigir permissões de invocação específicas. Um `403` pode significar:

- chave sem escopo;
- função não autorizada;
- modelo não disponível para sua conta;
- região ou entitlement incompatível.

Use a chave gerada ou indicada na página específica do modelo.
