#!/bin/bash
echo "folder"
echo $0
part1="$(dirname "$0")"
echo $part1
part2="$(basename "$0")"
echo $part2
cd $part1
export file_contents=`cat version.html`
export ansible_inventory=`cat env.txt`
cd /home/ubuntu/cync-devops-ansible
case "${ansible_inventory}" in

dev)  echo "dev ping test"
    ansible -m ping -i "dynamic-inventory/${ansible_inventory}/ec2.py" "tag_Name_NDS_CYNC_DEV_CashApp_Passenger"
    ;;
dev2)  echo  "dev2 ping test"
    ansible -m ping -i "dynamic-inventory/${ansible_inventory}/ec2.py" "tag_Name_NDS_CYNC_DEV2_CashApp"
    ;;
*) echo "No proper ansible inventory environment passed"
   exit 1
   ;;
esac
if [[ ($? == 0) && ${ansible_inventory} != "" ]]
then
     echo "ping is successfully completed"
ansible-playbook playbooks/cashapp.yml -i "dynamic-inventory/$ansible_inventory" --extra-vars "cashapp_version=$file_contents"
else
    echo "ping test got failed No deployment!!"
    exit 1
fi
if [[  $? != 0 ]]
then
 echo "Playbook execution got failed, Deployment Failed"
exit 1
fi


