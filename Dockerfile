FROM mariadb:latest
MAINTAINER Kevin Nordloh <info@prime-host.de>

RUN apt-get update && apt-get install -y openssh-server vim supervisor curl wget git unzip zsh cron \
 && mkdir /var/run/sshd \
 && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && NOTVISIBLE "in users profile" \
 && echo "export VISIBLE=now" >> /etc/profile \
 && TZ=Europe/Berlin \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install oh-my-zsh and configure for all users
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true \
 && sed -i s:/root/.oh-my-zsh:\$HOME/.oh-my-zsh:g /root/.zshrc && sed -i 's/robbyrussell/bira/g' /root/.zshrc && echo "DISABLE_UPDATE_PROMPT=true" >> /root/.zshrc \
 && cp -r /root/.oh-my-zsh /etc/skel/ \
 && cp /root/.zshrc /etc/skel \
 && apt-get --purge autoremove -y \
 && ./my.cnf /etc/mysql/my.cnf \
 && crontab -l | { cat; echo "* * * * * /root/scripts/mysql-backup.sh"; } | crontab -

COPY docker-entrypoint.sh /usr/local/bin/
COPY mysql-backup.sh /root/scripts/mysql-backup.sh
RUN chmod 775 /usr/local/bin/docker-entrypoint.sh /root/scripts/mysql-backup.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["mysqld"]
