# 10_extrair.py

# 1.0 Carregar os pacotes a serem utilizados
import os
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv
from pathlib import Path

# 1.1 Carregar as configurações do programa 
ENV_PATH = Path.cwd() / "env" / "secret.env"
DATA_PATH = Path.cwd() / "data"
LOGIN_URL = "https://sinfat.ciga.sc.gov.br/login"
CSV_DOWNLOAD_URL = "https://sinfat.ciga.sc.gov.br/consulta/csv"

# 1.2 Carregar as variáveis de autenticação
load_dotenv(ENV_PATH)
login_data = {
    "username": os.getenv("USERNAME"),
    "password": os.getenv("PASSWORD"),
    "_csrf": "",
}


# 1.3 Função para obtenção do token CSRF
def extrair_csrf(session, login=LOGIN_URL) -> str:
    """Extrai o token CSRF da página de login"""
    login_page = session.get(login)
    soup = BeautifulSoup(login_page.content, "html.parser")
    csrf_token = soup.find("input", attrs={"name": "_csrf"})["value"]
    return csrf_token


# 1.4 Função para iniciar uma sessão de login
def sessao_login(session, csrf_token, login=LOGIN_URL):
    """Cria uma sessão de login"""
    login_data.update({"_csrf": csrf_token})
    session.post(login, data=login_data)


# 1.5 Função para salvar o arquivo .csv do servidor em memória
def downloader_csv(session, download_csv=CSV_DOWNLOAD_URL):
    """Baixa o arquivo .csv dos dados"""
    download = session.get(download_csv)
    return download.content


# 1.6 Função para salvar os dados em disco
def save_csv(file_path, file_content):
    """Salva o arquivo .csv em disco"""
    with file_path.open(mode="wb") as file:
        file.write(file_content)

# 1.7 Função para extrair os dados do servidor e armazená-los em disco
def main():
    with requests.Session() as s:
        csrf_token = extrair_csrf(session=s)
        sessao_login(session=s, csrf_token=csrf_token)
        file_path = DATA_PATH / "bruto" / "dados_sinfat.csv"
        file_path.touch()
        file_content = downloader_csv(session=s)
        save_csv(file_path, file_content)


if __name__ == "__main__":
    main()
