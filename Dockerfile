# Base image from (http://phusion.github.io/baseimage-docker)
FROM phusion/baseimage:0.9.22

# Set up Version
ENV version=1.0.0

# Set image labels
LABEL net.corda.version=${version}
LABEL vendor="R3"
MAINTAINER <devops@r3.com>

# Install OpenJDK from zulu.org and update system
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9 \
 && (echo "deb http://repos.azulsystems.com/ubuntu stable main" >> /etc/apt/sources.list.d/zulu.list) \
 && apt-get -qq update \
 && apt-get -y upgrade -y -o Dpkg::Options::="--force-confold" \
 && apt-get -qqy install zulu-8 ntp \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add user corda
RUN groupadd corda \
 && useradd -c "Corda user" -g corda -m -s /bin/bash corda

# Create /opt/corda directory
RUN mkdir -p /opt/corda/plugins && mkdir -p /opt/corda/logs

# Copy corda jar
ADD https://dl.bintray.com/r3/corda/net/corda/corda/$version/corda-$version.jar /opt/corda/corda.jar
# (for now use local dir rather then remote location)
#COPY corda-$version.jar /opt/corda/corda.jar

### Init script for corda
RUN mkdir /etc/service/corda
COPY corda-$version.sh /etc/service/corda/run
RUN chmod +x /etc/service/corda/run

RUN chown -R corda:corda /opt/corda

# Expose port for corda (default is 10002)
EXPOSE 10002

# Working directory for Corda
WORKDIR /opt/corda
ENV HOME=/opt/corda

# Start runit
CMD [ "java", "-jar", "corda.jar" ]