from models import query_model
from utils import converter_funcs


def convert_query_algebra(conn, query: query_model.ConvertQuery):
    print(query.query_body)

    oTV = converter_funcs.TableVariables(query.table_variables)
    aTV_ASS = oTV.get_table_variables("ASS")
    aTV_ALL = oTV.get_table_variables("ALL")
    aTV_IND = oTV.get_table_variables("IND")

    oGL = converter_funcs.TargetList(query.target_list)
    aGL_VAR = oGL.get_target_list("VAR")
    aGL_ATR = oGL.get_target_list("ATR")

    oQB = converter_funcs.QueryBody(query.query_body)
    aQB_QWB = oQB.get_query_body("QWB")
    nQB_QTY = oQB.get_query_body("QTY")
    aQB_QBX = oQB.get_query_body("QBX")

    if aGL_ATR[0] == "*":
        query.target_list = ""
        wTBL = aTV_ASS[aGL_VAR[0]]
        sql = "SHOW COLUMNS FROM " + wTBL
        with conn:
            with conn.cursor() as curs:
                curs.execute(sql)
                for i in cur:
                    query.target_list += aGL_VAR[0] + "." + i[0] + ","
                query.target_list = query.target_list.rstrip(",")
    
    wQ0 = aQB_QWB[0].replace(") ", ")")
    wQ2 = aQB_QWB[2]
    sqlW = ""
    
    if wQ2 == "A":
        sqlW = converter_funcs.sql_1(wQ0, query.table_variables, query.target_list)
    
    if wQ2 == " EXCEPT " or wQ2 == " INTERSECT " or wQ2 == " UNION ":
        qb_qty_0 = wQ0.count("[")
        GoalList_0 = query.target_list
        TableVar_0 = ""

        if qb_qty_0 == 0:
            TableVar_0 = aTV_ALL[wQ0.strip("()")]
        else:
            for i in range(qb_qty_0 + 1):
                if i < qb_qty_0:
                    TableVar_0 += aTV_ALL[converter_funcs.qb_01(wQ0, "", 2)[i]] + ","
                else:
                    TableVar_0 += aTV_ALL[converter_funcs.qb_01(wQ0, "", 2)[i]]

        wQ1 = aQB_QWB[1].replace(") ", ")").strip()
        qb_qty_1 = wQ1.count("[")
        GoalList_1 = converter_funcs.qb_02(wQ1, 0)
        mwQ2 = wQ1.split("[")
        mwQty = len(mwQ2)
        wQ1_2 = ""

        if mwQty == 1:
            wQ1_2 += mwQ2[0] + ")"
        
        if mwQty > 1:
            for i in range(mwQty - 1):
                if i < mwQty - 2:
                    wQ1_2 += mwQ2[i] + ")["
                else:
                    wQ1_2 += mwQ2[i] + ")"

        TableVar_1 = ""
        for i in range(qb_qty_1):
            if i < qb_qty_1 - 1:
                TableVar_1 += aTV_ALL[converter_funcs.qb_02(wQ1, 2)[i]] + ","
            else:
                TableVar_1 += aTV_ALL[converter_funcs.qb_02(wQ1, 2)[i]]
        
        sqlW = converter_funcs.sql_1(wQ0, TableVar_0, GoalList_0) + "\n" + wQ2 + "\n" + converter_funcs.sql_1(wQ1_2, TableVar_1, GoalList_1)

    if wQ2 == " DELETE ":
        wj = 0
        sD1 = aQB_QBX[0][:1]
        aGL = aGL_VAR
        aGL.append(sD1)
        aD2 = list(set(aTV_IND) - set(aGL))
        nD2 = len(aD2) - 1

        for i in range(nQB_QTY + 1):
            if aQB_QBX[i].find("#") > 0:
                wj = i
                aQB_QBX[i] = aQB_QBX[i].replace("#", "=")
        
        sqlW += "SELECT " + query.target_list + "\n FROM "
        QtyGl = len(aGL_VAR)

        for i in range(QtyGl):
            if i < QtyGl - 1:
                sqlW += aTV_ALL[aGL_VAR[i]] + ","
            else:
                sqlW += aTV_ALL[aGL_VAR[i]]

        sqlW += "\n WHERE NOT EXISTS " + "\n(SELECT * \n FROM  "
        i = 0

        for x in aD2:
            if i < nD2:
                sqlW += aTV_ALL[x] + ","
                i += 1
            else:
                sqlW += aTV_ALL[x]

        sqlW += "\n WHERE "
        
        for i in range(wj+1, nQB_QTY):
            sqlW += aQB_QBX[i] + " AND "
        
        sqlW += " NOT EXISTS" + "\n(SELECT * \n FROM  " + aTV_ALL[sD1] + "\n WHERE "

        for i in range(wj + 1):
            if i < wj:
                sqlW += aQB_QBX[i] + " AND "
            else:
                sqlW += aQB_QBX[i] + " ))"

    QuerySQL = sqlW.replace("\"", "'")
    return QuerySQL


def convert_query_tuple(conn, query: query_model.ConvertQuery):
    table_variables_obj = converter_funcs.TableVariables(query.table_variables)
    table_variables_associations = table_variables_obj.get_table_variables("ASS")
    table_variables_full_string_associations = table_variables_obj.get_table_variables("ALL")

    target_list_obj = converter_funcs.TargetList(query.target_list)
    target_list_variables = target_list_obj.get_target_list("VAR")
    target_list_attributes = target_list_obj.get_target_list("ATR")

    if target_list_attributes[0] == "*":
        query.target_list = ""
        table_name = table_variables_associations[target_list_variables[0]]
        sql = "SHOW COLUMNS FROM " + table_name
        with conn:
            with conn.cursor() as curs:
                curs.execute(sql)
                for i in curs.fetchall():
                    query.target_list += target_list_variables[0] + "." + i[0] + ","
                query.target_list = query.target_list.rstrip(",")

    keywords = converter_funcs.tuple_keywords_generator(query.query_body, 1)
    variables = converter_funcs.tuple_keywords_generator(query.query_body, 2)

    sql_query = "SELECT " + query.target_list + "\n FROM "

    for count, target_variable in enumerate(target_list_variables.values()):
        if count < len(target_list_variables) - 1:
            sql_query += table_variables_full_string_associations[target_variable] + ", "
        else:
            sql_query += table_variables_full_string_associations[target_variable]

    for count, keyword in enumerate(keywords):
        if count < len(keywords) - 1:
            sql_query += "\n WHERE " + keyword + "\n(SELECT * \n FROM " + table_variables_full_string_associations[variables[count]]
        else:
            sql_query += "\n WHERE " + keyword

    sql_query += ")" * (len(keywords) - 1)
    sql_query = sql_query.replace("\"", "'")
    return sql_query
