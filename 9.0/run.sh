#!/bin/bash
javaCommandLine="/opt/webpdf/jre/bin/java $JAVA_PARAMETERS -server -Dfile.encoding=UTF-8 -Dlog4j.configuration=/opt/webpdf/conf/log4j2.xml --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED -jar /opt/webpdf/webPDF.starter.jar"
echo "Starting webPDF Server..."
echo " "
$javaCommandLine
