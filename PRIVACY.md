# Privacidade

O BytePapo foi projetado para uso local com servidores Ollama acessíveis pela rede local.

## Dados armazenados localmente

O app pode armazenar localmente no dispositivo:

- servidores cadastrados;
- modelo selecionado;
- personagens;
- instructions globais;
- conversas;
- mensagens do histórico;
- preferências de uso.

Esses dados são mantidos no próprio dispositivo usando armazenamento local do app.

## Dados enviados pela rede

As mensagens enviadas no chat são transmitidas para o servidor Ollama configurado pelo usuário.

O BytePapo não envia conversas para um servidor próprio do projeto, não possui backend próprio e não realiza sincronização em nuvem.

## Responsabilidade do usuário

O usuário é responsável por:

- configurar corretamente o servidor Ollama;
- proteger a rede local;
- evitar exposição pública insegura;
- não inserir informações sensíveis em servidores ou redes não confiáveis.

## Terceiros

O processamento das mensagens ocorre no servidor Ollama configurado pelo usuário. O comportamento, logs e armazenamento desse servidor dependem da configuração local do próprio usuário.

## Distribuição

Este projeto não possui, no momento, distribuição oficial em loja. Caso o app seja distribuído futuramente, esta política deverá ser revisada.
