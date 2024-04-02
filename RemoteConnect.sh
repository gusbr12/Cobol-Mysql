#!/bin/bash

# Configurações de conexão ao PostgreSQL
USUARIO="USUARIO PSQL"
BANCO_DE_DADOS="SEU BANCO PSQL"
ENDERECO="SEU.IP"
USUARIO_MYSQL="USER DO MYSQL"
SENHA_MYSQL="SENHA_MYSQL" 
PORTA_MYSQL="3306"
# Extensão que você deseja verificar
EXTENSAO="mysql_fdw"

# Construa a string de conexão para o psql
STRING_CONEXAO="-U $USUARIO -d $BANCO_DE_DADOS"

# Verifique se a extensão existe
EXISTE_EXTENSAO=$(psql $STRING_CONEXAO -tAc "SELECT COUNT(*) FROM pg_extension WHERE extname = '$EXTENSAO';")

if [ $EXISTE_EXTENSAO -eq 1 ]; then
    echo "A extensão $EXTENSAO já está instalada no banco de dados. Removendo servidor e mapeamento de usuário associados..."
    # Remove o mapeamento de usuário associado à extensão
    psql $STRING_CONEXAO -c "DROP USER MAPPING IF EXISTS FOR $USUARIO SERVER server_mysql;"
    # Remove a extensão existente
    psql $STRING_CONEXAO -c "DROP EXTENSION IF EXISTS $EXTENSAO CASCADE;"
else
    echo "A extensão $EXTENSAO não está instalada no banco de dados. Criando..."
fi

# Criação da extensão
#psql $STRING_CONEXAO -c "CREATE EXTENSION $EXTENSAO;"


# Código para criar o banco de dados 'users' (verifica se o banco de dados existe antes de criar)
echo "CREATE DATABASE users;" | psql $STRING_CONEXAO >/dev/null 2>&1
echo "\c users;
create table users (user_id INTEGER PRIMARY KEY NOT NULL, 
username VARCHAR(50) NOT NULL, password CHAR (50) NOT NULL);
INSERT INTO users VALUES (1, '$USUARIO_MYSQL', '$SENHA_MYSQL');" | psql $STRING_CONEXAO



echo "create extension mysql_fdw;
create server server_mysql foreign data wrapper 
mysql_fdw options(host '$ENDERECO', port '$PORTA_MYSQL');"| psql $STRING_CONEXAO


echo "create user mapping for $USUARIO server server_mysql options 
(username '$USUARIO_MYSQL', password '$SENHA_MYSQL');" | psql $STRING_CONEXAO

echo "grant usage on foreign server server_mysql to $USUARIO;" | psql $STRING_CONEXAO

echo "create foreign table TBLtest_mysql (TBLId INTEGER, TBLData DATE, TBLHora VARCHAR(8)) 
SERVER server_mysql options (dbname 'DBtest', table_name 'TBLtest');"| psql $STRING_CONEXAO
