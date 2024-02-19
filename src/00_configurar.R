# 00_configurar.R

# 00.0 Carregar as configurações em arquivo .yml ----
config <- config::get(file = "config/config.yml")

# 00.1 Carregar os pacotes a serem utilizados ----
lapply(config$pacotes, library, character.only = TRUE)

# 00.2 Carregar as funções próprias a serem utilizadas ----
source("src/01_funcoes.R")
source("src/02_funcoes_geo.R")

# 00.3 Carregar os dados geográficos em formato vetorial ----
limites_itajai <- st_read("data/geo/limites_itajai.shp")
municipios <- st_read("data/geo/municipios.shp")

# 00.4 Carregar arquivos com nomes de colunas e de var. categóricas ----
nomes_colunas  <- readr::read_csv(config$caminhos$nomes_colunas)

grupo_codigos  <- readr::read_csv(config$caminhos$grupo_codigos)
grupo_codigos <- setNames(grupo_codigos$grupo, grupo_codigos$codigo_consema)

siglas_lic  <- readr::read_csv(config$caminhos$siglas_lic)
siglas_lic <- setNames(siglas_lic$sigla, siglas_lic$licenca)

siglas_grupo  <- readr::read_csv(config$caminhos$siglas_grupo)
siglas_grupo <- setNames(siglas_grupo$sigla, siglas_grupo$grupo)


# 00.5 Leitura dos dados pelo R ----
df_bruto <- readr::read_delim(config$leitura_dados$caminho,
  delim = config$leitura_dados$delimiter,
  quote = config$leitura_dados$quote,
  col_names = nomes_colunas$nome,
  locale = locale(encoding = config$leitura_dados$encoding),
  skip = config$leitura_dados$skip
)