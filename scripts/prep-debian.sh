#!/bin/bash
sudo apt update
sudo apt -y install locales
sudo sed -i '/^# en_US.UTF-8 /s/^# //' /etc/locale.gen
sudo locale-gen

sudo apt -y install ansible
