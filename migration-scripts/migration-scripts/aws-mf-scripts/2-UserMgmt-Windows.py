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
import time
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
    
    #print(apps)
    #print(servers)
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
        print("ERROR: Windows Serverlist for wave: " + waveid + " is empty....")
        sys.exit(5)
        print("")
    else:
        print("successfully retrived server list")
        for server in serverlist:
            print(server)
        return serverlist

def main(arguments):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--Waveid', required=True)
    args = parser.parse_args(arguments)
    LoginHOST = endpoints['LoginApiUrl']
    UserHOST = endpoints['UserApiUrl']
    choice_flag = True
    choice = 3
    while choice_flag:
        print("1. Create user")
        print("2. Delete user")
        print("3. Exit")
        choice = input("Enter your choice [1-3]: ")
        if choice == '3':
            sys.exit(0)
        elif choice != '1' and choice != '2':
            print("Please provide a valid option [1, 2, 3]")
            print("")
        else:
            choice_flag = False
    print("****************************")
    print("*Login to Migration factory*")
    print("****************************")
    token = Factorylogin(input("Factory Username: ") , getpass.getpass('Factory Password: '), LoginHOST)

    print("****************************")
    print("*Getting Server List*")
    print("****************************")
    Servers = ServerList(args.Waveid, token, UserHOST)
    print("")
    if choice == '1':
        print("")
        print("************************************")
        print("*Creating local admin on the server*")
        print("************************************")
        LocalAdminUser = input("Enter Local admin username: ")
        localadmin_pass_first = getpass.getpass('Local admin Password: ')
        localadmin_pass_second = getpass.getpass('Re-enter Password: ')
        while(localadmin_pass_first != localadmin_pass_second):
            print("Password mismatch, please try again!")
            localadmin_pass_first = getpass.getpass('Local admin Password: ')
            localadmin_pass_second = getpass.getpass('Re-enter Password: ')
        localadmin_pass = localadmin_pass_second
        print("")
        for s in Servers:
            command1 = "Invoke-Command -ComputerName " + s + " -ScriptBlock {net user " + LocalAdminUser + " " + localadmin_pass + " /add}"
            print("------------------------------------------------------")
            print("- Creating a local user on: " + s + " -")
            print("------------------------------------------------------")
            p = subprocess.Popen(["powershell.exe", command1], stdout=sys.stdout)
            p.communicate()
            command2 = "Invoke-Command -ComputerName " + s + " -ScriptBlock {net localgroup Administrators " + LocalAdminUser + " /add}"
            print("Adding user to local admin group on server: " + s)
            p = subprocess.Popen(["powershell.exe", command2], stdout=sys.stdout)
            p.communicate()
        print("")
    else:
        print("")
        print("*************************************")
        print("*Deleting local admin on the servers*")
        print("*************************************")
        print("")
        LocalAdminUser = input("Enter local admin UserName to be deleted: ")
        print("")
        for s in Servers:
            command1 = "Invoke-Command -ComputerName " + s + " -ScriptBlock {net user " + LocalAdminUser + " /delete}"
            print("------------------------------------------------------")
            print("- Deleting a local user on: " + s + " -")
            print("------------------------------------------------------")
            p = subprocess.Popen(["powershell.exe", command1], stdout=sys.stdout)
            p.communicate()

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))