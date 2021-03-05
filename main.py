#!/c:/users/iitpspil/appdata/Local/Programs/Python39/python.exe

#pip config set global.trusted-host "files.pythonhosted.org pypi.org pypi.python.org"

#   --trusted-host files.pythonhosted.org --trusted-host pypi.org --trusted-host pypi.python.org
#C:/Users/IITPSPIL/AppData/Local/Programs/Python/Python39/python.exe c:\Users\IITPSPIL\.vscode\extensions\ms-python.python-2021.2.582707922\pythonFiles\pyvsc-run-isolated.py pip install -U pylint --user --trusted-host files.pythonhosted.org --trusted-host pypi.org --trusted-host pypi.python.org
#C:/Users/IITPSPIL/AppData/Local/Programs/Python/Python39/python.exe c:\Users\IITPSPIL\.vscode\extensions\ms-python.python-2021.2.582707922\pythonFiles\pyvsc-run-isolated.py pip install -U autopep8 --user --trusted-host pypi.org --trusted-host pypi.python.org


# sqlite > .open test.db
# sqlite > create table table1(id num, url text, server text)

# sqlite > .open test.db
# sqlite > insert into table1(id, url, server) values(1, "http://bepdev.vba.va.gov", "vaauswebwbt800")
# sqlite > insert into table1(id, url, server) values(2, "http://bepwebdevl.vba.va.gov", "vaauswebwbt800")

#%%
import socket
import os
import sqlite3
#conn=sqlite3.connect("C:\\Users\\IITPSPIL\\OneDrive - Department of Veterans Affairs\\python\\bgs\\bgs.db")
#c=conn.cursor()
# SQL="""Select * from servers;"""
# rows = c.execute(SQL).fetchall()
# for x in rows:
#     print(x)

#%%
# SQL2 = """Select urls.location, servers.location,
# urls.servers, servers.servers,
# urls.URL,servers.servername from urls
# inner join servers 
# on urls.Location = servers.Location
#    and urls.servers = servers.servers
# WHERE urls.url ='vbmsprod.vba.va.gov' """
# rows = c.execute(SQL2).fetchall()
# for x in rows:
#     print (x)

# %%

# db = "C:\\Users\\IITPSPIL\\OneDrive - Department of Veterans Affairs\\python\\bgs\\bgs.db"
# conn = sqlite3.connect(db)
# c = conn.cursor()
# SQL = """Select * from urls;"""
# rows = c.execute(SQL).fetchall()
# for x in rows:
#     print(x)

# num_fields = len(c.description)
# field_names = [i[0] for i in c.description]

# sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# result = sock.connect_ex(('vbmsprep.vba.va.gov', 443))
# if result == 0:
#    print ("Port is open")
# else:
#    print ("Port is not open")
# sock.close()

# %%

# class urlclass:
#     x = 5
#     def __str__(self):
#         return str(self.__class__) + ": " + str(self.__dict__)
# p1 = urlclass()
# print(p1.x)

# class urlclass:
#     def __init__(self, iam, env):
#         self.iam = iam
#         self.env = env
 
#     def __str__(self):
#         return str(self.__class__) + ": " + str(self.__dict__)

# url = urlclass('my_name', 'some_symbol')
# print(url)


def testport(url, port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = "Port Open" if (sock.connect_ex(
            (str(url), int(port))) == 0) else "Port Closed"
        sock.close()
        return result
        #print("{:35} 443: {:9} 80: {:9}".format(x["url"], result443, result80))
    except:
        #print("{:35} not found".format(x["url"]))
        return "Url Not Found"




thisworkstation = socket.gethostname().lower()
urls = []
db = "C:\\Users\\IITPSPIL\\OneDrive - Department of Veterans Affairs\\python\\bgs\\bgs.db"
conn = sqlite3.connect(db)
conn.row_factory = sqlite3.Row # Here's the magic!

SQL = "select * from urls"
SQLONSERVERS = """select servers,env,location,StartStopService,url,wl12,wl12ssl,fqdn,ListenPort,servername 
            from urlservers
            ;"""
SQLWLSERVERS = """select DISTINCT servers,env,location,StartStopService,url,wl12,wl12ssl,ListenPort  
            from urlservers
            where url = ?;"""
SQLURLS = """select DISTINCT env,location,StartStopService,url,wl12,wl12ssl,ListenPort from urlservers;"""
cursor = conn.execute(SQLURLS)

for row in cursor:
    #print(row['IAM'])
    if row["url"] == "bepdev.vba.va.gov":
        urls.append(row)
ports = 80, 443
for x in urls:
    portresults={}
    print("{:35} ".format(x["url"]))
    for port in ports:
        portresults[str(port)] = testport(x["url"],port)
        #print("\t{} {}".format(port, portresults[str(port)]), end="")
        print("\t{:<4} {}".format(port, portresults[str(port)]))
    else:
        print()

    cursor2 = conn.execute(SQLWLSERVERS, (x["url"],))
    wlservers=[]
    for row in cursor2:
        wlservers.append(row)
    for wlserver in wlservers:
        for wltest in wlserver["wl12"].split(','):
            wlip = wltest.split(':')[0]
            wlport = wltest.split(':')[1]
            print("\t{:17} {:7} {:7} {:20}".format(
                wlip, wlport, x["wl12ssl"], testport(wlip, wlport)))
            #print(wlip, wlport, testport(wlip, wlport), end="")
    else:
        print




