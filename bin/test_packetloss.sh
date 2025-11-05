#!/usr/bin/env bash
#
# Test script for packet loss controller (interface-wide)
# This will apply packet loss to an interface, verify it works, then clean up
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKETLOSS="$SCRIPT_DIR/packetloss"

# Get default interface
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$INTERFACE" ]; then
    echo -e "${RED}ERROR: Could not determine default network interface${NC}"
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This test must be run as root (use sudo)${NC}"
    exit 1
fi

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    if [ -n "$PING_PID" ] && kill -0 $PING_PID 2>/dev/null; then
        kill $PING_PID 2>/dev/null || true
        wait $PING_PID 2>/dev/null || true
    fi
    # Disable packet loss
    "$PACKETLOSS" "$INTERFACE" 0 2>/dev/null || true
    echo -e "${GREEN}Cleanup complete${NC}"
}

trap cleanup EXIT INT TERM

echo -e "${GREEN}=== Packet Loss Controller Test (Interface: $INTERFACE) ===${NC}\n"

# Step 1: Start a background ping
echo -e "${YELLOW}Step 1: Starting ping to 8.8.8.8...${NC}"
ping -i 0.5 8.8.8.8 > /tmp/ping_test.log 2>&1 &
PING_PID=$!
sleep 2  # Let it establish

if ! kill -0 $PING_PID 2>/dev/null; then
    echo -e "${RED}✗ Failed to start ping${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Ping started with PID $PING_PID${NC}"

# Step 2: Baseline - verify ping works normally
echo -e "\n${YELLOW}Step 2: Collecting baseline (5 seconds)...${NC}"
sleep 5
BASELINE_COUNT=$(grep -c "bytes from" /tmp/ping_test.log || echo "0")
echo -e "${GREEN}✓ Baseline: $BASELINE_COUNT successful pings${NC}"

if [ "$BASELINE_COUNT" -lt 5 ]; then
    echo -e "${RED}✗ Baseline too low, network may already have issues${NC}"
    exit 1
fi

# Step 3: Apply 50% packet loss
echo -e "\n${YELLOW}Step 3: Applying 50% packet loss to $INTERFACE...${NC}"
"$PACKETLOSS" "$INTERFACE" 50

# Step 4: Test with packet loss (10 seconds)
echo -e "\n${YELLOW}Step 4: Testing with packet loss (10 seconds)...${NC}"
> /tmp/ping_test.log  # Clear log
sleep 10
LOSS_COUNT=$(grep -c "bytes from" /tmp/ping_test.log || echo "0")
echo -e "${GREEN}✓ With 50% loss: $LOSS_COUNT successful pings${NC}"

# Calculate approximate loss percentage
EXPECTED_COUNT=$((BASELINE_COUNT * 10 / 5))  # Scale baseline to 10 seconds
if [ "$EXPECTED_COUNT" -gt 0 ]; then
    ACTUAL_LOSS=$(( (EXPECTED_COUNT - LOSS_COUNT) * 100 / EXPECTED_COUNT ))
    echo -e "${YELLOW}Expected ~$EXPECTED_COUNT pings, got $LOSS_COUNT (approx ${ACTUAL_LOSS}% loss)${NC}"

    if [ "$LOSS_COUNT" -lt "$((EXPECTED_COUNT / 2 + 2))" ]; then
        echo -e "${GREEN}✓ Packet loss appears to be working!${NC}"
    else
        echo -e "${YELLOW}⚠ Packet loss may not be fully effective (expected ~50% loss)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Unable to calculate loss percentage${NC}"
fi

# Step 5: Disable packet loss
echo -e "\n${YELLOW}Step 5: Disabling packet loss...${NC}"
"$PACKETLOSS" "$INTERFACE" 0

# Step 6: Verify restoration
echo -e "\n${YELLOW}Step 6: Verifying restoration (5 seconds)...${NC}"
> /tmp/ping_test.log  # Clear log
sleep 5
RESTORE_COUNT=$(grep -c "bytes from" /tmp/ping_test.log || echo "0")
echo -e "${GREEN}✓ After restoration: $RESTORE_COUNT successful pings${NC}"

if [ "$RESTORE_COUNT" -ge 5 ]; then
    echo -e "${GREEN}✓ Network restored to normal${NC}"
else
    echo -e "${YELLOW}⚠ Restoration may have issues${NC}"
fi

# Summary
echo -e "\n${GREEN}=== Test Summary ===${NC}"
echo -e "Interface:            $INTERFACE"
echo -e "Baseline (5s):        $BASELINE_COUNT pings"
echo -e "With 50% loss (10s):  $LOSS_COUNT pings"
echo -e "After restore (5s):   $RESTORE_COUNT pings"

if [ "$LOSS_COUNT" -lt "$BASELINE_COUNT" ] && [ "$RESTORE_COUNT" -ge 5 ]; then
    echo -e "\n${GREEN}✓✓✓ TEST PASSED ✓✓✓${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠⚠⚠ TEST INCONCLUSIVE ⚠⚠⚠${NC}"
    exit 1
fi
