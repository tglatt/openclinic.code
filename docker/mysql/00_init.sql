CREATE USER IF NOT EXISTS 'openclinic'@'localhost' IDENTIFIED WITH mysql_native_password BY 'openclinic';
CREATE USER IF NOT EXISTS 'openclinic'@'%' IDENTIFIED WITH mysql_native_password BY 'openclinic';
GRANT ALL PRIVILEGES ON *.* TO 'openclinic'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'openclinic'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
