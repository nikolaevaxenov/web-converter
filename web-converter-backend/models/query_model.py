from pydantic import BaseModel, Field


class NewQuery(BaseModel):
    query_group: str = Field(min_length=1)
    last_name: str = Field(min_length=1)
    query_id: str = Field(min_length=1)
    description: str | None = Field(default=None, min_length=1)
    table_variables: str | None = Field(default=None, min_length=1)
    target_list: str | None = Field(default=None, min_length=1)
    query_body: str | None = Field(default=None, min_length=1)


class EditQuery(BaseModel):
    query_group: str = Field(min_length=1)
    last_name: str = Field(min_length=1)
    query_id: str = Field(min_length=1)
    description: str | None = Field(default=None, min_length=1)
    table_variables: str | None = Field(default=None, min_length=1)
    target_list: str | None = Field(default=None, min_length=1)
    query_body: str | None = Field(default=None, min_length=1)


class ConvertQuery(BaseModel):
    table_variables: str = Field(min_length=1)
    target_list: str = Field(min_length=1)
    query_body: str = Field(min_length=1)


class GetColumnsNames(BaseModel):
    table_names: list[str] = Field(min_length=1)


class SQLQuery(BaseModel):
    sql_query: str = Field(min_length=1)


class SQLView(BaseModel):
    title: str = Field(min_length=1)
    sql_query: str = Field(min_length=1)
