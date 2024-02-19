# 01_funcoes.R

####
# 01.00 Funções para remapear valores de var. categóricas ----
####

## 01.01 Remapear variável `tipo_licenca`
remapear_tipo_licenca <- function(df) {
  df_transformado <- df %>%
    mutate(tipo_licenca = siglas_lic[tipo_licenca])
  return(df_transformado)
}

## 01.02 Remapear variável `coordenador`
remapear_nome_coordenador <- function(df) {
  df_transformado <- df %>%
    mutate(coordenador = siglas_analistas[coordenador])
  return(df_transformado)
}


# 01.10 Funções para criar novas var. ----
## 01.11 Criar variável `grupo_codigo`
criar_grupo_codigo <- function(df) {
  df_transformado <- df %>%
    mutate(grupo_codigo = grupo_codigos[codigo_consema])
  return(df_transformado)
}

## 01.12 Criar variável `grupo_codigo_resumo`
criar_grupo_codigo_resumo <- function(df) {
  df_transformado <- df %>%
    mutate(grupo_codigo_resumo = siglas_grupo[grupo_codigo])
  return(df_transformado)
}

## 01.13 Criar variável `grupo_processo`
extrair_codigo_processo <- function(df) {
  df_grupo <- df %>%
    mutate(grupo_processo = str_sub(processo, 1, 3))
}


####
# 01.20 Funções para formatar valores de var. ----
####


## 01.21 Capitalizar var. `descricao_consema`
capitalizar_descricao <- function(df) {
  df_transformado <- df %>%
  mutate(descricao_consema = str_to_sentence(descricao_consema, locale = "pt_BR"))
  return(df_transformado)
}

## 01.22 Capitalizar var. `endereco`
capitalizar_enderecos <- function(df) {
  df_transformado <- df %>%
    mutate(endereco = str_to_title(endereco, locale = "pt_BR"))
  return(df_transformado)
}

## 01.23 Capitalizar var. `razao_social`
capitalizar_razao_social <- function(df) {
  df_transformado <- df %>%
    mutate(razao_social = str_to_upper(razao_social, locale = "pt_BR"))
  return(df_transformado)
}

## 01.24 Formatar var. `cep`
formatar_cep <- function(df) {
  df_transformado <- df %>%
    mutate(cep = paste0(substr(cep, 1, 5), "-", substr(cep, 6, 8)))
  return(df_transformado)
}

## 01.25 Limpar as variáveis de datas
limpar_datas <- function(df) {
  df_transformado <- df %>%
    mutate(
      data_licenca = str_replace_all(data_licenca, "O requerimento ainda não possui uma licença emitida.", NA_character_),
      data_protocolo = str_replace_all(data_protocolo, "Não Protocolado", NA_character_),
      data_equipe = str_replace_all(data_equipe, "Sem Equipe Formada", NA_character_)
    ) %>%
    mutate(
      data_protocolo = str_remove_all(data_protocolo, "às"),
      data_equipe = str_remove_all(data_equipe, "às")
    )
  return(df_transformado)
}

# 01.26 Formatar as datas
formatar_datas <- function(df) {
  df_formatado <- df %>%
    mutate(
      data_licenca = ymd(data_licenca),
      data_protocolo = dmy_hm(data_protocolo),
      data_equipe = dmy_hm(data_equipe)
    )
  return(df_formatado)
}

# 01.27 Formatar o CPF/CNPJ
formatar_cnpj <- function(df) {
  df_formatado <- df %>%
    mutate(
      contagem_digitos = nchar(gsub("[^0-9]", "", cnpj)), # limpar e contar num. digitos
      grupo = case_when(
        contagem_digitos == 14 ~ "CNPJ",
        contagem_digitos == 11 ~ "CPF",
        TRUE ~ "Erro" # valor padrão para demais num. de digitos
      ),
      formatado = case_when(
        grupo == 'CNPJ' ~ str_c(
          str_sub(cnpj, 1, 2), ".",
          str_sub(cnpj, 3, 5), ".",
          str_sub(cnpj, 6, 8), "/",
          str_sub(cnpj, 9, 12), "-",
          str_sub(cnpj, 13, 14)
        ),
        grupo == 'CPF' ~ str_c(
          str_sub(cnpj, 1, 3), ".",
          str_sub(cnpj, 4, 6), ".",
          str_sub(cnpj, 7, 9), "-",
          str_sub(cnpj, 10, 11)
        ),
        TRUE ~ cnpj  # sem formatação para erro
      )
    ) %>%
    select(-c(cnpj,contagem_digitos,grupo)) %>%
    relocate(formatado, .after = razao_social) %>%
    rename(cnpj = formatado)
  return(df_formatado)
}

####
# 01.30 Funções para filtrar valores de var. ----
####

## 01.31 Remover requerimentos cancelados
### Remove os req. cancelados do `df` de entrada
remover_cancelados <- function(df) {
  df_filtrado <- df %>%
    filter(fase != "FCEI cancelado" | status != "FCEI Cancelado")
  return(df_filtrado)
}

## 01.32 Remover requerimentos ativos
### Retorna `df` somente com os req. cancelados
remover_ativos <- function(df) {
  df_filtrado <- df %>%
    filter(fase == "FCEI cancelado" & status == "FCEI Cancelado")
  return(df_filtrado)
}

## 01.33 Remover DANCs e CCAs
### Remove as DANCs e CCAs do `df` de entrada
remover_cca <- function(df) {
  df_filtrado <- df %>%
    filter(tipo_licenca != "DANC" & tipo_licenca != "CCA")
  return(df_filtrado)
}

## 01.34 Remover licenciamento propriamente dito
### Retorna `df` somente com DANCs e CCAs
remover_licenciamento <- function(df) {
  df_filtrado <- df %>%
    filter(tipo_licenca == "DANC" | tipo_licenca == "CCA")
  return(df_filtrado)
}

## 01.35 Remover licenças não emitidas
### Retorna `df` somente com licenças emitidas
remover_nao_emitidas <- function(df) {
  df_filtrado <- df %>%
    filter(is.na(data_licenca) == F)
  return(df_filtrado)
}

## 01.36 Remover requerimentos não protocolados
### Retorna `df` somente com req. protocolados
filtrar_protocolados <- function(df) {
  df_filtrado <- df %>%
    filter(is.na(data_protocolo) == F)
  return(df_filtrado)
}

## 01.37 Remover requerimentos protocolados
### Retorna `df` somente com req. não protocolados
filtrar_nao_protocolados <- function(df) {
  df_filtrado <- df %>%
    filter(is.na(data_protocolo) == T)
  return(df_filtrado)
}
