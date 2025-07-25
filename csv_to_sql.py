import pandas as pd
import pymysql  # Make sure you use pymysql here, not mysql.connector
import os

# List of CSV files and corresponding table names
csv_files = [
    ('customers.csv', 'customers'),
    ('geolocation.csv', 'geolocation'),
    ('order_items.csv', 'order_items'),
    ('orders.csv', 'orders'),
    ('payments.csv', 'payments'),
    ('products.csv', 'products'),
    ('sellers.csv', 'sellers')
]
# ✅ Connect to MySQL database
conn = pymysql.connect(
    host='localhost',
    user='root',
    password='adi',
    database='ecommerce'
)
cursor = conn.cursor()

# ✅ Set folder path where your CSV files are located
folder_path = r'C:\Programming\Data Analytics\Data Analytics Projects\Ecommerce Sales Analysis\Data'


# ✅ Helper function to map pandas dtypes to SQL types
def get_sql_type(dtype):
    if pd.api.types.is_integer_dtype(dtype):
        return 'INT'
    elif pd.api.types.is_float_dtype(dtype):
        return 'FLOAT'
    elif pd.api.types.is_bool_dtype(dtype):
        return 'BOOLEAN'
    elif pd.api.types.is_datetime64_any_dtype(dtype):
        return 'DATETIME'
    else:
        return 'TEXT'

# ✅ Process each CSV
for csv_file, table_name in csv_files:
    file_path = os.path.join(folder_path, csv_file)

    if not os.path.exists(file_path):
        print(f"❌ File not found: {file_path}")
        continue

    print(f"📦 Processing {csv_file}...")

    # Read CSV
    df = pd.read_csv(file_path)

    # Replace NaNs with None
    df = df.where(pd.notnull(df), None)

    # Clean column names
    df.columns = [col.strip().replace(' ', '_').replace('-', '_').replace('.', '_') for col in df.columns]

    # Create SQL table
    columns = ', '.join([f'`{col}` {get_sql_type(df[col].dtype)}' for col in df.columns])
    create_table_query = f'CREATE TABLE IF NOT EXISTS `{table_name}` ({columns})'
    cursor.execute(create_table_query)

    # Insert rows
    for _, row in df.iterrows():
        values = tuple(None if pd.isna(x) else x for x in row)
        placeholders = ', '.join(['%s'] * len(values))
        sql = f"INSERT INTO `{table_name}` ({', '.join(['`' + col + '`' for col in df.columns])}) VALUES ({placeholders})"
        cursor.execute(sql, values)

    # Commit
    conn.commit()
    print(f"✅ Inserted into `{table_name}`\n")

# Close connection
cursor.close()
conn.close()
print("🎉 All CSV files processed and uploaded to MySQL.")
