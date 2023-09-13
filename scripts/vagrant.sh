apt-get update
apt-get install -y git libcurl4-openssl-dev libreadline-dev manta

git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/ruby-build
/home/vagrant/ruby-build/install.sh

export HOME=/home/vagrant
echo 'export PATH="/home/vagrant/.rbenv/bin:$PATH"' >> /home/vagrant/.bash_profile
echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bash_profile
source /home/vagrant/.bash_profile

rbenv install 2.1.5
rbenv rehash
rbenv global 2.1.5
gem install bundler
rbenv rehash

chown -R vagrant:vagrant /home/vagrant/.rbenv
