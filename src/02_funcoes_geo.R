# 02_funcoes_geo.R

# 02.0 Classificar coord. em geográficas ou utm ----
classificar_coordenadas <- function(df) {

## Selecionar somente as coordenadas e o código de requerimento
  df_transformado <- df %>%
    select(c("requerimento", "x", "y")) %>%

## Tomar o valor absoluto de x e y
    mutate(
      x = abs(x),
      y = abs(y)
    ) %>%

## Calcular os coef. e exponentes de x e y
    mutate(
      coef_x = x / 10^floor(log10(x)),
      exp_x = floor(log10(x)),
      coef_y = y / 10^floor(log10(y)),
      exp_y = floor(log10(y))
    )

## Classificar as coord. com base nos coef. e expon.
  classificacao_geo <- df_transformado %>%
    group_by(exp_x, exp_y, coef_x, coef_y) %>%
    summarise(n = n()) %>%
    mutate(classificacao = case_when(
      exp_x == 5 & exp_y == 6 ~ "utm",
      (exp_x == 1 & exp_y == 1) & (trunc(coef_x) == 2 | trunc(coef_x) == 4) & (trunc(coef_y) == 2 | trunc(coef_y) == 4) ~ "geográfico",
      T ~ "erro"
    )) %>%
    ungroup()

## Unir a classificação no conjunto de dados tratados
  df_transformado <- df_transformado %>%
    left_join(classificacao_geo, by = c("exp_x", "exp_y", "coef_x", "coef_y"))

  return(df_transformado)
}


# 02.1 Extrair coordenadas geográficas ----
extrair_wgs84 <- function(df) {
  df_transformado <- df %>%
    filter(classificacao == "geográfico") %>%

## Adequar a ordem dos dados de latitude e longitude
    mutate(
      long = case_when(
        trunc(coef_y) == 2 ~ -x,
        trunc(coef_y) == 4 ~ -y
      ),
      lat = case_when(
        trunc(coef_x) == 2 ~ -x,
        trunc(coef_x) == 4 ~ -y
      )
    ) %>%
    select(c("requerimento", "long", "lat"))
  return(df_transformado)
}

# 02.2 Extrair coordenadas utm ----
extrair_utm <- function(df) {
  df_transformado <- df %>%
    filter(classificacao == "utm") %>%
    select(c("requerimento", "x", "y"))
}

# 02.3 Remover outliers ----
remover_outliers_geo <- function(df_geo) {
  df_geo$z_long <- scale(df_geo$long)
  df_geo$z_lat <- scale(df_geo$lat)

  df_geo_corr <- df_geo %>%
    filter(abs(z_long) < 1 & abs(z_lat) < 1)

  return(df_geo_corr)
}

remover_outliers_utm <- function(df_utm) {
  df_utm$z_x <- scale(df_utm$x)
  df_utm$z_y <- scale(df_utm$y)

  df_utm_corr <- df_utm %>%
    filter(abs(z_x) < 3 & abs(z_y) < 3)

  return(df_utm_corr)
}

# 02.4 Criar objetos vetoriais ----
criar_vetor_geo <- function (df_geo) {
  gdf_geo <- df_geo %>%
    st_as_sf(coords = c("long", "lat"), crs = 4326) %>%

## Transformar wgs84 em sirgas 2000
    st_transform(crs = 31982) %>%
    select(c("requerimento", "geometry"))
  return(gdf_geo)
}

criar_vetor_utm <- function (df_utm) {
  gdf_utm <- df_utm %>%
    st_as_sf(coords = c("x", "y"), crs = 31982) %>%
    select(c("requerimento", "geometry"))
  return(gdf_utm)
}

# 02.5 Unir os objetos vetoriais ----
unir_gdfs <- function (gdf_geo, gdf_utm) {
  gdf_unido <- rbind(gdf_geo, gdf_utm)

  coordenadas <- st_coordinates(gdf_unido$geometry)
  gdf_unido$x <- coordenadas[, "X"]
  gdf_unido$y <- coordenadas[, "Y"]
  rm(coordenadas)
  return(gdf_unido)
}

# 02.6 Unir a geometria do obj. vetorial aos demais atrib. ----
adicionar_geometria <- function (gdf_unido, df) {
  gdf <- df %>%
    select(-c("x", "y")) %>%
    left_join(gdf_unido, by = "requerimento")
  return(gdf)
}

adicionar_atributos <- function (gdf_unido, df) {
  gdf <- df %>%
    select(-c("x", "y")) %>%
    right_join(gdf_unido, by = "requerimento")
  return(gdf)
}

# 02.7 Remover pontos fora dos limites municipais ----
remover_pontos_fora <- function(gdf) {
  vetor_selecao_pontos <- st_intersects(gdf, limites_itajai, sparse = F)
  gdf_dentro <- gdf[vetor_selecao_pontos, ]
  return(gdf_dentro)
  rm(vetor_selecao_pontos)
}

