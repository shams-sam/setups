cd ~
mkdir workspace
cd 
git clone https://github.com/shams-sam/setups.git

sudo add-apt-repository -y ppa:kelleyk/emacs \
     main \
     universe \
     restricted \
     multiverse

# required to install python-ldap required by atlas
# https://stackoverflow.com/questions/4768446/i-cant-install-python-ldap
sudo apt-get install libsasl2-dev python-dev libldap2-dev libssl-dev

sudo apt update -y

sudo apt install -y \
     tmux \
     emacs28 \
     python-setuptools \
     tree

# miniconda installation
# https://towardsdatascience.com/how-to-install-miniconda-x86-64-apple-m1-side-by-side-on-mac-book-m1-a476936bfaf0
# https://docs.conda.io/en/latest/miniconda.html#linux-installers
wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh
sh ./Miniconda3-py37_4.12.0-Linux-x86_64.sh
source /home/$USER/miniconda3/etc/profile.d/conda.sh
conda create --yes --name py37 python=3.7
echo $'source /home/$USER/miniconda3/etc/profile.d/conda.sh\nconda activate py37\nalias ll="ls -al"' >> ~/.profile
source ~/.profile

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp setups/.tmux.conf.maglev ~/.tmux.conf

mkdir ~/.emacs.d
cp setups/emacs.init.el ~/.emacs.d/init.el
