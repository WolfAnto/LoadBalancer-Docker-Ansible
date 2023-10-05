# LoadBalancer-Docker-Ansible
Création d'un loadbalancer avec Docker et Ansible

Install Ansible :
```
sudo apt install Ansible
```
Création de la configuration Ansible :
```
mkdir loadbalancer-ansible
```

```
cd loadbalancer-ansible
```

```
nano ansible.cfg
```
```
[defaults]
inventory = hosts
host_key_checking = false
roles_path = /
```

```
nano hosts
```
```
[loadbalancer]
172.17.0.2 ansible_ssh_pass=root ansible_ssh_user=root

[web]
172.17.0.3 ansible_ssh_pass=root ansible_ssh_user=root
172.17.0.4 ansible_ssh_pass=root ansible_ssh_user=root
```

```
nano apache.yml
```yml
  - hosts: web
    roles:
    - role: webserver
    tasks:
      - name: install apache2
        apt: name=apache2 update_cache=yes state=latest

      - name: enabled mod_rewrite
        apache2_module: name=rewrite state=present
        notify:
          - restart apache2

      - name: apache2 listen on port 80
        lineinfile: dest=/etc/apache2/ports.conf regexp="^Listen 80" line="Listen 80" state=present
        notify:
          - restart apache2

      - name: apache2 virtualhost on port 80
        lineinfile: dest=/etc/apache2/sites-available/000-default.conf regexp="^<VirtualHost \*:80>" line="<VirtualHost *:80>" state=present
        notify:
          - restart apache2

    handlers:
      - name: restart apache2
        service: name=apache2 state=restarted

  - hosts: loadbalancer
    roles:
    - role: lbserver
    tasks:
      - name: install HAPROXY
        apt: name=haproxy update_cache=yes state=latest

      - name: copy HAPROXY configuration files to LoadBalancer
        template:
           src: haproxy.cfg
           dest: /etc/haproxy/
        notify:
          - restart haproxy

    handlers:
      - name: restart haproxy
        service: name=haproxy state=restarted

```

```
mkdir templates
```

```
nano templates/haproxy.cfg
```
```
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&confi>
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA2>
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_>
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

frontend myapp_front
      bind *:80
      default_backend myapp_back

backend myapp_back
      balance roundrobin
      server web1 172.17.0.3:80
      server web2 172.17.0.4:80
```

Création de nos machines :
```
nano Dockerfile
```
```
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

```
docker build -t ubuntu-ssh .
docker run -d -p 80:80 ubuntu-ssh
docker run -d -p ubuntu-ssh
docker run -d -p ubuntu-ssh
```

Application de la configuration Ansible :
```
ansible-playbook apache.yml
```

Résultat :
```
http://localhost
```
