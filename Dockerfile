FROM alpine/curl:8.3.0 as build

ARG HADOOP_VERSION=3.3.6
ARG METASTORE_VERSION=3.0.0
ARG AWS_JAVA_SDK_BUNDLE_VERSION=1.12.560
ARG MYSQL_CONNECTOR_JAVA_VERSION=8.0.33
ARG LOG4J_WEB_VERSION=2.20.0

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive-metastore

WORKDIR /opt

RUN mkdir -p ${HADOOP_HOME} ${HIVE_HOME}

RUN curl -L https://downloads.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - --directory ${HIVE_HOME} --strip 1 && \
    curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - --directory ${HADOOP_HOME} --strip 1 && \
    curl -L -o ${HIVE_HOME}/lib/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.jar https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-j-${MYSQL_CONNECTOR_JAVA_VERSION}.jar && \
    curl -L -o ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-${AWS_JAVA_SDK_BUNDLE_VERSION}.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_BUNDLE_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_BUNDLE_VERSION}.jar && \
    curl -L -o ${HIVE_HOME}/lib/log4j-web-${LOG4J_WEB_VERSION}.jar https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-web/${LOG4J_WEB_VERSION}/log4j-web-${LOG4J_WEB_VERSION}.jar

FROM openjdk:8-jre-slim

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive-metastore

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get clean

COPY --from=build $HIVE_HOME $HIVE_HOME
COPY --from=build $HADOOP_HOME $HADOOP_HOME

COPY config/metastore-site.xml ${HIVE_HOME}/conf
COPY scripts/entrypoint.sh /entrypoint.sh

ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-${AWS_JAVA_SDK_BUNDLE_VERSION}.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar

WORKDIR /opt

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

RUN mkdir ${HIVE_HOME}/warehouse && \
    chown hive:hive ${HIVE_HOME}/warehouse 
    
USER hive
EXPOSE 9083

ENTRYPOINT ["/entrypoint.sh"]