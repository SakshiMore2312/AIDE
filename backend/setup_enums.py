#!/usr/bin/env python
"""Create ENUM types that are missing from the database."""

import psycopg2
from psycopg2 import sql

try:
    conn = psycopg2.connect(
        host="localhost",
        user="educare_connect",
        database="educare_connect",
        password="educare_connect123"
    )
    
    cur = conn.cursor()
    
    # List of ENUM types to create
    enums = [
        ("coachingtype", ["'ONLINE'", "'OFFLINE'"]),
        ("messtype", ["'VEG'", "'NON_VEG'", "'BOTH'"]),
    ]
    
    for enum_name, enum_values in enums:
        try:
            # Try to drop if it exists (old way, without IF NOT EXISTS)
            cur.execute(f"DROP TYPE {enum_name} CASCADE")
            print(f"✓ Dropped {enum_name}")
        except psycopg2.Error:
            pass
        
        try:
            # Create the ENUM type
            values_str = ", ".join(enum_values)
            create_sql = f"CREATE TYPE {enum_name} AS ENUM ({values_str})"
            cur.execute(create_sql)
            print(f"✓ Created ENUM: {enum_name}")
        except psycopg2.Error as e:
            print(f"✗ Error creating {enum_name}: {e}")
    
    conn.commit()
    cur.close()
    conn.close()
    
    print("\n✓ ENUM types setup complete!")
    print("Now restart your app: uvicorn app.main:app --reload")
    
except psycopg2.Error as e:
    print(f"Error: {e}")
    exit(1)
