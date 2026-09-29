#!/bin/bash
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USER}
sudo dnf install -y make ansible
