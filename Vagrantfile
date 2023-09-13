Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu-12.04-amd64-docker-1426195046'
  config.vm.box_url = 'http://devtools-vagrant-images.s3.amazonaws.com/ubuntu-12.04-amd64-docker-1426195046.box'
  config.vm.provision :shell, :path => 'scripts/vagrant.sh'
end
