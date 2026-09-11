# Round Table Chronicles

Beat 'em up medieval 2D original para Android, inspirado na jogabilidade de
brawlers clássicos 16-bit. Diferencial: sistema de **evolução visual de
armadura e arma** em 5 estágios, comprados com moedas coletadas nas fases.

> Ambientação baseada livremente nas lendas do Rei Arthur (domínio público).
> Nenhum nome, personagem, arte ou música de jogos comerciais foi reutilizado.

## O que já está pronto neste esqueleto

- Projeto Godot 4.3 configurado (`project.godot`) com orientação landscape
  para Android e autoloads já registrados.
- **`GameManager.gd`** — vida, moedas, progresso de fase (autoload).
- **`UpgradeSystem.gd`** — os 5 estágios de armadura e 5 de arma, com custo,
  bônus de defesa/dano e sinais para atualizar o visual (autoload).
- **`Player.gd`** — movimento, combo de ataque, bloqueio, golpe especial e
  aplicação automática do visual do upgrade atual.
- **`Enemy.gd`** / **`Boss.gd`** — IA simples de perseguição/ataque, chefe
  com modo "enfurecido" abaixo de 50% de vida.
- **`HUD.gd`** / **`Forge.gd`** — barra de vida, moedas e tela de forja para
  comprar upgrades.
- Cenas (`.tscn`) já ligando os scripts aos nós esperados, com placeholders
  visuais em `ColorRect` (retângulos coloridos) no lugar dos sprites finais.
- Workflow do GitHub Actions (`.github/workflows/build-apk.yml`) pronto para
  gerar o `.apk` automaticamente a cada push.

## O que falta para virar um jogo "de verdade"

Isso é um **esqueleto funcional de arquitetura**, não um jogo finalizado.
Como os sprites de armadura/arma pixel art originais não podem ser gerados
automaticamente aqui (para evitar qualquer semelhança acidental com arte
protegida), os personagens usam retângulos coloridos como placeholder. Antes
de lançar, você (ou um artista) precisa:

1. Abrir o projeto no **Godot 4.3 ou superior**.
2. Verificar o **Input Map** em `Project > Project Settings > Input Map` —
   as ações `move_left/right/up/down` já vêm configuradas para WASD e setas,
   mas vale conferir visualmente no editor.
3. Substituir os `ColorRect` de `BodySprite`/`WeaponSprite` por
   `AnimatedSprite2D` com a arte real de cada um dos 5 estágios. No código,
   isso é uma troca pequena: em `apply_visual_upgrades()` (dentro de
   `Player.gd`), troque `body_sprite.color = armor["color"]` por algo como
   `body_sprite.play(armor["animation_name"])`.
4. Adicionar um **joystick virtual de toque** para mobile (a Asset Library
   do Godot tem plugins prontos, ex: "Virtual Joystick") — os botões de
   Atacar/Especial/Bloquear já estão na HUD e funcionam por toque.
5. Criar as fases reais (hoje só existe uma `Main.tscn` de teste com 3
   inimigos) e ligar `GameManager.complete_stage()` à transição de fase.
6. Adicionar música e efeitos sonoros originais ou licenciados livremente.

## Como rodar localmente

1. Baixe o [Godot 4.3+](https://godotengine.org/download) (versão Standard).
2. Abra a pasta do projeto pelo Godot (`project.godot`).
3. Pressione **F5** para rodar a cena principal.

## Como o build automático do APK funciona

O workflow `.github/workflows/build-apk.yml` roda a cada push na branch
`main` (ou manualmente pela aba **Actions** do GitHub) e usa a action
[`mlm-games/godot-build-action`](https://github.com/mlm-games/godot-build-action)
para:

1. Baixar o Godot e os templates de exportação automaticamente.
2. Exportar o projeto usando o preset `"Android arm64"` definido em
   `export_presets.cfg`.
3. Publicar o `.apk` gerado como **artifact do workflow** — para baixar,
   entre na aba **Actions** do repositório, abra a execução mais recente e
   baixe `round-table-chronicles-apk` na seção "Artifacts".

Por padrão o build é de **debug** (`DEBUG_MODE: "true"`), então não exige
nenhuma configuração extra de assinatura — ótimo para testar no celular.

### Build de release (assinado)

Para gerar um APK assinado (necessário para publicar na Play Store):

1. Gere um keystore local: `keytool -genkey -v -keystore release.keystore -alias round-table -keyalg RSA -keysize 2048 -validity 10000`
2. Converta para base64: `base64 -i release.keystore -o release.keystore.b64`
3. No GitHub, vá em **Settings > Secrets and variables > Actions** e crie:
   - `RELEASE_KEYSTORE` (conteúdo do `.b64`)
   - `KEYSTORE_PASSPHRASE`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`
4. No workflow, mude `DEBUG_MODE` para `"false"` e adicione os inputs
   `RELEASE_KEYSTORE`, `KEYSTORE_PASSPHRASE`, `KEY_ALIAS` e `KEY_PASSWORD`
   apontando para os secrets criados (`${{ secrets.NOME_DO_SECRET }}`).

## Estrutura de pastas

```
knights-game/
  project.godot
  export_presets.cfg
  icon.svg
  .github/workflows/build-apk.yml
  scenes/
    Main.tscn        # cena de teste com jogador + 3 inimigos
    Player.tscn
    Enemy.tscn
    Boss.tscn
    HUD.tscn
    Forge.tscn        # tela de compra de upgrades
  scripts/
    autoload/
      GameManager.gd
      UpgradeSystem.gd  # <- coração do sistema de upgrades visuais
    Player.gd
    Enemy.gd
    Boss.gd
    HUD.gd
    Forge.gd
```
