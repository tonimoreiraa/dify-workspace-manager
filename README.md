# Dify Tenant Manager

Script automatizado para criação de novos tenants (workspaces) em instalações self-hosted do Dify AI.

## 📋 Descrição

Este script Bash automatiza o processo de criação de novos tenants no Dify, incluindo:
- Criação do tenant no banco de dados PostgreSQL
- Associação automática de conta owner
- Replicação de chaves privadas de criptografia
- Validação e feedback visual do processo

## 🚀 Funcionalidades

- ✅ Criação automatizada de tenants
- ✅ Associação de conta owner configurável
- ✅ Cópia de chaves de criptografia do tenant principal
- ✅ Validação de cada etapa do processo
- ✅ Output colorido e informativo
- ✅ Tratamento de erros robusto

## 📦 Pré-requisitos

- Docker instalado e em execução
- Container PostgreSQL do Dify (`docker-db_postgres-1`)
- Container API do Dify (`docker-api-1`)
- Acesso ao banco de dados `dify`
- Usuário PostgreSQL: `postgres`

## 🔧 Configuração

Antes de executar, edite o script e configure:
```bash
