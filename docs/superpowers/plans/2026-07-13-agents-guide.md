# AGENTS.md Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar um guia de contribuição para agentes, em português, específico ao BytePapo.

**Architecture:** Um único arquivo Markdown na raiz concentra regras práticas que complementam, sem repetir, o README e CONTRIBUTING. O conteúdo deriva da estrutura Flutter, configuração do analisador e histórico de commits existentes.

**Tech Stack:** Markdown, Flutter 3.44.4+, Dart 3.12.2+.

## Global Constraints

- Título obrigatório: `Repository Guidelines`.
- O texto deve estar em português, ter entre 200 e 400 palavras e usar cabeçalhos Markdown.
- Não alterar o diretório `flutter/` não rastreado nem incluir credenciais.

---

### Task 1: Guia de contribuição para agentes

**Files:**
- Create: `AGENTS.md`
- Reference: `README.md`, `CONTRIBUTING.md`, `analysis_options.yaml`, `pubspec.yaml`

**Interfaces:**
- Consumes: estrutura e convenções já documentadas no repositório.
- Produces: `AGENTS.md`, referência operacional para contribuidores e agentes.

- [ ] **Step 1: Criar o guia Markdown**

Inclua as seções `Project Structure & Module Organization`, `Build, Test, and Development Commands`, `Coding Style & Naming Conventions`, `Testing Guidelines`, `Commit & Pull Request Guidelines` e `Security & Configuration` com comandos `flutter pub get`, `flutter analyze`, `flutter test` e `flutter run -d <device-id>`.

- [ ] **Step 2: Validar requisitos textuais**

Run: `rg -n "^# Repository Guidelines|flutter analyze|flutter test|fix:" AGENTS.md`

Expected: uma ocorrência do título e referências aos comandos e ao padrão de commit.

- [ ] **Step 3: Verificar comprimento e alterações**

Run: `(Get-Content -Raw AGENTS.md | Measure-Object -Word).Words; git status --short`

Expected: contagem entre 200 e 400 e somente `AGENTS.md` como novo arquivo relacionado à implementação.
