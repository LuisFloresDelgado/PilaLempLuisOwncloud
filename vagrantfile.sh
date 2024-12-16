Vagrant.configure("2") do |config|

  # Servidor de base de datos
  config.vm.define "Luis-db" do |db|
    db.vm.box = "debian/bullseye64"
    db.vm.network "private_network", ip: "192.168.6.14", virtualbox__intnet: "pn"
    db.vm.network "private_network", ip: "192.168.7.14", virtualbox__intnet: "prnetwork_b"
    db.vm.hostname = "Luis-db"   # Nombre personalizado de la máquina
    db.vm.provision "shell", path: "bd.sh"
  end

  # Servidor NFS
  config.vm.define "Luis-NFS" do |nfs|
    nfs.vm.box = "debian/bullseye64"
    nfs.vm.network "private_network", ip: "192.168.6.13", virtualbox__intnet: "pn"
    nfs.vm.network "private_network", ip: "192.168.7.13", virtualbox__intnet: "prnetwork_b"
    nfs.vm.hostname = "Luis-NFS"   # Nombre personalizado de la máquina
    nfs.vm.provision "shell", path: "nfs.sh"
  end

  # Servidores web
  config.vm.define "Luis-web1" do |serverweb1|
    serverweb1.vm.box = "debian/bullseye64"
    serverweb1.vm.network "private_network", ip: "192.168.6.11", virtualbox__intnet: "pn"
    serverweb1.vm.network "private_network", ip: "192.168.7.11", virtualbox__intnet: "prnetwork_b"
    serverweb1.vm.hostname = "Luis-web1"   # Nombre personalizado de la máquina
    serverweb1.vm.provision "shell", path: "backend.sh"
  end

  config.vm.define "Luis-web2" do |serverweb2|
    serverweb2.vm.box = "debian/bullseye64"
    serverweb2.vm.network "private_network", ip: "192.168.6.12", virtualbox__intnet: "pn"
    serverweb2.vm.network "private_network", ip: "192.168.7.12", virtualbox__intnet: "prnetwork_b"
    serverweb2.vm.hostname = "Luis-web2"   # Nombre personalizado de la máquina
    serverweb2.vm.provision "shell", path: "backend.sh"
  end

  # Máquina balanceador
  config.vm.define "Luis-balanceador" do |balanceador|
    balanceador.vm.box = "debian/bullseye64"
    balanceador.vm.network "public_network"
    balanceador.vm.network "forwarded_port", guest: 80, host: 8080
    balanceador.vm.network "private_network", ip: "192.168.6.10", virtualbox__intnet: "pn"
    balanceador.vm.hostname = "Luis-balanceador"   # Nombre personalizado de la máquina
    balanceador.vm.provision "shell", path: "balanceador.sh"
  end

end
