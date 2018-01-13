FROM ubuntu:16.04

# Install sudo because it's not in ubuntu's official image anymore.
RUN apt-get update && apt-get install -y sudo

# Add non root user.
RUN  useradd -m admin && echo "admin:admin" | chpasswd && adduser admin sudo
USER admin

COPY new-ubuntu-install.sh /home/admin/install.sh
WORKDIR /home/admin
RUN printf "\n***************************************************\nTo test, run\n\n\$ bash install.sh\n\nPassword is 'admin'\n***************************************************\n"
