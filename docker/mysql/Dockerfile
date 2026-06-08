FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_USER=openclinic
ENV MYSQL_PASSWORD=openclinic

COPY mysql.cnf /etc/mysql/conf.d/mysql.cnf
COPY 00_init.sql /docker-entrypoint-initdb.d/00_init.sql
COPY dump.sql /docker-entrypoint-initdb.d/dump.sql
COPY zz_nupsref.sql /docker-entrypoint-initdb.d/zz_nupsref.sql

CMD ["--default-authentication-plugin=mysql_native_password"]

EXPOSE 3306
