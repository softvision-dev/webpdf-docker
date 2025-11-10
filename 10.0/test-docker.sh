#!/bin/bash

#########################################
# webPDF Docker Test Script
# Tests the built Docker image
#########################################

set -e  # Exit on error

# Configuration
IMAGE_NAME="softvisiondev/webpdf:10.0.3"
CONTAINER_NAME="webpdf-test"
PORT="8080"
HEALTHCHECK_TIMEOUT=120  # seconds
LOCAL_PACKAGE="true"  # Use local package (./packages/webpdf.deb)

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "webPDF Docker Test Suite"
echo "=========================================="
echo ""

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        exit 1
    fi
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Cleanup function
cleanup() {
    print_info "Cleaning up..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

# Trap cleanup on exit
trap cleanup EXIT

# Test 1: Build the image
print_info "Test 1: Building Docker image (LOCAL_PACKAGE=$LOCAL_PACKAGE)..."
BUILD_OUTPUT=$(docker build --build-arg LOCAL_PACKAGE=$LOCAL_PACKAGE -t $IMAGE_NAME . 2>&1)
BUILD_EXIT_CODE=$?
if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "Build output (last 30 lines):"
    echo "---"
    echo "$BUILD_OUTPUT" | tail -n 30
    echo "---"
fi
print_status $BUILD_EXIT_CODE "Image built successfully"

# Test 2: Check image size
print_info "Test 2: Checking image size..."
IMAGE_SIZE=$(docker images $IMAGE_NAME --format "{{.Size}}")
echo "   Image size: $IMAGE_SIZE"
print_status 0 "Image size reported"

# Test 3: Start container
print_info "Test 3: Starting container..."
docker run -d --name $CONTAINER_NAME -p $PORT:$PORT $IMAGE_NAME > /dev/null
sleep 5
print_status $? "Container started"

# Test 4: Check if container is running
print_info "Test 4: Checking container status..."
CONTAINER_STATUS=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME)
if [ "$CONTAINER_STATUS" = "true" ]; then
    print_status 0 "Container is running"
else
    print_status 1 "Container is not running"
fi

# Test 5: Check healthcheck status
print_info "Test 5: Waiting for healthcheck (max ${HEALTHCHECK_TIMEOUT}s)..."
ELAPSED=0
INTERVAL=10
while [ $ELAPSED -lt $HEALTHCHECK_TIMEOUT ]; do
    HEALTH_STATUS=$(docker inspect -f '{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null || echo "none")

    if [ "$HEALTH_STATUS" = "healthy" ]; then
        print_status 0 "Container is healthy"
        break
    elif [ "$HEALTH_STATUS" = "unhealthy" ]; then
        echo "   Last health check output:"
        docker inspect -f '{{range .State.Health.Log}}{{.Output}}{{end}}' $CONTAINER_NAME
        print_status 1 "Container is unhealthy"
    fi

    echo "   Health status: $HEALTH_STATUS (${ELAPSED}s elapsed)"
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $HEALTHCHECK_TIMEOUT ]; then
    print_status 1 "Healthcheck timeout - container did not become healthy"
fi

# Test 6: Check webPDF endpoint directly
print_info "Test 6: Testing /webPDF/health endpoint..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/webPDF/health)
if [ "$HTTP_CODE" = "200" ]; then
    print_status 0 "Health endpoint returns HTTP 200"
else
    echo "   HTTP Status: $HTTP_CODE"
    print_status 1 "Health endpoint failed"
fi

# Test 7: Check if fonts are installed
print_info "Test 7: Verifying font installation..."
FONT_COUNT=$(docker exec $CONTAINER_NAME fc-list | wc -l)
echo "   Fonts installed: $FONT_COUNT"
if [ $FONT_COUNT -gt 50 ]; then
    print_status 0 "Fonts installed successfully ($FONT_COUNT fonts)"
else
    print_status 1 "Insufficient fonts installed"
fi

# Test 8: Check specific fonts (MS Core, Noto, Custom)
print_info "Test 8: Checking specific font families..."
FONTS_TO_CHECK=("Arial" "Calibri" "Tahoma" "Noto" "Liberation")
for FONT in "${FONTS_TO_CHECK[@]}"; do
    if docker exec $CONTAINER_NAME fc-list | grep -qi "$FONT"; then
        echo -e "   ${GREEN}✓${NC} $FONT found"
    else
        echo -e "   ${YELLOW}⚠${NC} $FONT not found (may be optional)"
    fi
done

# Test 9: Check webPDF user and permissions
print_info "Test 9: Checking user and permissions..."
CURRENT_USER=$(docker exec $CONTAINER_NAME whoami)
if [ "$CURRENT_USER" = "webpdf" ]; then
    print_status 0 "Running as non-root user (webpdf)"
else
    print_status 1 "Not running as expected user"
fi

# Test 10: Check webPDF installation path
print_info "Test 10: Checking webPDF installation..."
if docker exec $CONTAINER_NAME test -f /opt/webpdf/webpdf.starter.sh; then
    print_status 0 "webPDF installation verified"
else
    print_status 1 "webPDF installation not found"
fi

# Test 11: Show container logs (last 20 lines)
print_info "Container logs (last 20 lines):"
echo "---"
docker logs --tail 20 $CONTAINER_NAME 2>&1
echo "---"

echo ""
echo "=========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "=========================================="
echo ""
echo "Container Information:"
echo "  Name: $CONTAINER_NAME"
echo "  Image: $IMAGE_NAME"
echo "  Port: http://localhost:$PORT"
echo ""
echo "To stop and remove the container:"
echo "  docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
echo ""
