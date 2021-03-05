import subprocess

user = "apache"
host = "vaauswebwbt800.vba.va.gov"

privatekey = r'C:\Users\IITPSPIL\OneDrive - Department of Veterans Affairs\apps\Putty\P_Spillane_openssh.key'
command = 'svcs -a | grep vba'
command = 'ls -l'
fullcommand = 'ssh -q -T -i "' + privatekey + '" apache@vaauswebwbt800.vba.va.gov "'+command+'"'

results = subprocess.Popen(fullcommand,shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0]
results = results.decode().split(sep='\r\n')
for result in results:
    print (result)
print("done")

