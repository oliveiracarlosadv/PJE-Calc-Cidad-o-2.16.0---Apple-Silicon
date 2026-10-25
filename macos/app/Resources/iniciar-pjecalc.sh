#!/bin/bash
# Inicia o PJe-Calc Cidadão no macOS (Intel e Apple Silicon).
# Faz o mesmo que o iniciarPjeCalc.bat do Windows, com os mesmos parâmetros Java.
# É chamado pelo ícone PJe (Contents/MacOS/PJeCalc), que liga e desliga o sistema.
VERSAO="2.16.0"
RES="$(cd "$(dirname "$0")" && pwd)"

# Escolhe o Java certo para o processador
if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ]; then
  JAVA="$RES/jre-arm64/bin/java"
else
  JAVA="$RES/jre-x64/bin/java"
fi

# Como no Windows, o programa roda de uma pasta do usuário (banco de dados gravável).
# A pasta é criada uma única vez; os dados existentes nunca são sobrescritos.
DEST="$HOME/PJe-Calc/pjecalc-$VERSAO"
if [ ! -f "$DEST/bin/pjecalc.jar" ]; then
  mkdir -p "$DEST" && /usr/bin/ditto "$RES/pjecalc" "$DEST" || {
    /usr/bin/osascript -e 'display alert "PJe-Calc Cidadão" message "Não foi possível criar a pasta '"$DEST"'." as critical'
    exit 1
  }
fi
cd "$DEST" || exit 1

# O comando "open" que o PJe-Calc usa para abrir o navegador passa a abrir a janela no Chrome/Safari.
# Fica na pasta do usuário porque o Java (com ISO-8859-1) não aceita acentos no caminho.
mkdir -p "$DEST/.mac-bin" && /bin/cp -f "$RES/mac-bin/open" "$RES/mac-bin/janela-pjecalc" "$DEST/.mac-bin/" && /bin/chmod 755 "$DEST/.mac-bin/"*
export PATH="$DEST/.mac-bin:/usr/bin:/bin:/usr/sbin:/sbin"

# apple.awt.UIElement: o Java não cria um segundo ícone no Dock (o ícone é o PJe).
exec "$JAVA" -Dapple.awt.UIElement=true \
  -splash:pjecalc_splash.gif -Duser.timezone=GMT-3 -Dfile.encoding=ISO-8859-1 \
  -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe \
  -Dseguranca.pjekz.servico.contexto="https://pje.trtXX.jus.br/pje-seguranca" \
  -Xms1024m -Xmx2048m -XX:MaxPermSize=512m -jar bin/pjecalc.jar >> "$DEST/pjecalc.log" 2>&1
