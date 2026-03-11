Windows & Office Migration Suite (MGI Project)

Este repositório contém ferramentas de automação desenvolvidas para otimizar o processo de migração de locatários (tenants) Microsoft 365 e desvinculação de dispositivos Azure AD.

Destaques das Melhorias (v2.0)Segurança Operacional: 
Implementação de travas de confirmação (Double-Check) e palavras-chave para evitar execuções acidentais em comandos críticos (dsregcmd /leave). 

Robustez: Encerramento forçado de processos (taskkill) para evitar erros de arquivo em uso e validação de existência de diretórios. 

UX & Observabilidade: Interface colorida em PowerShell para facilitar a leitura do técnico e sistema de logs detalhados. 

Eficiência (Anti-Loop): Uso de Flags (marcadores) no sistema de arquivos para impedir que scripts disparados via GPO rodem repetidamente sem necessidade. 

Ferramentas IncluídasLimpeza de Cache (Batch): 
Remove tokens de login (OneAuth/IdentityCache) e reseta pacotes de autenticação do Windows. 

Desvinculação Azure AD (PowerShell): 
Automação do comando de saída de domínio com tratamento de exceções try/catch. 
