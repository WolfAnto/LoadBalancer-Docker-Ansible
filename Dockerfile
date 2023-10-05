
# Use the official image as a parent image
FROM ubuntu

# Add Source List
RUN echo "" > /etc/apt/sources.list

RUN echo "deb http://fr.archive.ubuntu.com/ubuntu/ jammy main restricted"  >> /etc/apt/sources.list \
    && echo "deb http://fr.archive.ubuntu.com/ubuntu/ jammy-updates main restricted"  >> /etc/apt/sources.list \
    && echo "deb http://fr.archive.ubuntu.com/ubuntu/ jammy universe"  >> /etc/apt/sources.list \
    && echo "deb http://fr.archive.ubuntu.com/ubuntu/ jammy-updates universe"  >> /etc/apt/sources.list \
    && echo "deb http://fr.archive.ubuntu.com/ubuntu/ jammy multiverse"  >> /etc/apt/sources.list \
    && echo "deb http://fr.archive.ubuntu.com/ubuntu/ jammy-updates multiverse"  >> /etc/apt/sources.list \
    && echo "deb http://fr.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse"  >> /etc/apt/sources.list \
    && echo "deb http://security.ubuntu.com/ubuntu jammy-security main restricted"  >> /etc/apt/sources.list \
    && echo "deb http://security.ubuntu.com/ubuntu jammy-security universe"  >> /etc/apt/sources.list \
    && echo "deb http://security.ubuntu.com/ubuntu jammy-security multiverse"  >> /etc/apt/sources.list

# Update the system
RUN apt-get update && apt-get upgrade -y

# Install Sudo and iproute2
RUN apt-get -y install sudo && apt-get -y install iproute2

# Install OpenSSH Server
RUN apt-get install -y openssh-server

# Set up configuration for SSH
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# SSH login fix. Otherwise, user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN /etc/init.d/ssh start


ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Expose the SSH port
EXPOSE 22
EXPOSE 80

# Run SSH
CMD ["/usr/sbin/sshd", "-D"]
