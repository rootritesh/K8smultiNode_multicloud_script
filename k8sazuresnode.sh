echo '''
[docker]
baseurl = https://download.docker.com/linux/centos/7/x86_64/stable/
gpgcheck = 0
''' > /etc/yum.repos.d/docker.repo

yum install docker-ce --nobest -y
yum install python36 -y
systemctl enable --now docker

echo '''
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
''' > /etc/yum.repos.d/kubernetes.repo

yum install kubelet kubeadm kubectl iproute-tc -y 
systemctl enable --now kubelet

echo '''
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
''' > /etc/docker/daemon.json
systemctl restart docker
docker info | grep -i cgroup

echo '''
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
''' > /etc/sysctl.d/k8s.conf
sysctl --system

