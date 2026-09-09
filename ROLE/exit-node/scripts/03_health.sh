#!/usr/bin/env bash
# Observe the digs node: connectivity, health, routes, and what's served/ssh.
set -uo pipefail

echo "=== tailscale status ==="
tailscale status

echo
echo "=== health ==="
tailscale status --json | python3 -c "import sys,json; d=json.load(sys.stdin); print('Self:', d['Self'].get('HostName'), d['Self'].get('TailscaleIPs')); print('Health:', d.get('Health', []))" 2>/dev/null || tailscale debug prefs

echo
echo "=== serve status ==="
tailscale serve status || true

echo
echo "=== forwarding ==="
sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding 2>/dev/null
