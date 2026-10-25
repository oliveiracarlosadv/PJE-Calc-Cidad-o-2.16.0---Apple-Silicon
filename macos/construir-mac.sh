#!/bin/bash
# Gera o instalador .pkg do PJe-Calc Cidadão para macOS (Intel + Apple Silicon)
# a partir do instalador oficial do Windows (pjecalc-<versão>-instalador-x64.exe).
#
# Uso:  ./construir-mac.sh caminho/para/pjecalc-2.16.0-instalador-x64.exe [pasta-de-saida]
#
# Requisitos: macOS com Xcode Command Line Tools (swiftc, pkgbuild, productbuild)
#             e 7-Zip (brew install sevenzip).
set -euo pipefail

EXE="${1:?Informe o caminho do instalador .exe do Windows}"
SAIDA="${2:-$PWD}"
VERSAO="2.16.0"
APP_NOME="PJe-Calc Cidadao $VERSAO.app"   # sem acento: o Java com ISO-8859-1 não funciona em pastas com acento
ZULU="zulu8.96.0.205-ca-fx-jre8.0.504"     # Java 8 com JavaFX (equivalente ao Oracle 8 do Windows)

AQUI="$(cd "$(dirname "$0")" && pwd)"
TRAB="$(mktemp -d -t pjecalc-build)"
trap 'rm -rf "${TRAB:?}"' EXIT

for f in 7zz swiftc pkgbuild productbuild curl shasum; do
  command -v "$f" >/dev/null || { echo "Falta o programa: $f"; exit 1; }
done

echo "==> Extraindo o instalador do Windows"
# Copia para uma pasta local e testa antes de extrair (pastas sincronizadas, como Google Drive,
# podem entregar o arquivo ainda incompleto).
cp "$EXE" "$TRAB/instalador.exe"
7zz t "$TRAB/instalador.exe" >/dev/null || { echo "O arquivo .exe está corrompido ou incompleto."; exit 1; }
7zz x -y -o"$TRAB/win" "$TRAB/instalador.exe" >/dev/null
WIN="$TRAB/win/pjecalc-windows64-$VERSAO"
[ -f "$WIN/bin/pjecalc.jar" ] || { echo "Não encontrei $WIN/bin/pjecalc.jar"; exit 1; }

# Checksum SHA-256 oficial de um pacote da Azul (consulta a API de metadados)
sha256_azul() {
  local nome="$1" arch="$2" uuid
  uuid="$(curl -fsSL "https://api.azul.com/metadata/v1/zulu/packages/?java_version=8&os=macos&arch=$arch&archive_type=tar.gz&java_package_type=jre&javafx_bundled=true&page_size=200" \
    | python3 -c "import sys,json;n=sys.argv[1];print(next(p['package_uuid'] for p in json.load(sys.stdin) if p['name']==n))" "$nome")"
  curl -fsSL "https://api.azul.com/metadata/v1/zulu/packages/$uuid" | python3 -c "import sys,json;print(json.load(sys.stdin)['sha256_hash'])"
}

echo "==> Baixando o Java 8 (Azul Zulu) para Intel e Apple Silicon"
for par in macosx_aarch64:arm64 macosx_x64:x64; do
  plat="${par%%:*}"; arq="${par##*:}"
  nome="$ZULU-$plat.tar.gz"
  curl -fsSL -o "$TRAB/$nome" "https://cdn.azul.com/zulu/bin/$nome"
  esperado="$(sha256_azul "$nome" "${plat#macosx_}")"
  obtido="$(shasum -a 256 "$TRAB/$nome" | cut -d' ' -f1)"
  [ "$esperado" = "$obtido" ] || { echo "Checksum inválido para $nome"; exit 1; }
  mkdir -p "$TRAB/jre-$arq"; tar -xzf "$TRAB/$nome" -C "$TRAB/jre-$arq"
done

echo "==> Montando o aplicativo"
ROOT="$TRAB/root"; C="$ROOT/$APP_NOME/Contents"; R="$C/Resources"
mkdir -p "$C/MacOS" "$R/mac-bin"
cp "$AQUI/app/Info.plist" "$C/Info.plist"
for l in pt_BR pt-BR en; do mkdir -p "$R/$l.lproj"; cp "$AQUI/app/lproj/InfoPlist.strings" "$R/$l.lproj/"; done
cp "$AQUI/app/Resources/iniciar-pjecalc.sh" "$AQUI/app/Resources/PJe.icns" "$AQUI/app/Resources/pje-dock.png" "$R/"
cp "$AQUI/app/Resources/mac-bin/"* "$R/mac-bin/"
chmod 755 "$R/iniciar-pjecalc.sh" "$R/mac-bin/"*

# Programa original (sem o Java e o Firefox do Windows e sem os .bat); nada dentro dele é alterado
mkdir -p "$R/pjecalc"
rsync -a --exclude bin/jre --exclude navegador --exclude '*.bat' "$WIN/" "$R/pjecalc/"
mkdir -p "$R/pjecalc/navegador/mac"
cp -R "$AQUI/navegador-stub/FirefoxPortable.app" "$R/pjecalc/navegador/mac/"
chmod 755 "$R/pjecalc/navegador/mac/FirefoxPortable.app/Contents/MacOS/QtWeb"

for arq in arm64 x64; do
  ditto "$(find "$TRAB/jre-$arq" -maxdepth 4 -type d -name Home | head -1)" "$R/jre-$arq"
done

echo "==> Compilando o controlador do ícone (universal)"
for t in arm64 x86_64; do
  swiftc -O -runtime-compatibility-version none -target "$t-apple-macos10.15" \
    "$AQUI/controlador/main.swift" -o "$TRAB/PJeCalc-$t"
done
lipo -create "$TRAB/PJeCalc-arm64" "$TRAB/PJeCalc-x86_64" -output "$C/MacOS/PJeCalc"

echo "==> Gerando o instalador .pkg"
pkgbuild --analyze --root "$ROOT" "$TRAB/comp.plist" >/dev/null
/usr/libexec/PlistBuddy -c "Set :0:BundleIsRelocatable false" "$TRAB/comp.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :0:BundleIsRelocatable bool false" "$TRAB/comp.plist"
/usr/libexec/PlistBuddy -c "Set :0:BundleIsVersionChecked false" "$TRAB/comp.plist"
/usr/libexec/PlistBuddy -c "Set :0:BundleOverwriteAction upgrade" "$TRAB/comp.plist"
mkdir -p "$TRAB/scripts"; cp "$AQUI/instalador/scripts/postinstall" "$TRAB/scripts/"; chmod 755 "$TRAB/scripts/postinstall"
pkgbuild --root "$ROOT" --component-plist "$TRAB/comp.plist" --install-location /Applications \
  --scripts "$TRAB/scripts" --identifier br.jus.pjecalc.cidadao.pkg --version 2.16.1 "$TRAB/app.pkg" >/dev/null
mkdir -p "$SAIDA"
productbuild --distribution "$AQUI/instalador/Distribution.xml" --resources "$AQUI/instalador/recursos" \
  --package-path "$TRAB" "$SAIDA/pjecalc-$VERSAO-instalador-mac.pkg" >/dev/null

echo "==> Pronto: $SAIDA/pjecalc-$VERSAO-instalador-mac.pkg"
