# A dummy plugin for Barge to set hostname and network correctly at the very first `vagrant up`
module VagrantPlugins
  module GuestLinux
    class Plugin < Vagrant.plugin("2")
      guest_capability("linux", "change_host_name") { Cap::ChangeHostName }
      guest_capability("linux", "configure_networks") { Cap::ConfigureNetworks }
    end
  end
end

Vagrant.configure(2) do |config|
  config.vm.define "ubuntu-essential"

  config.vm.box = "ailispaw/barge"

  config.vm.provision "trusty", type: "shell", path: "trusty.sh"
  config.vm.provision "xenial", type: "shell", path: "xenial.sh"

  config.vm.provision "nodoc", type: "shell", path: "nodoc.sh"
end
