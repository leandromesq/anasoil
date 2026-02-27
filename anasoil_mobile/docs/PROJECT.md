### Documento de Contextualização do Projeto: App AnaSoil

**1. Visão Geral do Projeto**
O AnaSoil é um sistema desenvolvido como parte do estágio obrigatório do curso de Ciência da Computação da Universidade Filadélfia. O objetivo central do aplicativo é agilizar e facilitar a tomada de decisões de agricultores e consultores agrícolas. Ele automatiza a interpretação de dados de coleta de solo, um processo que antes era feito de forma lenta e manual utilizando planilhas eletrônicas. O sucesso do projeto será medido pelo aumento do rendimento das culturas e do valor agregado para os produtores.

**2. Atores e Público-Alvo**
O sistema possui dois perfis principais de usuários, que utilizarão o aplicativo de maneira similar, mas com níveis de acesso (governança) diferentes:

**Agricultores:** Responsáveis pelas atividades diárias de plantio, trato e colheita do solo.

**Consultores Agrícolas:** Auxiliam nas decisões estratégicas de produção e possuem a capacidade de visualizar e gerenciar uma carteira com o histórico dos agricultores vinculados a eles.

**3. Funcionalidades e Casos de Uso Principais**
As funcionalidades do AnaSoil foram definidas para atender às necessidades dos usuários, garantindo uma experiência eficiente e intuitiva. As principais funcionalidades incluem:

**Autenticação de Usuário:** O acesso ao aplicativo exige um cadastro prévio e login obrigatório.

**Importação de Documentos:** O sistema deve permitir a importação de arquivos de análise de solo a partir do armazenamento local do dispositivo.

**Suporte a Múltiplos Formatos:** Os arquivos importados podem ser nos formatos PDF ou planilhas (XLSX).

**Geração Automática de Análises:** Após a importação, o app deve processar os dados e gerar relatórios numéricos e representações gráficas claras.

**Consulta de Histórico:** O aplicativo deve apresentar uma linha do tempo (histórico) das análises já realizadas pelo usuário.

**Funcionamento Offline:** O aplicativo deve permitir o uso sem conexão com a internet.

**Sincronização em Nuvem:** Quando conectado à internet, os dados e relatórios gerados devem ser enviados e armazenados em um banco de dados.

**4. Requisitos de Desempenho e Tecnologia**

**Stack Tecnológico:** O desenvolvimento mobile será realizado utilizando a linguagem Dart e o framework Flutter.

**Desempenho de Processamento:** O tempo de processamento, entre a importação do arquivo e a geração da interpretação dos dados, deve ser inferior a 5 segundos.

**Distribuição:** O aplicativo será distribuído via download na PlayStore.

**5. Estrutura e Design da Interface (Diretrizes para o Figma)**
A interface do AnaSoil deve seguir um padrão de design limpo, simples e intuitivo. O fluxo de telas básico deve conter:

**Tela de Login:** Para acesso seguro ao sistema.

**Tela Inicial (Dashboard):** Acesso rápido para iniciar uma nova análise, visualizar o histórico de análises e acessar a galeria de documentos.

**Tela de Resultados:** Apresentação da análise com dados numéricos, gráficos e uma seção com a explicação dos métodos de análise que foram aplicados.

### Protótipo de Telas

![Fluxo de Login](<Fluxo 1 - Login.jpg>)

![Fluxo Principal](<Fluxo 2 - Fluxo Principal.jpg>)
