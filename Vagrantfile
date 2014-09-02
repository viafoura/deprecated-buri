# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :public_network, type: "dhcp"
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    vb.customize ["modifyvm", :id, "--memory", "3072"]
  end
  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'export ANSIBLE_HOST_KEY_CHECKING=False && ssh-keygen -f ~/.ssh/known_hosts -R 192.168.33.10 && ssh-add ~/.vagrant.d/insecure_private_key && ./buri -u vagrant --environment development fluxdemo 192.168.33.10'
  end
end
