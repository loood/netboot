# -*- mode: ruby -*-
# vim: set ft=ruby :
PORT=8004
Vagrant.configure(2) do |config|

  config.vm.define "http" do |http|
    http.vm.provider "docker" do |docker|
      docker.image   = "nginx:stable"
      docker.ports   = ["#{PORT}:80"]
      docker.volumes = ["#{Dir.pwd}/files:/usr/share/nginx/html"]
    end
  end

  config.vm.define "pxe" do |machine_config|
    #machine_config.vm.network :private_network,
    #                            :type => "dhcp"
    #                            :libvirt__dhcp_bootp_file => "http://172.17.0.1:#{PORT}/boot.ipxe"
    machine_config.vm.provider :libvirt do |pxe|
      pxe.memory = 8000
      pxe.cpus = 2
      config.ssh.insert_key = false
      pxe.storage :file, :size => '10G'
      pxe.graphics_type = "vnc"
      pxe.boot 'network'
      pxe.kernel = "#{Dir.pwd}/files/vmlinuz-5.15.0-88-generic"
      pxe.initrd = "#{Dir.pwd}/files/initrd.img-5.15.0-88-generic"
      pxe.cmd_line = "fetch=http://172.17.0.1:#{PORT}/filesystem.squashfs dhcp boot=live nomodeset live-config.debug=true vga=1 live-config.nocomponents=hostname"
      #pxe.serial :type => "file", :source => {:path => File.join(File.dirname(__FILE__), 'serial.log')}

      #machine_config.vm.synced_folder ".", "/vagrant", disabled: false, create: true
    end
  end
end
