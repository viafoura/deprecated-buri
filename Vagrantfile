# -*- mode: ruby -*-
# vi: set ft=ruby :

# Requires the following plugin install to be run first, as well as everything in the readme.
#      vagrant plugin install vagrant-host-shell

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

options = {}
options[:role_name] = ENV['ROLE'] || 'all_in_one_flux'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    vb.customize ["modifyvm", :id, "--memory", "3072"]
  end
  config.vm.provision :host_shell do |host_shell|
    host_shell.inline = 'ssh-keygen -f ~/.ssh/known_hosts -R 192.168.33.10 && export ANSIBLE_HOST_KEY_CHECKING="False" && export ANSIBLE_PRIVATE_KEY_FILE="~/.vagrant.d/insecure_private_key" && ./buri --cluster-name dev_vm -v -u vagrant --environment development apply  192.168.33.10 ' + options[:role_name]
  end
end
