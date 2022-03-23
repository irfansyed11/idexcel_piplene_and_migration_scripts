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
import paramiko
import sys
import argparse
import requests
import json
import getpass
import os


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
    servers = json.loads(
        requests.get(UserHOST + serverendpoint, headers=auth).text)
    # print(servers)
    apps = json.loads(requests.get(UserHOST + appendpoint, headers=auth).text)
    # print(apps)

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
                        if server['server_os'].lower() == "linux":
                            serverlist.append(server['server_fqdn'])
                    else:
                        print("ERROR: server_fqdn for server: " + server[
                            'server_name'] + " doesn't exist")
                        sys.exit(4)
                else:
                    print('server_os attribute does not exist for server: ' +
                          server[
                              'server_name'] + ", please update this attribute")
                    sys.exit(2)

    if len(serverlist) == 0:
        print("ERROR: Serverlist for wave: " + waveid + " is empty....")
        print("")
        sys.exit(5)
    else:
        print("successfully retrived server list")
        for s in serverlist:
            print(s)
        print("")
        return serverlist


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


def upload_files(host, username, key_pwd, using_key, local_file_path):
    error = ''
    file_path = local_file_path
    ssh = None
    ftp = None
    try:
        ssh = open_ssh(host, username, key_pwd, using_key)
        tmp_c_command = ssh.exec_command("[ -d /tmp/copy_ce_files ] && echo 'Directory exists' || mkdir /tmp/copy_ce_files")
        post_launch_command = ssh.exec_command("[ -d '/boot/post_launch' ] && echo 'Directory exists' || sudo mkdir /boot/post_launch")
        ftp = ssh.open_sftp()
        if os.path.isfile(file_path):
            filename = file_path.split("/")
            filename = filename[-1]
            ftp.put(file_path, '/tmp/copy_ce_files/' + filename)
        else:
            for file in os.listdir(local_file_path):
                file_path = os.path.join(local_file_path, file)
                if os.path.isfile(file_path):
                    ftp.put(file_path, '/tmp/copy_ce_files/' + file)
                else:
                    print('ignoring the subdirectories... ' + file_path)
        copy_command = ssh.exec_command("sudo cp /tmp/copy_ce_files/* /boot/post_launch && sudo chown cloudendure /boot/post_launch/* && sudo chmod +x /boot/post_launch/*")
    except Exception as e:
        error = "Copying " + file_path + " to " + \
                "/boot/post_launch" + " on host " + host + " failed due to " + \
                str(e)
        print(error)
    finally:
        if ftp is not None:
            ftp.close()
        if ssh is not None:
            ssh.close()
    return error


def main(arguments):
    parser = argparse.ArgumentParser(description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--Waveid', required=True)
    parser.add_argument('--Source', required=True)
    args = parser.parse_args(arguments)
    LoginHOST = endpoints['LoginApiUrl']
    UserHOST = endpoints['UserApiUrl']
    print("")
    print("****************************")
    print("*Login to Migration factory*")
    print("****************************")
    token = Factorylogin(input("Factory Username: "),
                         getpass.getpass('Factory Password: '), LoginHOST)

    print("****************************")
    print("*Getting Server List*")
    print("****************************")
    servers = ServerList(args.Waveid, token, UserHOST)

    print("*****************************************")
    print("*Provide Linux credentials to copy files*")
    print("*****************************************")
    user_name = input("Linux Username: ")
    has_key = input("If you use a private key to login, press [Y] or if use password press [N]: ")
    has_key = has_key.lower()
    if has_key in 'y':
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
    print("*************************************")
    print("*Copying files to post_launch folder*")
    print("*************************************")
    print("")
    for server in servers:
        err_reason = upload_files(server, user_name, pass_key, has_key in 'y',
                    args.Source)
        if not err_reason:
            print("Successfully copied files to " + server)
        else:
            print("Unable to copy files to " + server + " due to " + err_reason)
        print("")


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))