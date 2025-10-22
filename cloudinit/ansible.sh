#! /bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common

sudo add-apt-repository --yes --update ppa:ansible/ansible

#Install Ansible
sudo apt install ansible -y

#Validate Ansible:
ansible --version
