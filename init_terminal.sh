# cd ~
# mkdir workspace
# cd workspace
# git clone https://github.com/shams-sam/setups.git

sudo add-apt-repository -y ppa:kelleyk/emacs \
     main \
     universe \
     restricted \
     multiverse

# required to install python-ldap required by atlas
# https://stackoverflow.com/questions/4768446/i-cant-install-python-ldap
sudo apt-get install -y libsasl2-dev python-dev libldap2-dev libssl-dev

sudo apt update -y

sudo apt install -y \
     tmux \
     emacs28 \
     python-setuptools \
     tree

# miniconda installation
# https://towardsdatascience.com/how-to-install-miniconda-x86-64-apple-m1-side-by-side-on-mac-book-m1-a476936bfaf0
# https://docs.conda.io/en/latest/miniconda.html#linux-installers
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh ./Miniconda3-latest-Linux-x86_64.sh -b
source /home/$USER/miniconda3/etc/profile.d/conda.sh
conda create --yes --name py37 python=3.7
echo "source /home/$USER/miniconda3/etc/profile.d/conda.sh
conda activate py37

# reference:
# https://askubuntu.com/a/730758
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
color_prompt=yes
if [ \"$color_prompt\" = yes ]; then
 PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
 PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi" >> ~/.profile
source ~/.profile

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp .tmux.conf.maglev ~/.tmux.conf

mkdir ~/.emacs.d
cp emacs.init.el ~/.emacs.d/init.el
