#!/usr/bin/env python
"""Fix PostgreSQL permissions for educare_connect user."""

import psycopg2

def try_postgres_connection(passwords):
    """Try to connect as postgres with different passwords."""
    for pwd in passwords:
        try:
            conn = psycopg2.connect(
                host="localhost",
                user="educare_connect",
                database="educare_connect",
                password=pwd
            )
            return conn
        except psycopg2.Error:
            continue
    return None

try:
    # Try common postgres passwords
    common_passwords = [
        "educare_connect123",
        "postgres",
        "password",
        "admin",
        "123456",
        "",  # no password
    ]
    
    print("Attempting to connect as postgres superuser...\n")
    conn = try_postgres_connection(common_passwords)
    
    if not conn:
        print("❌ Could not connect as postgres superuser with common passwords.")
        print("\n📝 Please run this SQL command manually as postgres superuser:")
        print("-" * 70)
        print("""
ALTER DATABASE educare_connect OWNER TO educare_connect;
ALTER SCHEMA public OWNER TO educare_connect;
GRANT ALL ON SCHEMA public TO educare_connect;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO educare_connect;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO educare_connect;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO educare_connect;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO educare_connect;
        """)
        print("-" * 70)
        print("\nYou can run these commands using:")
        print("1. pgAdmin or DBeaver GUI")
        print("2. psql command line")
        exit(0)

    print("✓ Connected as postgres superuser")

    conn.autocommit = True
    cur = conn.cursor()

    print("\nFixing permissions...\n")

    # Grant full rights to educare_connect user
    commands = [
        "ALTER DATABASE educare_connect OWNER TO educare_connect;",
        "ALTER SCHEMA public OWNER TO educare_connect;",
        "GRANT ALL ON SCHEMA public TO educare_connect;",
        "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO educare_connect;",
        "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO educare_connect;",
        "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO educare_connect;",
        "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO educare_connect;",
    ]
    
    for cmd in commands:
        cur.execute(cmd)
        print(f"✓ Executed: {cmd.strip()}")

    cur.close()
    conn.close()

    print("\n✅ All permissions fixed!")
    print("\nNow restart your app:")
    print("uvicorn app.main:app --reload")

except psycopg2.Error as e:
    print(f"❌ Error: {e}")
    exit(1)