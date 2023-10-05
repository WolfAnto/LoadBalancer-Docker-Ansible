# LoadBalancer-Docker-Ansible
Création d'un loadbalancer avec Docker et Ansible

Install Ansible :
```bash
sudo apt install Ansible
```

Création de la configuration Ansible :
Créer le dossier dans lequel nous réaliserons notre Loadbalancer.
```bash
mkdir loadbalancer-ansible
```

Placer vous dans le dossier précedement créer.
```bash
cd loadbalancer-ansible
```

Créer le fichier de configuration ansible.
Indiquer l'emplacement du fichier contenant vos hôtes et vos rôles.
```bash
nano ansible.cfg
```

![carbon(1)](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/ad1bc7b3-f20e-481a-a54e-d544902b2e63)

Indiquer vos groupes avec vos hôtes
```bash
nano hosts
```

![carbon](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/cb534ae9-4a26-49cc-8c4f-7d480fdfb07d)

Créer le playbook ansible.
```bash
nano apache.yml
```

![carbon(1)](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/a58e0658-e061-4385-9fe4-e6a16504398b)

Créer le dossier "Templates".
```bash
mkdir templates
```

Créer le fichier de configuration HAProxy pour le le loadbalancer.
```bash
nano templates/haproxy.cfg
```

![carbon(2)](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/a8a104ca-5be9-4b38-b132-5124e6362fe9)

Revenez au dossier précedent.
```bash
cd ..
```

Création de nos machines :
Créer le fichier "Dockerfile".
```bash
nano Dockerfile
```
```lang-docker
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
```

Monter votre Dockerfile et créer-en 3 exemplaires.
```bash
docker build -t ubuntu-ssh .
docker run -d -p 80:80 ubuntu-ssh
docker run -d -p ubuntu-ssh
docker run -d -p ubuntu-ssh
```

Application de la configuration Ansible :
Appliquer votre playbook
```bash
ansible-playbook apache.yml
```

Résultat :
Vérifier votre loadbalancer sur http://localhost.
```http
http://localhost
```
![image](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/df901b12-6857-4798-bd29-a219524711af)

![image](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/7c73de4e-1770-4fcf-a534-9a726cc1e026)

