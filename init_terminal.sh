cd ~
mkdir WorkSpace
cd WorkSpace
git clone https://github.com/shams-sam/setups.git

sudo add-apt-repository -y ppa:kelleyk/emacs
sudo apt update -y
sudo apt install -y \
     tmux \
     emacs28 \
     python-setuptools

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp setups/.tmux.conf.maglev ~/.tmux.conf

mkdir ~/.emacs.d
cp setups/emacs.init.el ~/.emacs.d/init.el
