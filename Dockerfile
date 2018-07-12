ROM mariadb:latest
MAINTAINER Kevin Nordloh <info@prime-host.de>

RUN apt-get update && apt-get install -y openssh-server vim supervisor curl wget git unzip zsh
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install oh-my-zsh and configure for all users
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN sed -i s:/root/.oh-my-zsh:\$HOME/.oh-my-zsh:g /root/.zshrc && sed -i 's/robbyrussell/bira/g' /root/.zshrc && echo "DISABLE_UPDATE_PROMPT=true" >> /root/.zshrc
RUN cp -r /root/.oh-my-zsh /etc/skel/
RUN cp /root/.zshrc /etc/skel

RUN apt-get --purge autoremove -y

ADD ./my.cnf /etc/mysql/my.cnf

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 775 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["mysqld"]
