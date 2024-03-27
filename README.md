# Builder Pull
1. mkdir -p ~/git/builder
2. cd ~/git/builder
3. git init
4. git pull https://github.com/automatemybuild/builder
5. cd ~/git/builder/start
6. bash builder.sh pop_os-22.04LTS.build
7. bash ~/git/builder/start/install.sh
9. bash ~/bin/mirror-nas.sh

# Builder Push
git add *; git commit -m `date '+%y%m%d'`; git push -u origin main
