from fastapi import APIRouter, HTTPException
from models import query_model
from utils import database, converter


router = APIRouter(prefix="/tuple", tags=['tuple'])


@router.get("/")
def get_all_queries():
    result = database.DatabaseTuple.get_all_queries()
    if not result:
        raise HTTPException(status_code=404, detail="Queries not found")
    return result


@router.get("/names")
def get_all_queries_names():
    result = database.DatabaseTuple.get_all_queries_names()
    if not result:
        raise HTTPException(status_code=404, detail="Queries not found")
    return result


@router.get("/{query_id}")
def get_query_by_id(query_id: int):
    result = database.DatabaseTuple.get_query_by_id(query_id)
    if not result:
        raise HTTPException(status_code=404, detail=f"Query with ID = {query_id} not found")
    return result


@router.post("/")
def add_query(query: query_model.NewQuery):
    return database.DatabaseTuple.add_query(query)


@router.put("/{query_id}")
def edit_query_by_id(query_id: int, query: query_model.EditQuery):
    result = database.DatabaseTuple.edit_query_by_id(query_id, query)
    if not result:
        raise HTTPException(status_code=404, detail=f"Query with ID = {query_id} not found")
    return result


@router.delete("/{query_id}")
def delete_query_by_id(query_id: int):
    result = database.DatabaseTuple.delete_query_by_id(query_id)
    if not result:
        raise HTTPException(status_code=404, detail=f"Query with ID = {query_id} not found")
    return result


@router.post("/convert")
def convert_query(query: query_model.ConvertQuery):
    return converter.convert_query_tuple(database.getConn(), query)
