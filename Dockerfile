# CentOS with NVM, 
# Version 0.1

FROM		centos
MAINTAINER	Arthur Tsang <arthur_tsang@hotmail.com>

# Install dependencies for nvm
RUN yum -y install git curl bzip2 tar
RUN yum -y install vim man

RUN useradd -m -p node node
RUN chsh -s /bin/bash node
RUN su - node -c "touch ~/.bash_profile"

# Install NVM v0.10.0
RUN su - node -c "curl https://raw.githubusercontent.com/creationix/nvm/v0.10.0/install.sh | bash"
# Set path for docker build
RUN su - node -c "echo '[ -s \$HOME/.nvm/nvm.sh ] && . \$HOME/.nvm/nvm.sh #This loads NVM' > .profile"

# Install node
Run su - node -c "nvm install 0.10.29"
RUN su - node -c "nvm alias default 0.10.29"

EXPOSE 4000

# Install Ionic
Run su - node -c "npm install -g cordova ionic"

# Install dependencies for android
RUN yum -y install wget 
RUN yum -y install java-1.7.0-openjdk-devel
RUN yum -y install glibc.i686 glibc-devl.i686 libstdc++.i686 zlib-devl.i686 ncurses-devl.i686 libX11-devel.i686 libXrender.i686 libXrandr.i686 zlib.i686

RUN yum -y install unzip

# Main Android SDK

# Update PATH for bash shell
RUN su - node -c "echo 'export ANDROID_HOME=/home/node/adt-bundle-linux/sdk' >> .bashrc"
RUN su - node -c "echo 'export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platforms:\$ANDROID_HOME/platform-tools' >> .bashrc"
RUN su - node -c "echo 'export ANT_HOME=/home/node/apache-ant' >> .bashrc"
RUN su - node -c "echo 'export PATH=\$PATH:\$ANT_HOME/bin' >> .bashrc"

# Switch user
USER node
# Install Ant 1.9.4 (required by android sdk)
RUN cd /home/node && wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-1.9.4-bin.tar.gz
RUN cd /home/node && tar xzf apache-ant-1.9.4-bin.tar.gz
RUN cd /home/node && rm -f apache-ant-1.9.4-bin.tar.gz
RUN cd /home/node && ln -s apache-ant-1.9.4 apache-ant


# Set PATH for docker build
ENV PATH ${PATH}:/home/node/adt-bundle-linux/sdk/tools:/home/node/adt-bundle-linux/sdk/platforms:/home/node/adt-bundle-linux/sdk/platform-tools

RUN cd /home/node && wget -q http://dl.google.com/android/adt/adt-bundle-linux-x86_64-20140624.zip
RUN cd /home/node && unzip adt-bundle-linux-x86_64-20140624.zip
RUN cd /home/node && rm -f adt-bundle-linux-x86_64-20140624.zip
RUN cd /home/node &&  ln -s adt-bundle-linux-x86_64-20140624 adt-bundle-linux

RUN echo y | android update sdk -a --filter platform-tools,build-tools,extra-android-support,android-19 --no-ui --force

# Switch back so it won't ask for user password
USER root

# test app for cordova
#RUN su - node -c "cd /home/node && cordova create cordova_test com.example.test 'CordovaTestApp'"
#RUN su - node -c "cd /home/node/cordova_test && cordova platform add android"
#RUN su - node -c "cd /home/node/cordova_test && cordova build"

# test app for ionic
RUN su - node -c "cd /home/node && ionic start ionicTestApp tabs"
RUN su - node -c "cd /home/node/ionicTestApp && ionic platform add android"
RUN su - node -c "cd /home/node/ionicTestApp && ionic build android"
#RUN su - node -c "cd /home/node/ionicTestApp && ionic emulate android"

# Start the shell as user node
# Usage: docker run -t -i $IMAGE
CMD su - node
