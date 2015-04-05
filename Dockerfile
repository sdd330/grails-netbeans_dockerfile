FROM phusion/baseimage:latest

MAINTAINER Yang Leijun <yang.leijun@gmail.com>

# Set customizable env vars defaults.
ENV GRAILS_VERSION 2.4.4
ENV DEBIAN_FRONTEND noninteractive

# Download Install Dependencies
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update
RUN apt-get -y upgrade

# Auto accept oracle jdk license
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -yq oracle-java7-installer oracle-java7-set-default ca-certificates libxext-dev libxrender-dev libxtst-dev mysql-client vim telnet dnsutils wget curl unzip git
RUN update-alternatives --display java

# Add JAVA_HOME to path.
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

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
RUN apt-get autoremove -yq && \
    apt-get clean -yq && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add start script
ADD run.sh /usr/local/bin/netbeans
RUN chmod +x /usr/local/bin/netbeans

# Define mount point to access data on host system.
VOLUME ["/workspace"]

# Execute start script to launch it.
ENTRYPOINT ["/sbin/my_init"]
CMD ["/usr/local/bin/netbeans"]

# Expose ports.
EXPOSE 80 8080