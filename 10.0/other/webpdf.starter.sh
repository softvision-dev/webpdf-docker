#!/bin/sh

echo "OS information..."
echo " "
cat /etc/os-release
echo " "

echo "Environment information..."
printenv
echo " "

# ========================================
# Configuration Bootstrap
# ========================================
# This section handles automatic initialization of configuration files
# when the config directory is empty (e.g., fresh PVC mount in Kubernetes)
# This eliminates the need for init containers in Kubernetes/OpenShift

CONFIG_DIR="/opt/webpdf/conf"
CONFIG_DEFAULTS="/opt/webpdf/conf-defaults"

echo "Checking configuration..."

# Check if essential configuration files exist
MISSING_FILES=0
REQUIRED_FILES="server.xml application.xml users.xml"

for file in $REQUIRED_FILES; do
    if [ ! -f "$CONFIG_DIR/$file" ]; then
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

# If any required files are missing, initialize from defaults
if [ $MISSING_FILES -gt 0 ]; then
    echo "Configuration incomplete. Missing $MISSING_FILES required file(s)."

    # Check if defaults exist (they should be in the image)
    if [ -d "$CONFIG_DEFAULTS" ] && [ "$(ls -A $CONFIG_DEFAULTS)" ]; then
        echo "Initializing missing configuration files from $CONFIG_DEFAULTS..."

        # Create config directory if it doesn't exist
        mkdir -p "$CONFIG_DIR"

        # Copy each file individually, only if it doesn't exist
        # This approach works correctly with individual file mounts
        for file in "$CONFIG_DEFAULTS"/*; do
            filename=$(basename "$file")
            target="$CONFIG_DIR/$filename"

            if [ ! -e "$target" ]; then
                echo "  Copying: $filename"
                cp "$file" "$target" 2>/dev/null || true
            else
                echo "  Skipping: $filename (already exists)"
            fi
        done

        echo "Configuration initialized successfully."
        echo "Configuration files populated in: $CONFIG_DIR"
    else
        echo "ERROR: Default configuration directory not found at $CONFIG_DEFAULTS"
        echo "This should not happen in a properly built image."
        echo "Please check the Dockerfile and image build process."
        exit 1
    fi
else
    echo "Configuration complete. All required files found."
    echo "Using existing configuration from: $CONFIG_DIR"
fi

echo " "

# ========================================
# Server Startup
# ========================================

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
