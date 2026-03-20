"""
Database connection module using SQLAlchemy
Connects to the PostgreSQL database via Supabase
"""
from sqlalchemy.pool import NullPool
from sqlalchemy import create_engine, text

# Database credentials
USER = "postgres.jgdojkbhcxzploxzpzxa"
PASSWORD = "xpgwvUKtz/m*7!X"
HOST = "aws-1-ap-south-1.pooler.supabase.com"
PORT = "6543"
DBNAME = "postgres"

# Construct the SQLAlchemy connection string
DATABASE_URL = f"postgresql+psycopg2://{USER}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}?sslmode=require"

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
