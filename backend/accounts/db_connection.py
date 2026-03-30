"""
Database connection module using SQLAlchemy
Connects to the PostgreSQL database via Supabase
"""
import os
from sqlalchemy.pool import NullPool
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env'))

# Database credentials are sourced from environment variables.
USER = os.getenv('DB_USER', 'postgres')
PASSWORD = os.getenv('DB_PASSWORD', '')
HOST = os.getenv('DB_HOST', 'localhost')
PORT = os.getenv('DB_PORT', '5432')
DBNAME = os.getenv('DB_NAME', 'postgres')
SSLMODE = os.getenv('DB_SSLMODE', 'prefer')

# Construct the SQLAlchemy connection string
DATABASE_URL = f"postgresql+psycopg2://{USER}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}?sslmode={SSLMODE}"

# Create engine with connection pooling disabled for testing
engine = create_engine(DATABASE_URL, poolclass=NullPool)

def get_db_connection():
    """Get a database connection"""
    return engine.connect()

def test_connection():
    """Test the database connection"""
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            print("✓ Database connection successful!")
            return True
    except Exception as e:
        print(f"✗ Failed to connect: {e}")
        return False
