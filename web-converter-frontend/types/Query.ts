export type Query = {
  query_group: string | null;
  last_name: string | null;
  query_id: string | null;
  description: string | null;
  table_variables: string | null;
  target_list: string | null;
  query_body: string | null;
};

export type QueryName = {
  id: number;
  query_group: string;
  last_name: string;
  query_id: string;
};

export type ConvertQuery = {
  table_variables: string | null;
  target_list: string | null;
  query_body: string | null;
};

export type TableName = {
  table_name: string;
};

export type TableNames = {
  table_names: string[];
};

export type SQLQuery = {
  sql_query: string;
};

export type SQLView = {
  title: string;
  sql_query: string;
};
