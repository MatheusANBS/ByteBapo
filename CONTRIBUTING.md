# Contribuindo com o BytePapo

Obrigado por considerar contribuir com o BytePapo.

Este projeto é um cliente Android em Flutter para conversar com servidores Ollama em rede local. O foco atual é manter o app simples, funcional e adequado para uso local/LAN.

## Como contribuir

Você pode contribuir com:

- correções de bugs;
- melhorias de UI/UX;
- melhorias na experiência de chat e streaming;
- ajustes de documentação;
- melhorias no suporte a servidores/modelos Ollama;
- testes unitários e de widget;
- refatorações pequenas e bem justificadas.

## Antes de abrir um Pull Request

Antes de enviar uma alteração, rode:

```powershell
flutter pub get
flutter analyze
flutter test
```

Quando possível, teste também em um dispositivo Android físico.

## Padrão de código

- Mantenha o código simples e legível.
- Evite adicionar dependências sem necessidade clara.
- Prefira nomes descritivos para classes, providers, widgets e métodos.
- Separe lógica de rede, estado e interface quando possível.
- Não inclua credenciais, IPs privados sensíveis ou arquivos gerados pelo build.

## Abrindo issues

Ao reportar um problema, inclua:

- versão do Flutter/Dart;
- dispositivo ou emulador usado;
- versão do Android;
- versão do Ollama;
- modelo testado;
- URL/host usado no app, ocultando dados sensíveis;
- passos para reproduzir;
- comportamento esperado;
- comportamento atual;
- logs relevantes.

## Pull Requests

Um bom PR deve conter:

- descrição clara da mudança;
- motivo da mudança;
- screenshots ou vídeos curtos quando alterar UI;
- referência para issue relacionada, se houver;
- confirmação de que `flutter analyze` e `flutter test` foram executados.

## Escopo do projeto

O BytePapo não tem como objetivo, por enquanto:

- hospedar servidor próprio;
- sincronizar histórico em nuvem;
- expor o Ollama diretamente para internet;
- implementar autenticação completa;
- publicar distribuição oficial em loja.

Esses pontos podem ser discutidos, mas mudanças desse tipo devem ser propostas antes em uma issue.
