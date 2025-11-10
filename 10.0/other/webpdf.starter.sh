#!/bin/sh

echo "OS information..."
echo " "
cat /etc/os-release
echo " "

echo "Environment information..."
printenv
echo " "

# define the start parameter
_HOME="${JAVA_HOME:-/opt/webpdf/jre/bin}"
_PARAMETERS="${JAVA_PARAMETERS:--Xmx4g -Xms1g}"
_OPTIONS="${SERVER_OPTIONS:-}"

# build the command line
javaCommandLine="$_HOME/java $_PARAMETERS -server -Dfile.encoding=UTF-8 -Dlog4j.configuration=/opt/webpdf/conf/log4j2.xml  -jar /opt/webpdf/webPDF.starter.jar $_OPTIONS"

echo "Starting webPDF Server..."
echo " "
echo "$javaCommandLine"
echo " "

# start the server
exec $javaCommandLine
