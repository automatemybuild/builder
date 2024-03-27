# builder
mkdir -p ~/git/builder
cd ~/git/builder
git init
git pull https://github.com/automatemybuild/builder
cd ~/git/builder/start
bash builder.sh pop_os-22.04LTS.build
bash install.sh
