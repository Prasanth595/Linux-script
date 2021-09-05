#!/bin/bash

# Define colors if needed

if which tput >/dev/null 2>&1; then
		  ncolors=$(tput colors)
	fi
	if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
		RED="$(tput setaf 1)"
		GREEN="$(tput setaf 2)"
		YELLOW="$(tput setaf 3)"
		BLUE="$(tput setaf 4)"
		BOLD="$(tput bold)"
		NORMAL="$(tput sgr0)"
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		NORMAL=""
	fi
  
ask() {
    # https://djm.me/ask
    local prompt default reply

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

installzsh() {

	if [ ! -n "$ZSH" ]; then
		ZSH=~/.oh-my-zsh
	fi

	if [ -d "$ZSH" ]; then
		printf "${YELLOW}You already have Oh My Zsh installed.${NORMAL}\n"
		printf "You'll need to remove $ZSH if you want to re-install.\n"
		exit
	fi

	git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH

	printf "${BLUE}Looking for an existing zsh config...${NORMAL}\n"
	if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
		printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-oh-my-zsh${NORMAL}\n";
		mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh;
	fi

	printf "${BLUE}Using the Oh My Zsh template file and adding it to ~/.zshrc${NORMAL}\n"
	cp $ZSH/templates/zshrc.zsh-template ~/.zshrc
	sed "/^export ZSH=/ c\\
	export ZSH=$ZSH
	" ~/.zshrc > ~/.zshrc-omztemp
	mv -f ~/.zshrc-omztemp ~/.zshrc

}


# ==================== #
#  add repos and keys  #
# ==================== #
printf "${BLUE}add repos and keys${NORMAL}\n"
sudo add-apt-repository -y ppa:daniruiz/flat-remix

# ==================== #
#     basic update     #
# ==================== #
printf "${BLUE}basic update${NORMAL}\n"
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade
sudo apt-get -y --force-yes dist-upgrade

# ==================== #
#     install apps     #
# ==================== #
printf "${BLUE}install apps${NORMAL}\n"
# some explanations:
# line 1: theme
# line 2: system tools
# line 3: fun-time tools
# line 4: video-audio codecs
# line 5: extract and compress programs for various archive formats
# line 6: bash tools (ascii, cowsay, etc.)
# line 7: for alternative login screen 
# line 8: gnome 3.12 thingies
# special mentions:
# gitk - The Git repository browser. Visualizing the commit graph, showing information related to each commit, and the files in the trees of each revision.
# gitg - the GNOME GUI client to view git repositories

sudo apt-get -qq install curl

sudo apt-get -qq install flat-remix flat-remix-gnome flat-remix-gtk gnome-tweak-tool chromium-browser git dconf-tools gdebi-core zsh

sudo apt-get -qq install autoconf autopoint bison texinfo automake gperf rsync tar gettext clang build-essential

# NEEDED BY: my node agnoster prompt plugin
sudo snap install jq

printf "${BLUE}install FONTS${NORMAL}\n"
# Install powerline fonts (for zsh terminal)
  # clone
  git clone https://github.com/powerline/fonts.git --depth=1
  # install
  cd fonts
  ./install.sh
  # clean-up a bit
  cd ..
  rm -rf fonts

# Installing google fonts (for kibibit theme)
curl https://raw.githubusercontent.com/qrpike/Web-Font-Load/master/install.sh | bash

# Install zsh
printf "${BLUE}Install zsh${NORMAL}\n"
installzsh
sudo sed -i 's/ZSH\_THEME\=\"robbyrussell\"/ZSH_THEME\=\"agnoster\"/' .zshrc

# Install Atom
printf "${BLUE}Install ATOM${NORMAL}\n"
wget -O atom-amd64.deb https://atom.io/download/deb
sudo gdebi -qn atom-amd64.deb

# Install GitKraken
printf "${BLUE}Install GITG=KRAKEN${NORMAL}\n"
sudo snap install gitkraken

#install Hyper Terminal
printf "${BLUE}Install HYPER TERMINAL${NORMAL}\n"
wget -O hyper.deb https://releases.hyper.is/download/deb
sudo gdebi -qn hyper.deb

# install icons-in-terminal
git clone https://github.com/sebastiencs/icons-in-terminal.git
cd icons-in-terminal
./install.sh
cd ..

# install ls with icons
git clone https://github.com/sebastiencs/ls-icons.git
cd ls-icons
./bootstrap
export CC=clang CXX=clang++
./configure --prefix=/opt/coreutils
make
sudo make install
cd ..

# RUN WITH: /opt/coreutils/bin/ls
# later, add this to zshrc as an alias

# Install Spotify
printf "${BLUE}Install SNAP applications${NORMAL}\n"
sudo snap install spotify vlc telegram-desktop

# Install calibre
printf "${BLUE}Install CALIBRE${NORMAL}\n"
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

printf "${BLUE}Install GNOME EXTENSIONS${NORMAL}\n"
# Install gnome extension installer
wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
chmod +x gnome-shell-extension-installer
sudo mv gnome-shell-extension-installer /usr/bin/

# Install User Themes for Gnome
gnome-shell-extension-installer 19
gnome-shell-extension-installer 307

printf "${BLUE}CHANGE DCONF ENTRIES${NORMAL}\n"
# change to the correct themes:
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Dark"
gsettings set org.gnome.desktop.interface monospace-font-name "Ubuntu Mono derivative Powerline Regular 13"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Righteous Regular 14"
gsettings set org.gnome.desktop.interface font-name "Comfortaa Regular 11"

# change dash-to-dock settings
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "BOTTOM"
gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-monitors false
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.13
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-width 1
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color "#ffffff"
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode "FIXED"
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode "FOCUS_APPLICATION_WINDOWS"
dconf write /org/gnome/shell/extensions/dash-to-dock/custom-theme-running-dots true
dconf write /org/gnome/shell/extensions/user-theme/name "'Flat-Remix-dark-miami'"

# Set favorites in dock
gsettings set org.gnome.shell favorite-apps "['chromium-browser.desktop', 'firefox.desktop', 'hyper.desktop', 'org.gnome.Nautilus.desktop', 'com.valvesoftware.Steam.desktop', 'atom.desktop', 'gitkraken.desktop', 'org.gnome.Software.desktop']"

# Change some ububntu colors to match kibibit
sudo sed -i 's/\#2c001e/#212121/' /etc/alternatives/gdm3.css
sudo sed -i 's/\#dd4814/#00A2C9/' /etc/alternatives/gdm3.css
git clone https://github.com/Kibibit/kibibit-assets.git
sudo mv /usr/share/plymouth/ubuntu-logo.png /usr/share/plymouth/_ubuntu-logo.png
sudo cp kibibit-assets/1x/long-white.png /usr/share/plymouth/ubuntu-logo.png
# Set desktop background
sudo cp kibibit-assets/4HPEcJ8.jpg /usr/share/backgrounds/kibibit-desktop.jpg
gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/kibibit-desktop.jpg
# Set lock screen background
sudo cp kibibit-assets/splash-kibibit-ubuntu2.jpg /usr/share/backgrounds/splash-kibibit-ubuntu2.jpg
gsettings set org.gnome.desktop.screensaver picture-uri file:///usr/share/backgrounds/splash-kibibit-ubuntu2.jpg

# kill the gnome shell to show the new extensions
killall -3 gnome-shell

# Install NVM
printf "${BLUE}Install NVM${NORMAL}\n"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
echo >> ~/.zshrc
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc
source ~/.bashrc

# Install node LTS and latest
printf "${BLUE}Install NODE${NORMAL}\n"
# nvm install node --latest-npm --reinstall-packages-from=node
# nvm install --lts --latest-npm --reinstall-packages-from='lts/*'
nvm install node --latest-npm
nvm install --lts --latest-npm

# Install node packages I use a lot :-)


# ==================== #
#      config git      #
# ==================== #
# NEEDS: git
printf "${BLUE}CONFIGURE GIT${NORMAL}\n"
git config --global user.name "Neil Kalman"
git config --global user.email "neilkalman@gmail.com"


mkdir ~/Development

# Get general dotfiles backed up to github
git init
git remote add origin https://github.com/Thatkookooguy/ubuntu-18.04-settings.git
git pull origin master
sudo rm -f -r .git

# ======================== #
#    prompt for a reboot   #
# ======================== #
echo ""
echo "===================="
echo " TIME FOR A REBOOT! "
echo "===================="
echo ""

# change bash to zsh
chsh -s $(which zsh)
sudo chsh -s $(which zsh)