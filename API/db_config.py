import os
import configparser
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Local Development Credentials
# Update these for your local Windows environment
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', 3306)
DB_NAME = os.getenv('DB_NAME', 'datingapp')

# API Key for authentication
API_KEY = os.getenv('API_KEY', "CHANGE_ME_TO_SECURE_KEY")

def get_database_uri():
    user = DB_USER
    password = DB_PASSWORD
    host = DB_HOST
    port = DB_PORT
    

    return f"mysql+pymysql://{user}:{password}@{host}:{port}/{DB_NAME}"
