# Como gerar o instalador

O script `macos/construir-mac.sh` recria o `pjecalc-2.16.0-instalador-mac.pkg` do zero, a partir do instalador oficial do Windows.

## Requisitos

- Um Mac (Apple Silicon ou Intel).
- Xcode Command Line Tools (fornece `swiftc`, `pkgbuild` e `productbuild`):

  ```bash
  xcode-select --install
  ```

- 7-Zip, para extrair o `.exe`:

  ```bash
  brew install sevenzip
  ```

- Conexão com a internet, para baixar o Java (cerca de 190 MB).
- O instalador oficial `pjecalc-2.16.0-instalador-x64.exe`, baixado da [página do PJe-Calc Cidadão no TRT8](https://www.trt8.jus.br/pjecalc-cidadao/instalando-o-pje-calc-cidadao).

## Passo a passo

```bash
git clone https://github.com/oliveiracarlosadv/PJE-Calc-Cidad-o-2.16.0---Apple-Silicon.git
```

```bash
cd PJE-Calc-Cidad-o-2.16.0---Apple-Silicon/macos
```

```bash
./construir-mac.sh ~/Downloads/pjecalc-2.16.0-instalador-x64.exe ~/Desktop
```

O instalador é gerado em `~/Desktop/pjecalc-2.16.0-instalador-mac.pkg`. Leva poucos minutos.

## O que o script faz

1. Copia o `.exe` para uma pasta temporária, testa a integridade e extrai com o 7-Zip.
2. Baixa o Java 8 da Azul (Zulu com JavaFX) para Apple Silicon e Intel, e confere o checksum SHA-256 oficial de cada arquivo.
3. Monta o `PJe-Calc Cidadao 2.16.0.app`:
   - copia os arquivos originais do PJe-Calc, **sem** `bin/jre` (Java do Windows), **sem** `navegador/` (Firefox do Windows) e **sem** os `.bat`;
   - adiciona `navegador/mac/FirefoxPortable.app` (aplicativo mínimo esperado pelo lançador);
   - adiciona os scripts de `macos/app/Resources` e os dois Java.
4. Compila o controlador do ícone (`macos/controlador/main.swift`) para arm64 e x86_64 e junta os dois num binário universal.
5. Gera o `.pkg` com `pkgbuild` e `productbuild`, usando as telas de `macos/instalador/recursos` e o script `macos/instalador/scripts/postinstall`, que coloca o ícone no Dock.

O `pkgbuild` pode mostrar algumas linhas `write: Permission denied`. Elas não afetam o pacote gerado.

## Estrutura desta pasta

```
macos/
├── construir-mac.sh                 script de build
├── app/
│   ├── Info.plist                   metadados do aplicativo
│   ├── lproj/InfoPlist.strings      nome com acento exibido no Finder e no Dock
│   └── Resources/
│       ├── iniciar-pjecalc.sh       inicia o Java (equivalente ao iniciarPjeCalc.bat)
│       ├── mac-bin/open             intercepta o "open" do lançador
│       ├── mac-bin/janela-pjecalc   abre/foca/fecha a janela no Chrome ou Safari
│       ├── PJe.icns                 ícone do aplicativo
│       └── pje-dock.png             ícone em PNG (1024 px)
├── controlador/main.swift           ícone PJe liga/desliga
├── navegador-stub/FirefoxPortable.app
├── instalador/
│   ├── Distribution.xml             telas e opções do instalador
│   ├── recursos/welcome.html        tela de boas-vindas
│   ├── recursos/conclusion.html     tela de conclusão
│   └── scripts/postinstall          adiciona o ícone ao Dock
└── ferramentas/gerar-icone.swift    gera o ícone "PJe"
```

## Recriar o ícone

```bash
swift macos/ferramentas/gerar-icone.swift pje-1024.png
```

Para gerar o `.icns`, crie uma pasta `PJe.iconset` com as imagens de 16 a 1024 px (`sips -z`) e rode `iconutil -c icns PJe.iconset`.

## Assinatura

O pacote gerado não é assinado. Para distribuir sem o aviso de "desenvolvedor não identificado", é preciso uma conta Apple Developer: assine com um certificado *Developer ID Installer* (`productsign`) e faça a notarização (`xcrun notarytool`).
