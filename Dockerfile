FROM resin/rpi-raspbian

MAINTAINER Bastian Rinsche <hi@bastianrinsche.de>

RUN apt-get update && \
apt-get install -yqq \
openssh-server \
rsync \
git-core \
net-tools

RUN addgroup git && \
adduser git --shell /bin/bash --ingroup git

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's@UsePrivilegeSeparation yes@UsePrivilegeSeparation no@' -i /etc/ssh/sshd_config

RUN sed 's@#RSAAuthentication yes@RSAAuthentication yes@' -i /etc/ssh/sshd_config
RUN sed 's@#PubkeyAuthentication yes@PubkeyAuthentication yes@' -i /etc/ssh/sshd_config

RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

# prepare data
ENV GOGS_CUSTOM /data/gogs
RUN echo "export GOGS_CUSTOM=/custom" >> /etc/profile && \
mkdir /gogits

WORKDIR /gogits

ADD ./gogs/ /gogits/

ADD start.sh /gogits/
RUN chmod a+x start.sh

EXPOSE 22
EXPOSE 3000
ENTRYPOINT []
CMD ["./start.sh"]
