FROM debian:buster

RUN apt-get update && apt-get install -y \
mariadb-server \
mariadb-client \
&& rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init_db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init_db.sh

RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
