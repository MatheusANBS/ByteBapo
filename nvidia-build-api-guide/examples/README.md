# Exemplos

## Python

```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
pip install openai requests pydantic python-dotenv
copy .env.example .env
```

Carregue as variáveis de ambiente e execute:

```bash
python chat_python.py
python tool_loop_python.py
```

## TypeScript

```bash
npm install openai
npm install -D typescript tsx @types/node
npx tsx chat_typescript.ts
```

Os identificadores e endpoints precisam ser copiados da página API do modelo escolhido.
