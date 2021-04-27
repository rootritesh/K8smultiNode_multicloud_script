
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

kubeadm config images pull

echo '''
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
''' > /etc/docker/daemon.json
systemctl restart docker
docker info | grep -i cgroup

kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=13.234.225.31:6443 --ignore-preflight-errors=NumCPU  --ignore-preflight-errors=Mem

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubeadm token create --print-join-command