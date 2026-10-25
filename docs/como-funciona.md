# Como funciona

Este documento explica como o PJe-Calc Cidadão 2.16.0 do Windows passou a rodar no macOS **sem nenhuma alteração no código do sistema**.

## O que é o PJe-Calc Cidadão por dentro

O instalador oficial do Windows (`pjecalc-2.16.0-instalador-x64.exe`) é um arquivo autoextraível que só descompacta uma pasta e cria um atalho na Área de Trabalho. Dentro dela:

| Item | O que é |
|---|---|
| `bin/pjecalc.jar` | Lançador em Java (classe `br.jus.trt8.pjecalcsa.container.Lancador`) |
| `bin/lib/` | Bibliotecas do Tomcat 7 embutido e do banco H2 |
| `tomcat/` | Servidor web com a aplicação `pjecalc` |
| `.dados/pjecalc.h2.db` | Banco de dados com os cálculos e as tabelas |
| `bin/jre/` | Java 8 da Oracle **para Windows** |
| `navegador/windows/` | Firefox Portable 55 **para Windows** |
| `iniciarPjeCalc.bat` | Script que inicia o sistema |

O `iniciarPjeCalc.bat` roda:

```
javaw -splash:pjecalc_splash.gif -Duser.timezone=GMT-3 -Dfile.encoding=ISO-8859-1
      -Dseguranca.pjecalc.tokenServicos=… -Dseguranca.pjekz.servico.contexto=…
      -Xms1024m -Xmx2048m -XX:MaxPermSize=512m -jar bin\pjecalc.jar
```

O lançador então:

1. sobe o Tomcat na porta **9257** (somente `127.0.0.1`);
2. coloca um ícone na bandeja do sistema (menu **Iniciar Projetos** / **Sair**);
3. abre o navegador em `http://localhost:9257/pjecalc`.

## O lançador já previa Mac e Linux

Ao descompilar o `pjecalc.jar`, a classe `Lancador` mostra que o sistema já foi pensado para os três sistemas. Ela escolhe o navegador assim:

| Sistema | Navegador esperado | Comando executado |
|---|---|---|
| Windows | `navegador/windows/FirefoxPortable.exe` | `FirefoxPortable.exe <URL>` |
| macOS | `navegador/mac/FirefoxPortable.app` | `open <…>/FirefoxPortable.app <URL>` |
| Linux | `navegador/linux/Firefox-45.0.1-x86_64.AppImage` | `<…>.AppImage <URL>` |

No Mac, antes de abrir, o lançador também atualiza a linha `home=` do arquivo `FirefoxPortable.app/Contents/MacOS/QtWebSettings/QtWeb.NET/QtWeb Internet Browser.ini`. Se esse arquivo não existir, ele mostra um erro.

Ou seja: para rodar no Mac basta trocar o que é específico do Windows (o Java e o navegador), mantendo todo o resto.

## O que foi trocado

### 1. Java

O Java 8 da Oracle para Windows foi substituído pelo **Azul Zulu 8 com JavaFX**: o mesmo Java 8, compilado para macOS. O aplicativo leva duas cópias:

- `jre-arm64`: para Apple Silicon;
- `jre-x64`: para Intel.

O script de início escolhe a certa pelo processador (`sysctl hw.optional.arm64`).

Os parâmetros Java são **os mesmos do `iniciarPjeCalc.bat`**. Só foi acrescentado `-Dapple.awt.UIElement=true`, que impede o Java de criar um segundo ícone no Dock (o ícone visível é o PJe). Isso não muda nada no funcionamento do sistema.

### 2. Navegador

O Firefox Portable do Windows não é usado. No lugar dele:

- `navegador/mac/FirefoxPortable.app` é um aplicativo mínimo que existe só para o lançador encontrar o caminho e o arquivo `.ini` que ele espera.
- O comando `open` que o lançador executa é interceptado por um script com o mesmo nome (`mac-bin/open`), colocado antes no `PATH`. Quando o pedido é "abrir o FirefoxPortable.app com a URL do PJe-Calc", o script chama `janela-pjecalc abrir`; qualquer outro uso de `open` segue para o `/usr/bin/open` normal.
- `janela-pjecalc` abre a URL numa janela de aplicativo do Chrome (`--app=`), dentro do Chrome que o usuário já usa. Se a janela já existir, só a traz para a frente. Sem Chrome, usa uma janela do Safari. Com `fechar`, fecha as janelas do PJe-Calc.

### 3. Pasta de trabalho

No Windows, o sistema roda da pasta onde foi extraído, que precisa permitir gravação: ali ficam o banco de dados e os arquivos temporários do Tomcat. No Mac, o aplicativo em `/Applications` é somente leitura. Por isso, na primeira vez que o sistema é ligado, a pasta do programa é copiada para:

```
~/PJe-Calc/pjecalc-2.16.0/
```

O sistema roda a partir dela, como no Windows. Se a pasta já existe, ela **nunca é sobrescrita**: os cálculos ficam preservados ao reinstalar.

### 4. Ícone liga/desliga

`Contents/MacOS/PJeCalc` é um pequeno aplicativo nativo em Swift (`macos/controlador/main.swift`). Ele é o ícone **PJe** do Dock:

| Evento | Ação |
|---|---|
| Aplicativo aberto | Executa `iniciar-pjecalc.sh` (que inicia o Java) |
| Clique no ícone com o sistema ligado | Pergunta: **Desligar** / **Mostrar janela** / **Cancelar** |
| Desligar, Encerrar, Cmd+Q ou logout | Fecha a janela do navegador, envia `SIGTERM` ao Java e espera até 20 s; o Tomcat e o banco H2 fecham pelos próprios ganchos de encerramento |
| O Java terminou sozinho (menu **Sair** do PJe-Calc) | Fecha a janela do navegador e apaga o ícone |
| Porta 9257 já em uso ao abrir | Não inicia outro servidor; só mostra a janela |

## Por que o nome do aplicativo não tem acento

O arquivo se chama `PJe-Calc Cidadao 2.16.0.app`. O nome com acento ("Cidadão") aparece no Finder e no Dock por tradução (`InfoPlist.strings`).

O motivo: o PJe-Calc exige `-Dfile.encoding=ISO-8859-1`. Com essa codificação, o Java 8 converte errado os caminhos com acento ao iniciar processos e não encontra o próprio `jspawnhelper`. Resultado: o comando que abre o navegador falha em silêncio. Mantendo o Java num caminho sem acento, tudo funciona. Pelo mesmo motivo, os scripts `mac-bin` são copiados para `~/PJe-Calc/pjecalc-2.16.0/.mac-bin`, e o `PATH` do Java só contém caminhos sem acento.

## O que NÃO foi alterado

- `pjecalc.jar` e as bibliotecas em `bin/lib`;
- o Tomcat, a aplicação web e as configurações (`tomcat/`);
- o banco de dados inicial (`.dados/pjecalc.h2.db`);
- os parâmetros Java do `iniciarPjeCalc.bat`;
- a porta (9257), o endereço e o comportamento do ícone da bandeja / barra de menus.

## Estrutura do aplicativo instalado

```
/Applications/PJe-Calc Cidadao 2.16.0.app/Contents/
├── Info.plist
├── MacOS/PJeCalc                  controlador do ícone (universal: arm64 + x86_64)
└── Resources/
    ├── iniciar-pjecalc.sh         equivalente ao iniciarPjeCalc.bat
    ├── mac-bin/open               intercepta o "open" do lançador
    ├── mac-bin/janela-pjecalc     abre/foca/fecha a janela no Chrome ou Safari
    ├── jre-arm64/  jre-x64/       Java 8 (Azul Zulu, com JavaFX)
    ├── PJe.icns  pje-dock.png     ícone
    └── pjecalc/                   arquivos originais do PJe-Calc 2.16.0
        └── navegador/mac/FirefoxPortable.app   aplicativo mínimo esperado pelo lançador
```
