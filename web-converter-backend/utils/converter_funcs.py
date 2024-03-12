class TableVariables:
    def __init__(self, table_variables):
        self.associations = {}
        self.full_string_associations = {}
        self.variables = []
        self.tables = []
        self.table_variables = table_variables

    def get_table_variables(self, type):
        table_variables_list = [table_variable.lstrip() for table_variable in self.table_variables.split(",")]

        if type == "ASS":
            for table_variable in table_variables_list:
                self.associations[table_variable.split(" ")[2]] = table_variable.split(" ")[0]
            return self.associations

        if type == "ALL":
            for table_variable in table_variables_list:
                self.full_string_associations[table_variable.split(" ")[2]] = table_variable
            return self.full_string_associations

        if type == "IND":
            for count, table_variable in enumerate(table_variables_list):
                self.variables.append(self.table_variables.split(",")[count][-1])
            return self.variables


class TargetList:
    def __init__(self, target_list):
        self.variables = {}
        self.attributes = []
        self.full_strings = []
        self.target_list = target_list

    def get_target_list(self, type):
        variable_counter = 0
        target_list_elements = [target.lstrip() for target in self.target_list.split(",")]

        if type == "VAR":
            variables_list = [variable.split(".")[0] for variable in target_list_elements]

            for i in range(len(target_list_elements)):
                try:
                    if variables_list[i] != variables_list[i+1]:
                        self.variables[variable_counter] = variables_list[i]
                        variable_counter += 1
                except IndexError:
                    self.variables[variable_counter] = variables_list[i]
                    variable_counter += 1
            return self.variables
        
        if type == "ATR":
            columns_list = [column.split(".")[1] for column in target_list_elements]
            for i in range(len(target_list_elements)):
                position = columns_list[i].upper().find("AS")
                if position == -1:
                    self.attributes.append(columns_list[i])
                else:
                    self.attributes.append(columns_list[i][position+3::])
            return self.attributes


class QueryBody:
    def __init__(self, query_body):
        self.qwb = []
        self.qty = None
        self.qbx = []
        self.query_body = query_body

    def get_query_body(self, s):
        if s == "QWB":
            a = [" EXCEPT ", "#", " UNION ", " INTERSECT "]
            self.qwb = [self.query_body, "", "A"]

            if self.query_body.upper().find(a[0]) != -1:
                self.qwb = self.query_body.split(a[0])
                self.qwb.append(" EXCEPT ")
            
            if self.query_body.upper().find(a[1]) != -1:
                self.qwb = [self.query_body, "", " DELETE "]

            if self.query_body.upper().find(a[2]) != -1:
                self.qwb = self.query_body.split(a[2])

            if self.query_body.upper().find(a[3]) != -1:
                self.qwb = self.query_body.split(a[3])
                self.qwb.append(" INTERSECT ")
            
            return self.qwb
        
        if s == "QTY":
            self.qty = self.query_body.count("[")
            return self.qty

        if s == "QBX":
            a1 = self.query_body.split("[")
            a2 = []
            a3 = []

            j = 0
            for x in a1:
                if x.find("]") != -1:
                    a2.insert(j, x.split("]")[0])
                    j += 1

            j = 0
            for x1 in a2:
                if x1.find(" AND ") == -1:
                    self.qbx.insert(j, x1)
                    j += 1
                else:
                    a3 = x1.split(" AND ")
                    for x2 in a3:
                        self.qbx.insert(j, x2)
                        j += 1
                        
            return self.qbx


def qby(tv, gl):
    aTV_IND = TableVariables(tv).get_table_variables("IND")
    aGL_VAR = TargetList(gl).get_target_list("VAR")

    q = []
    j = 0
    for x in aTV_IND:
        if x not in aGL_VAR.values():
            q.insert(j, x)
            j += 1
    
    return q


def qb_01(qb, gl, x):
    aGL_VAR = TargetList(gl).get_target_list("VAR")

    qb_qty = qb.count("[")
    m_qb0 = qb.split("[")
    m_qb2 = []

    for i in range(qb_qty + 1):
        m_qb0[i] = m_qb0[i].strip("()")

    if qb_qty == 0:
        m_qb2.append(qb)
    
    if qb_qty > 0:
        for i in range(qb_qty + 1):
            if i == 0:
                m_qb2.append(m_qb0[0]) 
            else:
                m_qb2.append(m_qb0.split("]")[1])

    m_qb1 = list(set(m_qb2, aGL_VAR))[:qb_qty]

    if x == 1:
        return m_qb1
    
    if x == 2:
        return m_qb2


def qb_02(qb, x):
    qb_qty = qb.count("[")
    m_qb0 = qb.split("[")

    for i in range(qb_qty + 1):
        m_qb0[i] = m_qb0[i].strip("()")
    
    s_qb0 = m_qb0[qb_qty].rstrip("]")

    m_qb2 = []
    for i in range(qb_qty):
        if i == 0:
            m_qb2.append(m_qb0[i])
        else:
            if len(m_qb0[i].split("]")) > 0:
                m_qb2.append(m_qb0[i].split("]")[0])
            
    aGL_VAR = TargetList(s_qb0).get_target_list("VAR")
    m_qb1 = list(set(m_qb2) - set(aGL_VAR))[:qb_qty]

    if x == 0:
        return s_qb0

    if x == 1:
        return m_qb1

    if x == 2:
        return m_qb2
    

def sql_1(qb, tv, gl):
    aQB_QBX = QueryBody(qb).get_query_body("QBX")
    aTV_ALL = TableVariables(tv).get_table_variables("ALL")
    aGL_VAR = TargetList(gl).get_target_list("VAR")
    w1 = qby(tv, gl)

    tvQty = tv.count(",") + 1
    glQty = len(aGL_VAR)
    qbQty = tvQty - glQty
    prQty = len(aQB_QBX)
    
    QuerySQL = "SELECT " + gl + "\n FROM "
    
    if prQty == 0:
        QuerySQL += tv
        return QuerySQL

    for i in range(glQty):
        if i < glQty - 1:
            QuerySQL += aTV_ALL[aGL_VAR[i]] + ", "
        else:
            QuerySQL += aTV_ALL[aGL_VAR[i]]

    QuerySQL += "\n WHERE "

    if not w1:
        if aQB_QBX[prQty - 1].find(",") == -1:
            wprQty = prQty - 1
        else:
            wprQty = prQty - 2
        
        for i in range(wprQty + 1):
            if i < wprQty:
                QuerySQL += aQB_QBX[i] + " AND "
            else:
                QuerySQL += aQB_QBX[i]

        return QuerySQL
    else:
        j = 0
        k = 0
        M1 = []
        M2 = []

        for x in aQB_QBX:
            for i in range(qbQty):
                if x.find(w1[i]) != -1 and x not in M2:
                    M2.append(x)
                    j += 1

        cM2 = len(M2)

        if prQty == cM2:
            QuerySQL += " EXISTS \n ( SELECT * \n FROM "

            for i in range(qbQty):
                if i < qbQty - 1:
                    QuerySQL += aTV_ALL[w1[i]] + ", "
                else:
                    QuerySQL += aTV_ALL[w1[i]]
            
            QuerySQL += "\n WHERE "

            for i in range(cM2):
                if i < cM2 - 1:
                    QuerySQL += M2[i] + " AND "
                else:
                    QuerySQL += M2[i] + " ) "
            
            return QuerySQL
        
        for x in list(set(aQB_QBX) - set(M2)):
            M1.append(x)
            k += 1
        
        cM1 = len(M1)

        for i in range(cM1):
            if i < cM1 - 1:
                QuerySQL += M1[i] + " AND "
            else:
                QuerySQL += M1[i]

        if cM2 > 0:
            if cM1 != 0:
                QuerySQL += " AND EXISTS \n ("
            else:
                QuerySQL += " EXISTS \n ("

            QuerySQL += " SELECT * \n FROM "

            for i in range(qbQty):
                if i < qbQty - 1:
                    QuerySQL += aTV_ALL[w1[i]] + ", "
                else:
                    QuerySQL += aTV_ALL[w1[i]]

            QuerySQL += "\n WHERE "

            for i in range(cM2):
                if i < cM2 - 1:
                    QuerySQL += M2[i] + " AND "
                else:
                    QuerySQL += M2[i] + " ) "
    
    return QuerySQL


def tuple_keywords_generator(query_body, type):
    query_body_list = query_body.split("[")
    keywords = []
    variables = []

    for count, query_body_element in enumerate(query_body_list):
        query_body_element = query_body_element.strip().strip("]").replace("FORALL", "NOT EXISTS").replace("IMPLY", "AND NOT")
        if count < query_body.count("["):
            keywords.append(query_body_element[0:-1])
            variables.append(query_body_element[-1])
        else:
            keywords.append(query_body_element)

    if type == 1:
        return keywords
    if type == 2:
        return variables
