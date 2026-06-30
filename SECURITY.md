# Política de Segurança

## Escopo

O BytePapo é um cliente Android para uso local/LAN com servidores Ollama. Ele não fornece servidor próprio, autenticação, proxy seguro ou camada de exposição pública.

## Recomendações de uso seguro

- Use o app apenas em redes confiáveis.
- Não exponha a porta `11434` do Ollama diretamente na internet.
- Não use `localhost` no celular para acessar o Ollama rodando no computador; use o IP local da máquina.
- Evite redes públicas ou desconhecidas.
- Caso precise acessar fora da LAN, use uma camada segura, como VPN, túnel autenticado, proxy com HTTPS ou solução equivalente.
- Revise permissões e configurações de cleartext traffic antes de qualquer distribuição pública.
- Não coloque tokens, senhas, IPs sensíveis ou dados privados em issues públicas.

## Reportando vulnerabilidades

Caso encontre uma vulnerabilidade, evite abrir uma issue pública com detalhes exploráveis.

Envie um contato privado para o mantenedor:

- GitHub: `@MatheusANBS`

Inclua, quando possível:

- descrição do problema;
- passos para reproduzir;
- impacto potencial;
- versão/commit testado;
- evidências, logs ou screenshots sem dados sensíveis.

## Aviso

Este projeto é fornecido como está, sem garantias. O usuário é responsável por proteger sua rede, seu servidor Ollama e seus dados locais.
