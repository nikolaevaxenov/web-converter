from dotenv import load_dotenv
from models import query_model
import psycopg2
import psycopg2.extras
import os


if (os.path.isfile(".env.local")):
    load_dotenv(".env.local")
else:
    load_dotenv(".env.production")


conn = psycopg2.connect(dbname=os.getenv("DB_NAME"),
                            user=os.getenv("DB_USER"),
                            password=os.getenv("DB_PASSWORD"),
                            host=os.getenv("DB_HOST"),
                            cursor_factory=psycopg2.extras.RealDictCursor)
conn.set_client_encoding('UTF8')


def getConn():
    return conn


class DatabaseAlgebra:
    @staticmethod
    def get_all_queries():
        with conn:
            with conn.cursor() as curs:
                curs.execute('SELECT * FROM queries_algebra;')
                return curs.fetchall()

    @staticmethod
    def get_all_queries_names():
        with conn:
            with conn.cursor() as curs:
                curs.execute('SELECT id, query_group, last_name, query_id FROM queries_algebra;')
                return curs.fetchall()

    @staticmethod
    def get_query_by_id(query_id: int):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'SELECT * FROM queries_algebra WHERE id=%s;'
                curs.execute(sql_query, (query_id,))
                return curs.fetchone()

    @staticmethod
    def add_query(query: query_model.NewQuery):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'INSERT INTO queries_algebra (query_group, last_name, query_id, description, table_variables, target_list, query_body) values (%s, %s, %s, %s, %s, %s, %s) RETURNING id;'
                curs.execute(sql_query, (query.query_group, query.last_name, query.query_id, query.description, query.table_variables, query.target_list, query.query_body,))
                return curs.fetchone()

    @staticmethod
    def edit_query_by_id(query_id: int, query: query_model.EditQuery):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'UPDATE queries_algebra SET query_group = %s, last_name = %s, query_id = %s, description = %s, table_variables = %s, target_list = %s, query_body = %s WHERE id=%s RETURNING *;'
                curs.execute(sql_query, (query.query_group, query.last_name, query.query_id, query.description, query.table_variables, query.target_list, query.query_body, query_id,))
                return curs.fetchone()

    @staticmethod
    def delete_query_by_id(query_id: int):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'DELETE FROM queries_algebra WHERE id=%s;'
                curs.execute(sql_query, (query_id,))
                return curs.rowcount


class DatabaseTuple:
    @staticmethod
    def get_all_queries():
        with conn:
            with conn.cursor() as curs:
                curs.execute('SELECT * FROM queries_tuple;')
                return curs.fetchall()

    @staticmethod
    def get_all_queries_names():
        with conn:
            with conn.cursor() as curs:
                curs.execute('SELECT id, query_group, last_name, query_id FROM queries_tuple;')
                return curs.fetchall()

    @staticmethod
    def get_query_by_id(query_id: int):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'SELECT * FROM queries_tuple WHERE id=%s;'
                curs.execute(sql_query, (query_id,))
                return curs.fetchone()

    @staticmethod
    def add_query(query: query_model.NewQuery):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'INSERT INTO queries_tuple (query_group, last_name, query_id, description, table_variables, target_list, query_body) values (%s, %s, %s, %s, %s, %s, %s) RETURNING id;'
                curs.execute(sql_query, (query.query_group, query.last_name, query.query_id, query.description, query.table_variables, query.target_list, query.query_body,))
                return curs.fetchone()

    @staticmethod
    def edit_query_by_id(query_id: int, query: query_model.EditQuery):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'UPDATE queries_tuple SET query_group = %s, last_name = %s, query_id = %s, description = %s, table_variables = %s, target_list = %s, query_body = %s WHERE id=%s RETURNING *;'
                curs.execute(sql_query, (query.query_group, query.last_name, query.query_id, query.description, query.table_variables, query.target_list, query.query_body, query_id,))
                return curs.fetchone()

    @staticmethod
    def delete_query_by_id(query_id: int):
        with conn:
            with conn.cursor() as curs:
                sql_query = 'DELETE FROM queries_tuple WHERE id=%s;'
                curs.execute(sql_query, (query_id,))
                return curs.rowcount


class DatabaseGeneric:
    @staticmethod
    def get_all_tables():
        with conn:
            with conn.cursor() as curs:
                curs.execute('SELECT table_name FROM information_schema.tables WHERE table_schema=\'public\' AND table_type=\'BASE TABLE\' ORDER BY table_name;')
                return curs.fetchall()

    @staticmethod
    def get_all_columns(table_name: str):
        with conn:
            with conn.cursor() as curs:
                curs.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table_name}';")
                return curs.fetchall()

    @staticmethod
    def execute_sql(sql_query: str):
        with conn:
            with conn.cursor() as curs:
                curs.execute(sql_query)
                return curs.fetchall()

    @staticmethod
    def create_view(sql_view: query_model.SQLView):
        with conn:
            with conn.cursor() as curs:
                curs.execute(f'CREATE VIEW {sql_view.title} AS ' + sql_view.sql_query)
