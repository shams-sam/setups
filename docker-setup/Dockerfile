# parent image
FROM tensorflow/tensorflow:nightly-py3

# set working directory
WORKDIR /development

# Copy the current directory contents into the destination directory
ADD . /development

# setup command line tools
RUN apt-get update && apt-get install -y \
    emacs \
    git \
    tmux \
    && \
apt-get clean && \
apt-get autoremove && \
rm -rf /var/lib/apt/list/*

# setup non-pip libraries
RUN ["apt-get", "install", "-y", "python-opencv"]

# install requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# expose ports for connection
# 6006 for tensorboard
# 8888 for jupyter notebook
EXPOSE 6006 8888

CMD ["/run_jupyter.sh", "--allow-root"]
