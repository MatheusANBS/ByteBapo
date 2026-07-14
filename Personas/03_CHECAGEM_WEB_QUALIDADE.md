# Checagem Web de Qualidade — v3

Esta versão revisa todos os 29 prompts para reduzir trechos genéricos e reforçar fidelidade de personagem. A revisão priorizou páginas oficiais quando disponíveis e complementou lacunas com páginas enciclopédicas de referência quando as páginas oficiais não traziam ficha completa.

## Fontes principais por grupo

- **One Piece:** páginas oficiais de personagens em `https://one-piece.com/character/...` para Luffy, Zoro, Nami, Robin, Sanji, Chopper, Franky, Usopp e Brook.
- **Naruto:** site oficial `https://naruto-official.com/en` para contexto da franquia; Narutopedia/Wikipedia para detalhes de Tsunade e Hinata.
- **Bleach:** site oficial `https://bleach-anime.com/` para contexto atual da franquia; Bleach Wiki/Wikipedia para detalhes de Rukia e Yoruichi.
- **Chainsaw Man:** portal oficial `https://chainsawman.dog/` para contexto da adaptação; Chainsaw Man Wiki/Wikipedia para detalhes de Makima e Power.
- **Frieren:** site oficial `https://frieren-anime.jp/` e páginas enciclopédicas para confirmar núcleo de Frieren.
- **Violet Evergarden:** páginas oficiais do anime/livros da Kyoto Animation quando disponíveis e páginas enciclopédicas para sinopse e relações.
- **Fate / Steins;Gate / Ghost in the Shell / Madoka / Attack on Titan / Fullmetal Alchemist / Kaguya-sama / Sailor Moon / Cowboy Bebop / KonoSuba / Evangelion:** fontes oficiais de obra quando disponíveis e páginas enciclopédicas/fandom para fichas de personagem, trajetória e nuances de voz.

## O que foi melhorado

1. Cada arquivo recebeu a seção **Checagem de fidelidade por pesquisa**.
2. A seção **Quando o usuário pedir conselho** foi personalizada por personagem.
3. O catálogo JSON recebeu marcação `research_status: checado_web_v3`.
4. As notas de referência foram atualizadas com a metodologia de validação.
5. O arquivo agregado `TODOS_OS_PROMPTS.md` foi regenerado com os prompts revisados.

## Resumo por personagem

| Nº | Personagem | Pontos reforçados |
|---:|---|---|
| 01 | Violet Evergarden | ex-soldada que trabalha na Companhia Postal CH como Auto Memory Doll, escrevendo cartas para traduzir sentimentos que outros não conseguem expressar. |
| 02 | Saber / Artoria Pendragon | Servant da classe Saber e versão feminina do Rei Arthur, ligada a Caliburn/Excalibur, Camelot, dever real e Guerra do Santo Graal. |
| 03 | Makise Kurisu | neurocientista prodígio ligada ao Future Gadget Laboratory, peça central da investigação sobre linhas de mundo, D-mails e viagem temporal em Akihabara. |
| 04 | Motoko Kusanagi | Major cyborg da Seção 9 de Segurança Pública, especialista em operações táticas, hacking, investigação cibernética e dilemas de identidade. |
| 05 | Rei Ayanami | Primeira Criança e piloto da Unidade Eva-00, figura enigmática ligada à NERV, Gendo Ikari, clones e temas de identidade substituível. |
| 06 | Asuka Langley Soryu / Shikinami | piloto prodígio da Unidade Eva-02, em versões Soryu/Shikinami conforme a continuidade escolhida, marcada por orgulho, performance e medo de rejeição. |
| 07 | Homura Akemi | garota mágica ligada a Madoka, loops temporais, escudo, armas, desejo de proteção e revelações sobre o destino das magical girls. |
| 08 | Mikasa Ackerman | soldado de elite do Corpo de Exploração, Ackerman, ligada à proteção de Eren, à guerra contra titãs e à perda constante. |
| 09 | Riza Hawkeye | tenente de Amestris, atiradora de elite e braço moral de Roy Mustang, marcada pela guerra de Ishval e pela responsabilidade militar. |
| 10 | Nico Robin | arqueóloga dos Chapéus de Palha, sobrevivente de Ohara, leitora de Poneglyphs e buscadora do Rio Poneglyph/história verdadeira. |
| 11 | Nami | navegadora e cartógrafa dos Chapéus de Palha, sobrevivente de Arlong Park, especialista em clima, mapas e dinheiro. |
| 12 | Yoruichi Shihouin | ex-capitã da 2ª Divisão, ex-comandante da Onmitsukidō, antiga nobre Shihōin, mestre de Shunpo e aliada de Urahara. |
| 13 | Rukia Kuchiki | shinigami da Soul Society, ligada ao clã Kuchiki, a Ichigo e ao dever de purificar Hollows, com humor seco e senso de honra. |
| 14 | Tsunade Senju | Sannin lendária, Quinta Hokage de Konoha, médica-ninja excepcional, usuária de força monstruosa e invocadora de Katsuyu. |
| 15 | Hinata Hyuga | kunoichi do clã Hyūga, usuária do Byakugan e Punho Gentil, marcada por timidez, rejeição familiar e coragem silenciosa. |
| 16 | Makima | oficial da Segurança Pública e figura associada ao controle, manipulação, contratos e desejo distorcido de conexão. |
| 17 | Power | Fiend do Sangue da Segurança Pública, caótica, egoísta, mentirosa e ligada a Denji, Aki e ao gato Meowy/Nyako. |
| 18 | Kaguya Shinomiya | vice-presidente do conselho estudantil da Academia Shuchiin, herdeira da família Shinomiya e protagonista de guerra psicológica romântica com Miyuki. |
| 19 | Usagi Tsukino / Sailor Moon | Usagi Tsukino, Sailor Moon, guardiã do amor e da justiça, reencarnação lunar e líder emocional das Sailor Guardians. |
| 20 | Faye Valentine | caçadora de recompensas da Bebop, ligada a dívidas, criossono, amnésia e solidão noir espacial. |
| 21 | Frieren | elfa maga milenar, antiga integrante do grupo que derrotou o Rei Demônio, viajante com Fern e Stark em busca de entender vínculos humanos. |
| 22 | Megumin | arquimaga dos Demônios Carmesim em KonoSuba, obcecada por magia de Explosão e integrante do grupo de Kazuma. |
| 23 | Monkey D. Luffy | capitão dos Chapéus de Palha, usuário da Gomu Gomu/Hito Hito modelo Nika, membro da Pior Geração e candidato a Rei dos Piratas. |
| 24 | Roronoa Zoro | primeiro companheiro de Luffy, combatente dos Chapéus de Palha, espadachim de três espadas e aspirante a maior espadachim do mundo. |
| 25 | Sanji | cozinheiro dos Chapéus de Palha, lutador de chutes, cavalheiro e sobrevivente de fome/abandono, ligado ao Baratie e à família Vinsmoke. |
| 26 | Tony Tony Chopper | médico dos Chapéus de Palha, rena que comeu a Hito Hito no Mi, discípulo de Hiriluk/Kureha e sonhador de virar “panaceia”. |
| 27 | Franky | carpinteiro naval dos Chapéus de Palha, cyborg, construtor do Thousand Sunny e discípulo de Tom em Water 7. |
| 28 | Usopp | atirador dos Chapéus de Palha, contador de histórias de Syrup Village, Sogeking/God Usopp e aspirante a bravo guerreiro do mar. |
| 29 | Brook | músico dos Chapéus de Palha, esqueleto vivo pela Yomi Yomi no Mi, antigo Rumbar Pirate e guardião da promessa com Laboon. |


## Complemento v4

A v4 não altera a checagem de fidelidade narrativa da v3. A mudança principal é estrutural: inclusão do prompt global de formatação para role-play literário e atualização dos arquivos de navegação para orientar o uso conjunto com os prompts individuais.
