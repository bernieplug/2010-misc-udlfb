#!/bin/bash
dev=$1
prog=$2
shift 2
echo 1 > /sys/class/graphics/$dev/metrics_reset
start=$(date +%s)
$prog $@
end=$(date +%s)
rendered=`cat /sys/class/graphics/$dev/metrics_bytes_rendered`
sent=`cat /sys/class/graphics/$dev/metrics_bytes_sent`
identical=`cat /sys/class/graphics/$dev/metrics_bytes_identical`
cycles=`cat /sys/class/graphics/$dev/metrics_cpu_kcycles_used`
total_compress=`/usr/bin/bc <<EOF
scale=2; (($rendered - $sent) / $rendered) * 100
EOF`
bus_compress=`/usr/bin/bc <<EOF
scale=2; (($rendered - $identical - $sent) / ($rendered - $identical)) * 100
EOF`
mbps=`/usr/bin/bc <<EOF
scale=2; ($sent) / ($end - $start) * 8 / 1048576
EOF`
cycles_per_pix=`/usr/bin/bc <<EOF
scale=0; $cycles * 1000 / $rendered
EOF`
echo
echo "Rendered bytes:  $rendered (total pixels * Bpp)"
echo "Identical bytes: $identical (skipped via backbuffer check)"
echo "sent bytes:      $sent (sent over usb, including overhead)"
echo "K CPU cycles:    $cycles (transpired, may include context switches)"
echo
echo "Protocol Compression: $bus_compress % (displaylink protocol compression)"
echo "Total Compression: $total_compress % (including identical pixels skipped)"
echo "CPU cycles per pixel: $cycles_per_pix"
echo "USB Mbps: $mbps (theoretical USB 2.0 peak 480, practical ~230)"
echo

