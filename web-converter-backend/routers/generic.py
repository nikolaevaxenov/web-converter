from fastapi import APIRouter, HTTPException
from models import query_model
from utils import database, check_sql
import psycopg2.errors as psycopg2_errors
import uuid


router = APIRouter(prefix="/generic", tags=['generic'])


@router.get("/")
def get_all_tables():
    result = database.DatabaseGeneric.get_all_tables()
    if not result:
        raise HTTPException(status_code=404, detail="Tables not found")
    return result


@router.post("/")
def execute_sql(sql_query_obj: query_model.SQLQuery):
    if not check_sql.check_valid_sql(sql_query_obj.sql_query):
        raise HTTPException(status_code=406, detail="Illegal SQL expression")

    try:
        result = database.DatabaseGeneric.execute_sql(sql_query_obj.sql_query)
    except psycopg2_errors.SyntaxError:
        raise HTTPException(status_code=406, detail="Invalid SQL expression")


@router.post("/view")
def create_view(sql_view: query_model.SQLView):
    if not check_sql.check_valid_sql(sql_view.sql_query):
        raise HTTPException(status_code=406, detail="Illegal SQL expression")

    try:
        database.DatabaseGeneric.create_view(sql_view)
    except psycopg2_errors.SyntaxError:
        raise HTTPException(status_code=406, detail="Invalid SQL expression")
    except psycopg2_errors.DuplicateTable:
        sql_view.title = f"{sql_view.title}_{str(uuid.uuid1()).split("-")[0]}"
        database.DatabaseGeneric.create_view(sql_view)
    return sql_view.title
