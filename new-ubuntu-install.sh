#!/bin/bash

THIS_REPO_DIR="scripts-and-dotfiles"

# If an install step can't be completed, add it here and print at the end.
extra_instructions=()

# Run all following commands from home dir.
pushd ~

# Install apt packages from default repositories.
sudo apt-get update
sudo apt-get install -y \
  git \
  vim \
  curl \
  wget \
  unzip \
  htop \
  openvpn \
  apt-transport-https \
  ca-certificates \
  software-properties-common \
  build-essential \
  cmake \
  pkg-config \
  libopenblas-dev \
  liblapack-dev \
  openjdk-8-jdk \
  silversearcher-ag

# Add Google repository.
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# Add docker repository.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"

# Install apt-packages from added external repositories.
sudo apt-get update
sudo apt-get install -y \
    google-chrome-stable \
    docker-ce

# Allow user to use docker without sudo. (Requires restart or 'newgrp docker' for each shell).
sudo groupadd docker
sudo gpasswd -a ${USER} docker
newgrp docker

# Optional install for nvidia driver.
read -p "Install nvidia driver [y|n]? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # TODO: Need to test this.

    # Install nvidia driver.
    sudo add-apt-repository ppa:graphics-drivers/ppa
    sudo apt-get update
    sudo apt-get install nvidia-387 nvidia-settings

    # Install cuda.
    printf "Manual install of cuda. Probably **don't** install the display drivers asked about in the install script.\n"
    wget https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda_9.1.85_387.26_linux \
        -O cuda-install.run
    sudo sh cuda-install.run
    nvcc --version  # Verify install.
    # TODO: This can be done with --silent, see defaults/params
    # TODO: Need to manually update .bashrc?

    # Install cudnn.
    extra_instructions+=("cudnn requires a log in + manual download")

else
    echo "Not installing nvidia driver."
fi

# Directory for non-apt program installs.
NONAPT_INSTALL_PATH=$HOME/opt
mkdir ~/opt

# Directory for development.
mkdir -p ~/dev

# Depending on how this script was invoked we may have to clone the
# repository that contains it.
if [ ! -d "$THIS_REPO_DIR" ]; then
  git clone https://github.com/johnPertoft/scripts-and-dotfiles ${THIS_REPO_DIR}
fi

# Install gradle.
wget https://services.gradle.org/distributions/gradle-4.4.1-bin.zip -O gradle.zip
unzip gradle.zip && rm gradle.zip
mv gradle* opt/gradle
printf '\nexport PATH="/home/admin/opt/gradle/bin:$PATH"' >> .bashrc

# Install bazel.
echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get install -y bazel

# Python (Anaconda)
wget https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh -O anaconda-install.sh
sh anaconda-install.sh -b -p ${NONAPT_INSTALL_PATH}/anaconda3
printf '\nexport PATH="/home/admin/opt/anaconda3/bin:$PATH"' >> .bashrc
rm anaconda-install.sh

# Python packages.
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
jupyter nbextension enable scratchpad/main

# fzf search tool
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && .fzf/install --all

# pathogen.vim plugin runtime manager.
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install vim plugins.
pushd ~/.vim/bundle
git clone https://github.com/tpope/vim-sensible.git  # sensible.vim for some defaults.
git clone https://https://github.com/scrooloose/nerdtree  # nerdtree file explorer.
popd

# Copy over .vimrc.
cp ${THIS_REPO_DIR}/dotfiles/.vimrc ~/.vimrc

read -p "Generate ssh key pair [y|n]? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    ssh-keygen
else
    echo "Not generating ssh key pair."
fi

# Misc bash stuff.
printf "\n" >> .bashrc
printf "export PS1='\w \$ ' # Simpler prompt" >> .bashrc

# Make sure any changes to .bashrc are taken into effect.
source ~/.bashrc

# Print any remaining instructions for manual installs.
for i in "${extra_instructions[@]}"; do echo "$i" ; done

# Clean up.
rm -rf ${THIS_REPO_DIR}

# Installation complete.
printf "\nInstallation complete.\nSome stuff may require a restart (e.g. docker without sudo)."
read -p "Restart now [y|n]? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo shutdown -r now
fi

popd
