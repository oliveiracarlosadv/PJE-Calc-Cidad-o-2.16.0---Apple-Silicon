# PJe-Calc Cidadão 2.16.0 para macOS

<img src="macos/app/Resources/pje-dock.png" alt="Ícone PJe" width="96" align="right">

Instalador do **PJe-Calc Cidadão 2.16.0** para Mac, nos dois tipos de processador:

- **Apple Silicon** (M1, M2, M3, M4…)
- **Intel**

A instalação é no estilo "Continuar, Instalar, Fechar" e não exige Terminal nem Java instalado. O sistema funciona exatamente como no Windows: os arquivos do PJe-Calc (`pjecalc.jar`, Tomcat, aplicação web e banco de dados) são os originais do instalador oficial, sem nenhuma alteração.

> Projeto independente e **não oficial**. O PJe-Calc Cidadão é desenvolvido e distribuído pela Justiça do Trabalho (TRT da 8ª Região / CSJT). Veja o [aviso legal](#aviso-legal).

## Download

Baixe o arquivo **`pjecalc-2.16.0-instalador-mac.pkg`** na página de [Releases](../../releases/latest).

## Requisitos

| | |
|---|---|
| Sistema | macOS 10.15 (Catalina) ou mais novo |
| Processador | Apple Silicon ou Intel (o mesmo instalador serve para os dois) |
| Navegador | Google Chrome (recomendado) ou Safari |
| Espaço em disco | cerca de 800 MB |
| Java | **não precisa**: o Java 8 já vem dentro do aplicativo |

## Instalação

1. Dê dois cliques em `pjecalc-2.16.0-instalador-mac.pkg`.
2. Se o Mac disser que o instalador "não pode ser aberto porque é de um desenvolvedor não identificado":
   - clique com o **botão direito** no arquivo e escolha **Abrir**; ou
   - vá em **Ajustes do Sistema → Privacidade e Segurança** e clique em **Abrir Mesmo Assim**.

   Isso acontece porque o instalador não tem assinatura paga da Apple. É necessário só na primeira vez.
3. Clique em **Continuar**, depois em **Instalar**, e digite a senha do Mac quando for pedida.
4. Ao final, o aplicativo **PJe-Calc Cidadão 2.16.0** estará em **Aplicativos** e o ícone **PJe** estará no Dock.

## Como usar

### Ligar e desligar pelo ícone PJe

O ícone **PJe** no Dock funciona como um interruptor:

| Situação | O que acontece ao clicar no ícone |
|---|---|
| PJe-Calc desligado | Liga o sistema e abre a janela do PJe-Calc |
| PJe-Calc ligado | Pergunta se deseja **Desligar**, **Mostrar janela** ou **Cancelar** |

Ao desligar, o servidor do PJe-Calc é encerrado com segurança (o banco de dados é fechado corretamente) e a janela do sistema no navegador também é fechada.

Também dá para usar o **botão direito** no ícone do Dock:

- **Mostrar janela do PJe-Calc**: traz a janela para a frente.
- **Desligar o PJe-Calc**: desliga o sistema.
- **Encerrar**: também desliga.

### A janela do sistema

- O PJe-Calc abre numa **janela própria do Google Chrome**, sem barra de endereço, dentro do Chrome que você já usa. Não é aberta uma nova instância do Chrome.
- Se a janela já estiver aberta, o sistema só a traz para a frente, sem duplicar.
- Se o Chrome não estiver instalado, o sistema abre numa janela do **Safari**.
- Na primeira vez, o macOS pergunta se o **PJe-Calc Cidadão** pode controlar o Google Chrome (ou o Safari). Clique em **Permitir**: é isso que permite fechar a janela ao desligar.

### Ícone na barra de menus

Com o sistema ligado, aparece também o ícone do próprio PJe-Calc na barra de menus (no alto da tela), com as opções originais:

- **Iniciar Projetos**: abre a janela.
- **Sair**: desliga tudo. O ícone do Dock também apaga.

## Onde ficam os seus cálculos

Como no Windows, cada versão tem sua própria pasta, com o banco de dados:

```
~/PJe-Calc/pjecalc-2.16.0/
```

(`~` é a sua pasta pessoal; no Finder, use **Ir → Pasta Pessoal**.)

- A pasta é criada na primeira vez que o sistema é ligado.
- **Reinstalar ou atualizar o aplicativo não apaga os seus cálculos.**
- Para backup, use a exportação de cálculos do próprio PJe-Calc, como no Windows.
- Após a primeira instalação, **atualize as Tabelas Auxiliares**, como orienta o TRT8.

## Desinstalar

1. Desligue o PJe-Calc (ícone PJe → **Desligar**).
2. Exporte seus cálculos, se quiser guardá-los.
3. Arraste **PJe-Calc Cidadão 2.16.0** de **Aplicativos** para o Lixo.
4. Remova o ícone do Dock: botão direito no ícone → **Opções → Remover do Dock**.
5. Se não for mais usar os cálculos, apague a pasta `~/PJe-Calc/pjecalc-2.16.0`.

## Problemas comuns

| Problema | Solução |
|---|---|
| "Desenvolvedor não identificado" ao abrir o instalador | Botão direito no arquivo → **Abrir** (veja [Instalação](#instalação)) |
| A janela não fecha ao desligar | Permita o controle do navegador em **Ajustes do Sistema → Privacidade e Segurança → Automação → PJe-Calc Cidadão** |
| Mensagem "O PJe-Calc Cidadão aberto da última vez não foi encerrado completamente" | Outro PJe-Calc está usando a porta 9257. Desligue-o pelo ícone PJe ou pelo ícone na barra de menus e ligue de novo |
| Quero ver o registro (log) do sistema | Arquivo `~/PJe-Calc/pjecalc-2.16.0/pjecalc.log` |

## Documentação técnica

- [Como funciona](docs/como-funciona.md): o que foi feito para o PJe-Calc rodar no Mac sem mudar o código.
- [Como gerar o instalador](docs/como-gerar-o-instalador.md): passo a passo para recriar o `.pkg` a partir do instalador oficial do Windows.
- [Versões anteriores](docs/versoes-anteriores.md): documentação das releases antigas deste repositório.

## Linux

Uma versão para Linux está planejada, no mesmo esquema da versão para Mac.

## Aviso legal

- O **PJe-Calc Cidadão** é software da Justiça do Trabalho (TRT da 8ª Região / CSJT). Este repositório não é oficial e não tem vínculo com o TRT8, o CSJT ou o CNJ.
- Os arquivos do PJe-Calc incluídos no instalador são os do instalador oficial para Windows, versão 2.16.0, sem modificações. O download oficial está na [página do PJe-Calc Cidadão no TRT8](https://www.trt8.jus.br/pjecalc-cidadao/instalando-o-pje-calc-cidadao).
- O Java incluído é o [Azul Zulu 8](https://www.azul.com/downloads/?version=java-8-lts&package=jre-fx) (OpenJDK com JavaFX), distribuído sob a licença GPLv2 com Classpath Exception.
- Use por sua conta e risco. Confira os resultados dos cálculos como faria com qualquer instalação do PJe-Calc.

## Licença

Este repositório **não tem licença de código aberto**. Os scripts e a documentação são de Carlos Alexandre Albuquerque Oliveira, com todos os direitos reservados: você pode consultar e usar para instalar o PJe-Calc no seu próprio Mac, mas não pode redistribuir nem republicar sem autorização.

O PJe-Calc Cidadão é software da Justiça do Trabalho (CSJT) e continua sujeito às regras dos seus titulares.
