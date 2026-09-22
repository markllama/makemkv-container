#!/bin/bash
echo 'mark ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/mark
sudo dnf install -y make ansible
