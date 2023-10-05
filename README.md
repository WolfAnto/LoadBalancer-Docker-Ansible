# LoadBalancer-Docker-Ansible
Création d'un loadbalancer avec Docker et Ansible.

Install Ansible :
```bash
sudo apt install Ansible
```

Création de la configuration Ansible :
Créer le dossier dans lequel nous réaliserons notre Loadbalancer.
```bash
mkdir loadbalancer-ansible
```

Placez-vous dans le dossier précédemment créé.
```bash
cd loadbalancer-ansible
```

Créer le fichier de configuration ansible.
Indiquer l'emplacement du fichier contenant vos hôtes et vos rôles.
```bash
nano ansible.cfg
```

![carbon(1)](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/ad1bc7b3-f20e-481a-a54e-d544902b2e63)

Indiquer vos groupes avec vos hôtes.
```bash
nano hosts
```

![carbon](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/cb534ae9-4a26-49cc-8c4f-7d480fdfb07d)

Créer le playbook ansible.
```bash
nano apache.yml
```

![carbon(2)](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/d26cc89b-d257-4d64-bbde-e8231fa7f8b3)

Créer le dossier "Templates".
```bash
mkdir templates
```

Créer le fichier de configuration HAProxy pour le loadbalancer.
```bash
nano templates/haproxy.cfg
```

![carbon(2)](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/a8a104ca-5be9-4b38-b132-5124e6362fe9)

Revenez au dossier précédent.
```bash
cd ..
```

Création de nos machines :
Créer le fichier "Dockerfile".
```bash
nano Dockerfile
```

![carbon(1)](https://github.com/WolfAnto/LoadBalancer-Docker-Ansible/assets/73076854/0df6d55f-edd6-4d67-a200-5b2986840b28)

Monter votre Dockerfile et créez-en 3 exemplaires.
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

