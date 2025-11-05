#!/usr/bin/env bash
#
# Debug script to verify packet loss configuration
#

if [ -z "$1" ]; then
    echo "Usage: $0 <pid>"
    exit 1
fi

PID=$1
IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

echo "=== Debugging Packet Loss for PID $PID ==="
echo ""

echo "1. Check if PID exists:"
if [ -d "/proc/$PID" ]; then
    echo "   ✓ PID $PID is running: $(ps -p $PID -o comm=)"
else
    echo "   ✗ PID $PID does not exist"
    exit 1
fi
echo ""

echo "2. Check cgroup:"
CGROUP="/sys/fs/cgroup/net_cls/packet_loss_$PID"
if [ -d "$CGROUP" ]; then
    echo "   ✓ Cgroup exists: $CGROUP"
    echo "   Classid: $(cat $CGROUP/net_cls.classid) (decimal)"
    echo "   Classid (hex): 0x$(printf '%x' $(cat $CGROUP/net_cls.classid))"
    echo "   PIDs in cgroup: $(cat $CGROUP/cgroup.procs | tr '\n' ' ')"
else
    echo "   ✗ Cgroup does not exist: $CGROUP"
fi
echo ""

echo "3. Check tc qdisc setup on $IFACE:"
tc qdisc show dev $IFACE
echo ""

echo "4. Check tc classes:"
tc class show dev $IFACE
echo ""

echo "5. Check tc filters:"
tc filter show dev $IFACE
echo ""

echo "6. Check packet statistics for classes:"
tc -s class show dev $IFACE
echo ""

echo "7. Test: Send packets from PID and check stats"
echo "   Watch the 'Sent' counters above, then Ctrl+C after a few seconds"
echo "   Class 1:1 should have OTHER traffic"
echo "   Class 1:10 should have PID $PID traffic"
echo ""
