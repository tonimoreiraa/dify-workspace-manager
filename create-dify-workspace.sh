#!/bin/bash

set -e  # Sair se houver erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
ORIGINAL_TENANT_ID='INSIRA O ID DO WORKSPACE PRINCIPAL'


echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Script de Criação de Tenant - Dify${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Solicitar nome do cliente
read -p "Digite o nome do cliente: " CLIENTE_NOME

if [ -z "$CLIENTE_NOME" ]; then
    echo -e "${RED}Erro: Nome do cliente não pode estar vazio!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Criando tenant para: ${CLIENTE_NOME}${NC}"
echo ""

# 1. Inserir novo tenant e capturar o ID
echo -e "${YELLOW}[1/3] Inserindo novo tenant no banco de dados...${NC}"

TENANT_ID=$(docker exec -i docker-db_postgres-1 psql -U postgres dify -t -A -c "
INSERT INTO tenants (name, encrypt_public_key, plan, status, created_at, updated_at)
SELECT
    '$CLIENTE_NOME',
    encrypt_public_key,
    'basic',
    'normal',
    current_timestamp,
    current_timestamp
FROM tenants
LIMIT 1
RETURNING id;
" | grep -E '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' | head -n 1)

if [ -z "$TENANT_ID" ]; then
    echo -e "${RED}Erro: Falha ao criar tenant!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Tenant criado com sucesso! ID: ${TENANT_ID}${NC}"
echo ""

# 2. Associar conta ao tenant
echo -e "${YELLOW}[2/3] Associando conta toni@dpibrasil.com ao tenant...${NC}"

RESULT=$(docker exec -i docker-db_postgres-1 psql -U postgres dify -t -A -c "
INSERT INTO tenant_account_joins (tenant_id, account_id, role, created_at, updated_at)
SELECT
    '$TENANT_ID',
    id,
    'owner',
    current_timestamp,
    current_timestamp
FROM accounts
WHERE email = 'toni@dpibrasil.com'
RETURNING tenant_id;
" | grep -E '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' | head -n 1)

if [ -z "$RESULT" ]; then
    echo -e "${RED}Erro: Falha ao associar conta ao tenant!${NC}"
    echo -e "${YELLOW}Verifique se o email 'toni@dpibrasil.com' existe na tabela accounts.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Conta associada com sucesso!${NC}"
echo ""

# 3. Copiar chaves privadas
echo -e "${YELLOW}[3/3] Copiando chaves privadas...${NC}"

docker exec -i docker-api-1 /bin/bash -c "
if [ -d '/app/api/storage/privkeys/${ORIGINAL_TENANT_ID}' ]; then
    cp -R /app/api/storage/privkeys/${ORIGINAL_TENANT_ID} /app/api/storage/privkeys/$TENANT_ID
    echo 'Chaves copiadas com sucesso'
else
    echo 'ERRO: Diretório de origem não encontrado'
    exit 1
fi
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Chaves privadas copiadas com sucesso!${NC}"
else
    echo -e "${RED}Erro: Falha ao copiar chaves privadas!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Tenant criado com sucesso!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Nome do Cliente: ${GREEN}${CLIENTE_NOME}${NC}"
echo -e "Tenant ID: ${GREEN}${TENANT_ID}${NC}"
echo -e "Email Owner: ${GREEN}toni@dpibrasil.com${NC}"
echo ""
echo -e "${YELLOW}Nota: Guarde o Tenant ID para referência futura!${NC}"
echo ""