#!/bin/bash

echo "mark ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/mark
sudo dnf -y install ansible make
