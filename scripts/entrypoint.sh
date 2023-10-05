#!/bin/bash
export JAVA_HOME=/usr/local/openjdk-8

if [ x"$HIVE_DB_CONNECTION_URL" = "x" ]; then
    echo "HIVE_DB_CONNECTION_URL environment variable is not set"
    exit 1 
fi

if [ x"$HIVE_DB_USERNAME" = "x"  ]; then
    echo "HIVE_DB_USERNAME environment variable is not set"
    exit 1 
fi

if [ x"$HIVE_DB_PASSWORD" = "x" ]; then
    echo "HIVE_DB_PASSWORD environment variable is not set"
    exit 1 
fi

replace_connection_url=$(grep "javax.jdo.option.ConnectionURL" -A +3 -B 1 ${HIVE_HOME}/conf/metastore-site.xml | grep "<value>")
sed -i "s|$replace_connection_url|<value>$HIVE_DB_CONNECTION_URL</value>|g" ${HIVE_HOME}/conf/metastore-site.xml

replace_username=$(grep "javax.jdo.option.ConnectionUserName" -A +3 -B 1 ${HIVE_HOME}/conf/metastore-site.xml | grep "<value>")
sed -i "s|$replace_username|<value>$HIVE_DB_USERNAME</value>|g" ${HIVE_HOME}/conf/metastore-site.xml

replace_password=$(grep "javax.jdo.option.ConnectionPassword" -A +3 -B 1 ${HIVE_HOME}/conf/metastore-site.xml | grep "<value>")
sed -i "s|$replace_password|<value>$HIVE_DB_PASSWORD</value>|g" ${HIVE_HOME}/conf/metastore-site.xml

# Check if schema exists
${HIVE_HOME}/bin/schematool -dbType mysql -info

if [ $? -eq 1 ]; then
  echo "Getting schema info failed. Probably not initialized. Initializing..."
  ${HIVE_HOME}/bin/schematool -initSchema -dbType mysql 
fi

${HIVE_HOME}/bin/start-metastore