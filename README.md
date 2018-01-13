# Scripts and dot files
This repository contains some scripts and dotfiles as well as an 
install script for a new ubuntu installation.

On a fresh ubuntu installation, run the following
```bash
$ sudo apt-get install -y git && \
  git clone https://github.com/johnPertoft/scripts-and-dotfiles && \
  bash scripts-and-dotfiles/new-ubuntu-install.sh
```

An Ubuntu 16.04 image is included in this repository to test the install script. 
It probably won't work for some graphical installs etc. And it's not automated but 
it can be tried by running the following
```bash
$ bash docker/test.sh
```
