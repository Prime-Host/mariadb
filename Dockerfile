FROM mariadb:latest
MAINTAINER Kevin Nordloh <info@prime-host.de>

RUN apt-get update && apt-get install -y openssh-server vim supervisor curl wget git unzip zsh cron \
 && mkdir /var/run/sshd \
 && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && echo "export VISIBLE=now" >> /etc/profile \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV NOTVISIBLE "in users profile"
ENV TZ=Europe/Berlin

# Install oh-my-zsh and configure for all users
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true \
 && cp /root/.oh-my-zsh/themes/bira.zsh-theme /root/.oh-my-zsh/themes/prime-host.zsh-theme \
 && sed -i 's/%m%/%M%/g' /root/.oh-my-zsh/themes/prime-host.zsh-theme \
 && sed -i s:/root/.oh-my-zsh:\$HOME/.oh-my-zsh:g /root/.zshrc \
 && sed -i 's/robbyrussell/prime-host/g' /root/.zshrc \
 && echo "DISABLE_UPDATE_PROMPT=true" >> /root/.zshrc \
 && echo "set encoding=utf-8" >> /root/.vimrc \
 && echo "set fileencoding=utf-8" >> /root/.vimrc \
 && cp -r /root/.oh-my-zsh /etc/skel/. \
 && cp /root/.zshrc /etc/skel/. \
 && cp /root/.vimrc /etc/skel/. \
 && apt-get --purge autoremove -y \
 && crontab -l | { cat; echo "0 1 * * * /root/scripts/mysql-backup.sh"; } | crontab -

ADD ./my.cnf /etc/mysql/my.cnf
COPY docker-entrypoint.sh /usr/local/bin/
COPY mysql-backup.sh /root/scripts/mysql-backup.sh
RUN chmod 775 /usr/local/bin/docker-entrypoint.sh /root/scripts/mysql-backup.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["mysqld"]
