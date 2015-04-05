FROM phusion/baseimage:0.9.16
MAINTAINER Yang Leijun <yang.leijun@gmail.com>

# Set customizable env vars defaults.
ENV GRAILS_VERSION 2.4.4

# Download Install Dependencies
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update
RUN apt-get -y upgrade

# Auto accept oracle jdk license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer ca-certificates libxext-dev libxrender-dev libxtst-dev mysql-client vim telnet dnsutils wget curl unzip git
RUN update-alternatives --display java

# Add JAVA_HOME to path.
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install Grails
WORKDIR /
RUN wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-$GRAILS_VERSION.zip
RUN unzip grails-$GRAILS_VERSION.zip
RUN rm -rf grails-$GRAILS_VERSION.zip
RUN ln -s grails-$GRAILS_VERSION grails

# Setup Grails path.
ENV GRAILS_HOME /grails
ENV PATH $GRAILS_HOME/bin:$PATH

# Install NetBeans
ADD state.xml /tmp/state.xml
RUN wget http://download.netbeans.org/netbeans/8.0.2/final/bundles/netbeans-8.0.2-javase-linux.sh -O /tmp/netbeans.sh -q && \
    chmod +x /tmp/netbeans.sh && \
    echo 'Installing NetBeans' && \
    /tmp/netbeans.sh --silent --state /tmp/state.xml && \
    rm -rf /tmp/*

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add start script
ADD run.sh /usr/local/bin/netbeans

RUN echo 1000 > /etc/container_environment/uid
RUN echo 1000 > /etc/container_environment/gid
RUN echo 1000 > /etc/container_environment/HOME
RUN echo developer > /etc/container_environment/USER
RUN echo /home/developer > /etc/container_environment/HOME
RUN the_user="developer" && \
    the_home="/home/$the_user" && \
    the_capital_user=$(echo $the_user | sed 's/./\U&/') && \
    echo $the_home > /etc/container_environment/HOME && \
    echo $the_user > /etc/container_environment/USER && \
    echo ":0" > /etc/container_environment/DISPLAY && \
    echo "/tmp/.Xauthority" > /etc/container_environment/XAUTHORITY && \
    echo "$the_user:x:1000:1000:$the_capital_user,,,:/$the_user:/bin/bash" >> /etc/passwd && \
    echo "$the_user:x:1000:" >> /etc/group && \
    echo "$the_user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$the_user && \
    chmod 0440 /etc/sudoers.d/$the_user && \
    mkdir -p $the_home && \
    chown $the_user:$the_user -R $the_home && \
    chmod +x /usr/local/bin/netbeans
	
USER developer
ENV HOME /home/developer
WORKDIR /home/developer

# Define mount point to access data on host system.
VOLUME ["/home/developer/workspace"]

# Execute start script to launch it.
ENTRYPOINT ["/sbin/my_init"]
CMD ["/usr/local/bin/netbeans"]