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

serverendpoint = '/prod/user/servers'
appendpoint = '/prod/user/apps'

with open('FactoryEndpoints.json') as json_file:
    endpoints = json.load(json_file)

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

def ServerList(waveid, token, UserHOST, serverendpoint, appendpoint):
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
    winServerlist = []
    linuxServerlist = []
    for app in applist:
        for server in servers:
            if app == server['app_id']:
                if 'server_os' in server:
                    if 'server_fqdn' in server:
                        if server['server_os'].lower() == "windows":
                            winServerlist.append(server['server_name'])
                        elif server['server_os'].lower() == 'linux':
                            linuxServerlist.append(server['server_fqdn'])
                    else:
                        print("ERROR: server_fqdn for server: " + server['server_name'] + " doesn't exist")
    if len(winServerlist) == 0 and len(linuxServerlist) == 0:
        print("ERROR: Serverlist for wave: " + waveid + " is empty....")
        print("")
    else:
        return winServerlist, linuxServerlist

def open_ssh(host, username, key_pwd, using_key):
    ssh = None
    try:
        if using_key:
            private_key = paramiko.RSAKey.from_private_key_file(key_pwd)
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(hostname=host, username=username, pkey=private_key)
        else:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(hostname=host, username=username, password=key_pwd)
    except IOError as io_error:
        error = "Unable to connect to host " + host + " with username " + \
                username + " due to " + str(io_error)
        print(error)
    except paramiko.SSHException as ssh_exception:
        error = "Unable to connect to host " + host + " with username " + \
                username + " due to " + str(ssh_exception)
        print(error)
    return ssh


def execute_cmd(host, username, key, cmd, using_key):
    output = ''
    error = ''
    ssh = None
    try:
        ssh = open_ssh(host, username, key, using_key)
        if ssh is None:
            error = "Not able to get the SSH connection for the host " + host
            print(error)
        else:
            stdin, stdout, stderr = ssh.exec_command(cmd)
            for line in stdout.readlines():
                output = output + line
            for line in stderr.readlines():
                error = error + line
    except IOError as io_error:
        error = "Unable to execute the command " + cmd + " on " +host+ " due to " + \
                str(io_error)
        print(error)
    except paramiko.SSHException as ssh_exception:
        error = "Unable to execute the command " + cmd + " on " +host+ " due to " + \
                str(ssh_exception)
        print(error)
    except Exception as e:
        error = "Unable to execute the command " + cmd + " on " +host+ " due to " + str(e)
        print(error)
    finally:
        if ssh is not None:
            ssh.close()
    return output, error


def main(arguments):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--Waveid', required=True)
    args = parser.parse_args(arguments)
    LoginHOST = endpoints['LoginApiUrl']
    UserHOST = endpoints['UserApiUrl']

    print("****************************")
    print("*Login to Migration factory*")
    print("****************************")
    token = Factorylogin(input("Factory Username: ") , getpass.getpass('Factory Password: '), LoginHOST)
    winServers, linuxServers = ServerList(args.Waveid, token, UserHOST,
                                   serverendpoint, appendpoint)
    if len(winServers) > 0:
        print("****************************")
        print("*Shutting down Windows servers*")
        print("****************************")
        for s in winServers:
            command = "Stop-Computer -ComputerName " + s + " -Force"
            print("Shutting down server: " + s)
            p = subprocess.Popen(["powershell.exe", command], stdout=sys.stdout)
            p.communicate()
    if len(linuxServers) > 0:
        print("")
        print("****************************")
        print("*Shutting down Linux servers*")
        print("****************************")
        print("")
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
        print("")
        for s in linuxServers:
            output, error = execute_cmd(s, user_name, pass_key, "sudo shutdown now", has_key in 'y')
            if not error:
                print("Shutdown successful on " + s)
            else:
                print("unable to shutdown server " + s + " due to " + error)
            print("")

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))