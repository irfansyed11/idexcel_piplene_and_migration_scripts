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
import paramiko
import socket

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

def ServerList(waveid, token, UserHOST, Projectname):
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
                if Projectname != "":
                    if str(app['cloudendure_projectname']) == str(Projectname):
                        applist.append(app['app_id'])
                else:
                    applist.append(app['app_id'])
    
    #print(apps)
    #print(servers)
    # Get Server List
    servers_Windows = []
    servers_Linux = []
    for app in applist:
        for server in servers:
            if app == server['app_id']:
                if 'server_os' in server:
                    if 'server_fqdn' in server:
                        if server['server_os'].lower() == "windows":
                            servers_Windows.append(server)
                        if server['server_os'].lower() == "linux":
                            servers_Linux.append(server)
                    else:
                        print("ERROR: server_fqdn for server: " + server['server_name'] + " doesn't exist")
                        sys.exit(4)
                else:
                    print ('server_os attribute does not exist for server: ' + server['server_name'] + ", please update this attribute")
                    sys.exit(2)
    if len(servers_Windows) == 0 and len(servers_Linux) == 0:
        print("ERROR: Serverlist for wave: " + waveid + " in CE Project " + Projectname + " is empty....")
        print("")
    else:
        print("successfully retrieved server list")
        print("")
        if len(servers_Windows) > 0:
            print("*** Windows Server List")
            for server in servers_Windows:
                print(server['server_name'])
        print("")
        if len(servers_Linux) > 0:
            print("*** Linux Server List ***")
            print("")
            for server in servers_Linux:
                print(server['server_name'])
        return servers_Windows, servers_Linux

def check_windows(Servers_Windows, RDPPort):
    for s in Servers_Windows:
        command = "(Test-NetConnection -ComputerName " + s["server_fqdn"] + " -Port " + RDPPort + ").TcpTestSucceeded"
        p = subprocess.Popen(["powershell.exe", command], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        tcpresult = False
        output, error = p.communicate()
        if (output):
            print(" RDP test to Server " + s["server_fqdn"] + " : Pass")
        else:
            print(" RDP test to Server " + s["server_fqdn"] + " : Fail")


def check_ssh_connectivity(ip, user_name, pass_key, is_key, SSHPort):
    ssh, error = open_ssh(ip, user_name, pass_key, is_key, SSHPort)
    if ssh is None or len(error) > 0:
        print(" SSH test to server " + ip + " : Fail")
        return None
    else:
        print(" SSH test to server " + ip + " : Pass")

def open_ssh(host, username, key_pwd, using_key, SSHPort):
    ssh = None
    error = ''
    try:
        if using_key:
            private_key = paramiko.RSAKey.from_private_key_file(key_pwd)
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(hostname=host, port=SSHPort, username=username, pkey=private_key)
        else:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(hostname=host, username=username, password=key_pwd)
    except IOError as io_error:
        error = "Unable to connect to host " + host + " with username " + \
                username + " due to " + str(io_error)
    except paramiko.SSHException as ssh_exception:
        error = "Unable to connect to host " + host + " with username " + \
                username + " due to " + str(ssh_exception)
    return ssh, error

def main(arguments):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--Waveid', required=True)
    parser.add_argument('--SSHPort', default="22")
    parser.add_argument('--RDPPort', default="3389")
    parser.add_argument('--CloudEndureProjectName', default="")
    args = parser.parse_args(arguments)
    LoginHOST = endpoints['LoginApiUrl']
    UserHOST = endpoints['UserApiUrl']
    print("")
    print("****************************")
    print("*Login to Migration factory*")
    print("****************************")
    token = Factorylogin(input("Factory Username: ") , getpass.getpass('Factory Password: '), LoginHOST)

    print("****************************")
    print("*** Getting Server List ****")
    print("****************************")
    Servers_Windows, Servers_Linux = ServerList(args.Waveid, token, UserHOST, args.CloudEndureProjectName)
    print("")
    windows_results = []
    linux_results = []
    user_name = ''
    pass_key = ''
    has_key = ''

    if len(Servers_Linux) > 0:
        print("**************************************")
        print("* Enter Linux Sudo username/password *")
        print("**************************************")
        user_name = input("Linux Username: ")
        has_key = input("If you use a private key to login, press [Y] or if use password press [N]: ")
        if has_key.lower() in 'y':
            pass_key = getpass.getpass('Private Key: ')
        else:
            pass_key_first = getpass.getpass('Linux Password: ')
            pass_key_second = getpass.getpass('Re-enter Password: ')
            while(pass_key_first != pass_key_second):
                print("Password mismatch, please try again!")
                pass_key_first = getpass.getpass('Linux Password: ')
                pass_key_second = getpass.getpass('Re-enter Password: ')
            pass_key = pass_key_second

    if len(Servers_Windows) > 0:
        print("")
        print("*********************************************")
        print("*Checking RDP Access for Windows servers*")
        print("*********************************************")
        print("")
        check_windows(Servers_Windows, args.RDPPort)
   
    if len(Servers_Linux) > 0:
        print("")
        print("********************************************")
        print("*Checking SSH connections for Linux servers*")
        print("********************************************")
        print("")
        for s in Servers_Linux:
            check_ssh_connectivity(s["server_fqdn"], user_name, pass_key, has_key.lower() in 'y', args.SSHPort)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))