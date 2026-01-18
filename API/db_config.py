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
    """
    Constructs the database URI.
    Prioritizes ~/.my.cnf (standard MySQL config) if it exists (for server deployment).
    Falls back to local constants defined above.
    """
    my_cnf_path = os.path.expanduser('~/.my.cnf')
    
    user = DB_USER
    password = DB_PASSWORD
    host = DB_HOST
    port = DB_PORT
    
    if os.path.exists(my_cnf_path):
        try:
            config = configparser.ConfigParser()
            config.read(my_cnf_path)
            if 'client' in config:
                # user = config['client'].get('user', user)
                # password = config['client'].get('password', password)
                # host = config['client'].get('host', host)
                # port = config['client'].get('port', port)
        except Exception as e:
            print(f"Warning: Could not parse {my_cnf_path}: {e}")

    return f"mysql+pymysql://{user}:{password}@{host}:{port}/{DB_NAME}"
