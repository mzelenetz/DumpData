import os
import re
import yaml
import datetime as dt

from wpconnect import Query

# Get configs from file
with open('cfg.yml', 'r') as file:
    cfg = yaml.load(file, Loader=yaml.FullLoader)

# Filesystem
default_sql_dir = cfg['SQL_DIR']
data_dir = cfg['LOCAL_DIR']

# Oracle auth
oracle_host = cfg['ORACLE_HOST']
oracle_port = cfg['ORACLE_PORT']
oracle_service = cfg['ORACLE_SERVICE']
oracle_user = cfg['ORACLE_USER']
oracle_pwd = cfg['ORACLE_PWD']

# Get today's date
def _get_date():
    return dt.datetime.now().date().strftime('%Y%m%d')

today = _get_date()

# Make sure the local data directory exists
def _ensure_data_dir():
    if not os.path.exists(data_dir):
        os.mkdir(data_dir)

# Connect to Oracle
def _connect_db():
    q = Query(
        server=oracle_host,
        database=oracle_service,
        username=oracle_user,
        password=oracle_pwd
    )

    q.add_query_libs(default_sql_dir)

    return q

# Get the query
def _get_query(sql_dir, query_name):
    with open(os.path.join(sql_dir, query_name) + '.sql', 'r') as file:
        query = file.read()

    return query

# Read data from oracle
def _get_data(conn, query):
    d = conn.execute_query(query)

    return d

# Get a filename
def _get_fp(base, suffix):
    return os.path.join(data_dir, f'{base}_{suffix}.csv')

# Write the query data to a csv file in the data_dir
def _write_data(df, fp):
    df.to_csv(fp, index=False)

def write_data(
    query_name,
    query_directory,
    filename
):
    if filename is None:
        filename = query_name

    _ensure_data_dir()

    conn = _connect_db()

    query = _get_query(query_directory, query_name)

    output = _get_data(conn, query)

    if len(output.index) == 0:
        raise Exception('The query returned no data')

    fp = _get_fp(filename, today)

    _write_data(output, fp)

    return(fp)
