# parent image
FROM ufoym/deepo:latest

# set working directory
WORKDIR /setup

# Copy the current directory contents into the destination directory
ADD . /setup

# install requirements.txt
RUN pip install --upgrade pip && \
    pip install --trusted-host pypi.python.org -r \
    requirements.txt

# download nltk corpora
RUN python3 -m nltk.downloader \
    -d /usr/share/nltk_data \
    punkt \
    stopwords

RUN apt-get update && \
    apt-get install -y zsh
	    
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ADD ./.zshrc /root/.zshrc


WORKDIR /WorkSpace