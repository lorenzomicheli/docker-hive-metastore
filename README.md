# Hive Metastore Dockerfile

This repository provides a Dockerfile for Hive Metastore.
It includes the MySQL Java connector to support MySQL Databases.

To configure the database connection string and credentials, you need to set the following environment variables:

``HIVE_DB_CONNECTION_URL="jdbc:mysql://db:3306/metastore_db"``

``HIVE_DB_USERNAME="username"``

``HIVE_DB_PASSWORD="password"``

For example:
```
docker run -d -p 9083:9083 --env HIVE_DB_CONNECTION_URL="jdbc:mysql://db:3306/metastore_db" --env HIVE_DB_USERNAME="username" --env HIVE_DB_PASSWORD="password" hms:latest
```
