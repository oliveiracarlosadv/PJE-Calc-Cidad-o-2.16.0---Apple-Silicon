# PjeCalc Cidadão para macOS

## Versão
**PjeCalc v2.16.0 - Modificado para macOS**

## Sobre

Este repositório contém uma versão modificada do **PjeCalc Cidadão** para funcionar nativamente em computadores Mac (macOS).

O PjeCalc é uma aplicação oficial do **Tribunal Regional do Trabalho (TRT)** para cálculo de parcelas trabalhistas e previdenciárias.

**Repositório Original:** [CNJ - PjeCalc](https://www.cnj.jus.br/)

## Modificações Realizadas

A modificação foi **mínima e não invasiva**. O único objetivo foi criar um executável (`.app`) para macOS que permite iniciar a aplicação com um simples clique duplo, sem necessidade de executar scripts ou comandos pelo Terminal.

### O que foi modificado:

- ✓ Criado aplicativo nativo macOS (`PjeCalc.app`)
- ✓ Script shell que inicia o Tomcat e abre o navegador
- ✓ Adicionado ícone personalizado
- ✓ Configuração de metadados do macOS

### O que NÃO foi modificado:

- ✗ Nenhum arquivo Java ou JAR foi alterado
- ✗ Nenhuma funcionalidade foi removida ou adicionada
- ✗ Nenhum comportamento do aplicativo foi modificado
- ✗ Código fonte original permanece intacto

## Como Usar

### Instalação Inicial (uma única vez)

Abra o Terminal e execute:

```bash
bash ~/Downloads/pjecalc-windows64-2.16.0/INSTALAR.sh
```

Isso vai autorizar o aplicativo no seu Mac.

### Execução

Após instalação, simplesmente **clique duas vezes** em `PjeCalc.app`.

O aplicativo vai:
1. Iniciar o servidor Tomcat automaticamente
2. Aguardar o carregamento (10 segundos)
3. Abrir a página no seu navegador padrão
4. Mostrar uma notificação de inicialização

## Pré-requisitos

- **macOS 10.12+**
- **Java 11 ou superior** instalado

### Instalar Java (se necessário)

**Opção 1 - Homebrew (Recomendado):**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install openjdk@11
```

**Opção 2 - Oracle:**
Acesse: https://www.oracle.com/java/technologies/downloads/

**Opção 3 - OpenJDK:**
Acesse: https://jdk.java.net/

## Compatibilidade

✓ **Mac Intel**  
✓ **Mac Apple Silicon (M1, M2, M3)**

## Arquivos Incluídos
