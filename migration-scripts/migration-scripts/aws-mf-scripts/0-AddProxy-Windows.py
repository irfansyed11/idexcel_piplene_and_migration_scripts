#########################################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.                    #
# SPDX-License-Identifier: MIT-0                                                        #
#                                                                                       #
# Permission is hereby granted, free of charge, to any person obtaining a copy of this  #
# software and associated documentation files (the "Software"), to deal in the Software #
# without restriction, including without limitation the rights to use, copy, modify,    #
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    #
# permit persons to whom the Software is furnished to do so.                            #
#                                                                                       #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   #
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         #
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    #
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     #
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        #
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                #
#########################################################################################

from __future__ import print_function
import sys
import argparse
import requests
import json
import subprocess
import getpass

with open('FactoryEndpoints.json') as json_file:
    endpoints = json.load(json_file)

serverendpoint = '/prod/user/servers'
appendpoint = '/prod/user/apps'

def Factorylogin(username, password, LoginHOST):
    login_data = {'username': username, 'password': password}
    r = requests.post(LoginHOST + '/prod/login',
                  data=json.dumps(login_data))
    if r.status_code == 200:
        print("Migration Factory : You have successfully logged in")
        print("")
        token = str(json.loads(r.text))
        return token
    if r.status_code == 502:
        print("ERROR: Incorrect username or password....")
        sys.exit(1)
    else:
        print(r.text)
        sys.exit(2)

def ServerList(waveid, token, UserHOST):
# Get all Apps and servers from migration factory
    auth = {"Authorization": token}
    servers = json.loads(requests.get(UserHOST + serverendpoint, headers=auth).text)
    #print(servers)
    apps = json.loads(requests.get(UserHOST + appendpoint, headers=auth).text)
    #print(apps)
    
    # Get App list
    applist = []
    for app in apps:
        if 'wave_id' in app:
            if str(app['wave_id']) == str(waveid):
                applist.append(app['app_id'])
    
    # Get Server List
    serverlist = []
    for app in applist:
        for server in servers:
            if app == server['app_id']:
                        if 'server_os' in server:
                                if 'server_fqdn' in server:
                                    if server['server_os'].lower() == "windows":
                                        serverlist.append(server['server_fqdn'])
                                else:
                                    print("ERROR: server_fqdn for server: " + server['server_name'] + " doesn't exist")
                                    sys.exit(4)
                        else:
                            print ('server_os attribute does not exist for server: ' + server['server_name'] + ", please update this attribute")
                            sys.exit(2)
                
    if len(serverlist) == 0:
        print("ERROR: Serverlist for wave: " + waveid + " is empty....")
        print("")
    else:
        print("successfully retrived server list")
        for s in serverlist:
            print(s)
        return serverlist

def main(arguments):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--Waveid', required=True)
    parser.add_argument('--ProxyServer', required=True)
    args = parser.parse_args(arguments)
    LoginHOST = endpoints['LoginApiUrl']
    UserHOST = endpoints['UserApiUrl']
    print("")
    print("****************************")
    print("*Login to Migration factory*")
    print("****************************")
    token = Factorylogin(input("Factory Username: ") , getpass.getpass('Factory Password: '), LoginHOST)

    print("****************************")
    print("*Getting Server List*")
    print("****************************")
    Servers = ServerList(args.Waveid, token, UserHOST)

    print("")
    print("*************************************")
    print("* Adding proxy on the source server *")
    print("*************************************")
    
    for server in Servers:
        command1 = "Invoke-Command -ComputerName " + server + " -ScriptBlock {[Environment]::SetEnvironmentVariable('https_proxy', 'https://" + args.ProxyServer + "/', 'Machine')}"
        command2 = "Invoke-Command -ComputerName " + server + " -ScriptBlock {Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' ProxyEnable -value 1}"
        command3 = "Invoke-Command -ComputerName " + server + " -ScriptBlock {Set-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' ProxyServer -value " + args.ProxyServer + "}"
        p1 = subprocess.Popen(["powershell.exe", command1], stdout=sys.stdout)
        p1.communicate()
        p2 = subprocess.Popen(["powershell.exe", command2], stdout=sys.stdout)
        p2.communicate()
        p3 = subprocess.Popen(["powershell.exe", command3], stdout=sys.stdout)
        p3.communicate()
        print("Proxy server added for server: " + server)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))