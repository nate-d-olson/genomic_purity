import sqlite3

db = "ncbi.db"
unknown = -1
no_rank = "no rank"

def getNameByTaxid(taxid):   
    conn = sqlite3.connect(db)   
    cursor = conn.cursor()   
    command = "SELECT name FROM tree WHERE taxid = '" + str(taxid) + "';"   
    cursor.execute(command)   
    result = cursor.fetchone()   
    cursor.close()    
    if result:   
        return result[0]   
    else:   
        return "unknown" 

def getRankByTaxid(taxid):  
    conn = sqlite3.connect(db)  
    cursor = conn.cursor()  
    command = "SELECT rank FROM tree WHERE taxid = '" + str(taxid) + "';"  
    cursor.execute(command)  
    cursor.close()    
    result = cursor.fetchone()  
    if result:  
        return result[0]  
    else:  
        return no_rank  
        
def getParentByTaxid(taxid):  
    conn = sqlite3.connect(db)  
    cursor = conn.cursor()  
    command = "SELECT parent FROM tree WHERE taxid = '" + str(taxid) + "';"  
    cursor.execute(command)  
    result = cursor.fetchone()  
    cursor.close()  
    if result:  
        return result[0]  
    else:  
        return unknown
 
def getTaxidByName(name,limit=1):  
    conn = sqlite3.connect(db)  
    cursor = conn.cursor()  
    command = "SELECT taxid FROM tree WHERE name = '" + str(name) + "';"  
    cursor.execute(command)  
    results = cursor.fetchall()  
    cursor.close()  
    temp = []  
    for result in results:  
        temp += result[0]  
    if len(temp) != 0:  
        temp.sort()  
        return temp[:limit]  
    else:  
        return [unknown] 

def getTaxidByName(name,limit=1):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT taxid FROM tree WHERE name = '" + str(name) +  "';"
    
    cursor.execute(command)
    results = cursor.fetchall()
    cursor.close()
    
    temp = []
    for result in results:
        temp += result[0]
    
    if len(temp) != 0:
        temp.sort()
        return temp[:limit]
    else:
        return [unknown]

def getRankByTaxid(taxid):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT rank FROM tree WHERE taxid = '" + str(taxid) +  "';"
    cursor.execute(command)
    cursor.close()   
    result = cursor.fetchone()
    if result:
        return result[0]
    else:
        return no_rank

def getRankByName(name):

    try:
        return getRankByTaxid(getTaxidByName(name)[0])
    except:
        return no_rank

def getNameByTaxid(taxid):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT name FROM tree WHERE taxid = '" + str(taxid) +  "';"
    cursor.execute(command)
    
    result = cursor.fetchone()
    cursor.close()   
    if result:
        return result[0]
    else:
        return "unknown"

def getParentByTaxid(taxid):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT parent FROM tree WHERE taxid = '" + str(taxid) +  "';"
    cursor.execute(command)
    
    result = cursor.fetchone()
    cursor.close()
    if result:
        return result[0]
    else:
        return unknown

def getParentByName(name):

    try:
        return getParentByTaxid(getTaxidByName(name)[0])
    except:
        return unknown
    

def getPathByTaxid(taxid):
    path = []
    
    current_id = int(taxid)
    path.append(current_id)
    
    while current_id != 1 and current_id != unknown:
        #print current_id
        current_id = int(getParentByTaxid(current_id))
        path.append(current_id)
    
    return path[::-1]
    
    
def getTaxidByGi(gi):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT taxid FROM gi_taxid WHERE gi = '" + str(gi) +  "';"
    cursor.execute(command)
    
    result = cursor.fetchone()
    cursor.close()
    if result:
        return result[0]
    else:
        return unknown
    
def getTaxidByUid(uid):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT gi FROM uid_gi WHERE uid = '" + str(uid) +  "';"
    
    cursor.execute(command)
    gi = cursor.fetchone()
    cursor.close()
    result = getTaxidByGi(gi[0])
    
    if result:
        return result
    else:
        return unknown
    
def getSonsByTaxid(taxid):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT taxid FROM tree WHERE parent = '" + str(taxid) +  "';"
    result = [row[0] for row in cursor.execute(command)]
    cursor.close()
    return result


def getSonsByName(name):
    conn = sqlite3.connect(db)
    cursor = conn.cursor()
    command = "SELECT taxid FROM tree WHERE parent = '" + str(getTaxidByName(name)[0]) +  "';"
    result = [row[0] for row in cursor.execute(command)]
    cursor.close()
    return result


def getGiByTaxid(taxid):
    conn = sqlite3.connect(db)
    command = "SELECT gi FROM gi_taxid WHERE taxid = '" + str(taxid) +  "';"
    cursor = conn.cursor()
    #print command
    try:
        result = [row[0] for row in cursor.execute(command)] 
        
        cursor.close()
        return result
    except Exception, e:
        print e
