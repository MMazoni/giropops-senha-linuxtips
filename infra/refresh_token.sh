#!/bin/bash

# Caminho do arquivo de configuração OCI
OCI_CONFIG_FILE=~/.oci/config

# Perfil OCI
OCI_PROFILE=DEFAULT

# Função para renovar o token
refresh_token() {
    oci session refresh --config-file $OCI_CONFIG_FILE --profile $OCI_PROFILE
}

# Função para exibir o tempo de expiração do token
show_token_expiration() {
    oci session validate --config-file ~/.oci/config --profile DEFAULT
}

# Função para exportar o token
export_token() {
    export OCI_CLI_AUTH=security_token
}

# Renovar o token
refresh_token
show_token_expiration
export_token

