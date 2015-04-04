FROM java:8
MAINTAINER Yang Leijun <yang.leijun@gmail.com>

# Set customizable env vars defaults.
ENV GRAILS_VERSION 2.4.4

# Download Install Tools
RUN apt-get update
RUN apt-get install -y unzip

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

# Define mount point to access data on host system.
VOLUME ["/workspace"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add start script
ADD run.sh /usr/local/bin/netbeans
RUN chmod +x /usr/local/bin/netbeans

# Execute start script to launch it.
ENTRYPOINT ["run.sh"]
