# 1. Extração dos dados ----
library(reticulate)
py_run_file("src/10_extrair.py")

# 2. Configuração dos scripts ----
source("src/00_configurar.R", encoding = "UTF-8")

# 3. Tratamento dos dados ----
source("src/20_tratar.R", encoding = "UTF-8")

# 4. Armazenamento dos dados ----
source("src/30_salvar.R", encoding = "UTF-8")