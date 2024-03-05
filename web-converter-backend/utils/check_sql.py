import sqlparse


def check_valid_sql(sql_statement):
    parsed_statement = sqlparse.parse(sql_statement)
    for token in parsed_statement[0].tokens:
        if token.ttype in [sqlparse.tokens.Keyword.DML, sqlparse.tokens.Keyword.DDL, sqlparse.tokens.Keyword.CTE]:
            if token.value.upper() in ["CREATE", "DROP", "ALTER", "TRUNCATE", "COMMENT", "RENAME", "INSERT", "UPDATE", "DELETE", "LOCK", "CALL", "EXPLAIN PLAN", "GRANT", "REVOKE", "BEGIN", "COMMIT", "ROLLBACK", "SAVEPOINT"]:
                return False
    return True
