# 20_tratar.R

# 02.1 Pré-processamento dos dados ----
df_pre_processado <- df_bruto %>%
  remapear_tipo_licenca() %>%
  limpar_datas() %>%
  select(-regional)


# 02.2 Tratamento dos dados ----
df <- df_pre_processado %>%
  formatar_datas() %>%
  formatar_cnpj() %>%
  capitalizar_descricao() %>%
  capitalizar_enderecos() %>%
  capitalizar_razao_social() %>%
  formatar_cep() %>%
  criar_grupo_codigo() %>%
  extrair_codigo_processo() %>%
  criar_grupo_codigo_resumo() %>%

## Filtrar dados não cancelados e dados protocolados
  remover_cancelados() %>%
  filtrar_protocolados() %>%

## Remover registros duplicados
  distinct(requerimento, .keep_all = T)


# 02.3 Tratamento dos dados geográficos ----
df_geo_tratado <- df %>%
  classificar_coordenadas()

## Separar coordenadas geográficas (wgs84 - epsg 4326) ----
gdf_4326 <- df_geo_tratado %>%
  extrair_wgs84() %>%
  remover_outliers_geo() %>%
  criar_vetor_geo() %>%
  remover_pontos_fora()

## Separar coordenadas utm (sirgas2000 - epsg 31982) ----
gdf_31982 <- df_geo_tratado %>%
  extrair_utm() %>%
  remover_outliers_utm() %>%
  criar_vetor_utm() %>%
  remover_pontos_fora()

## Unir coord. geográficas e utm e adicionar geometria ao df ----
gdf <- unir_gdfs(gdf_4326, gdf_31982) %>%
  adicionar_geometria(df) %>%
  st_as_sf(sf_column_name = "geometry",
           crs = 31982) %>%

## Transformar em wgs84 web mercator - epsg 3857
  st_transform(crs = 3857)