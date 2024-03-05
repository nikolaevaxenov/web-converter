from fastapi import APIRouter, HTTPException
from models import query_model
from utils import database


router = APIRouter(prefix="/algebra", tags=['algebra'])


@router.get("/")
def get_all_queries():
    result = database.DatabaseAlgebra.get_all_queries()
    if not result:
        raise HTTPException(status_code=404, detail="Queries not found")
    return result


@router.get("/names")
def get_all_queries_names():
    result = database.DatabaseAlgebra.get_all_queries_names()
    if not result:
        raise HTTPException(status_code=404, detail="Queries not found")
    return result


@router.get("/{query_id}")
def get_query_by_id(query_id: int):
    result = database.DatabaseAlgebra.get_query_by_id(query_id)
    if not result:
        raise HTTPException(status_code=404, detail=f"Query with ID = {query_id} not found")
    return result


@router.post("/")
def add_query(query: query_model.NewQuery):
    return database.DatabaseAlgebra.add_query(query)


@router.put("/{query_id}")
def edit_query_by_id(query_id: int, query: query_model.EditQuery):
    result = database.DatabaseAlgebra.edit_query_by_id(query_id, query)
    if not result:
        raise HTTPException(status_code=404, detail=f"Query with ID = {query_id} not found")
    return result


@router.delete("/{query_id}")
def delete_query_by_id(query_id: int):
    result = database.DatabaseAlgebra.delete_query_by_id(query_id)
    if not result:
        raise HTTPException(status_code=404, detail=f"Query with ID = {query_id} not found")
    return result
