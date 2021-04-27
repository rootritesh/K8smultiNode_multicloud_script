
echo '''
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
''' > /etc/yum.repos.d/kubernetes.repo

yum install docker kubelet kubeadm kubectl iproute-tc -y 
systemctl enable --now docker
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
