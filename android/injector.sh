#!/bin/sh
# daemon
BASEDIR=$(dirname $0)
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p create -l
$BASEDIR/sepolict-inject -s init_shell -t init_shell -c udp_socket -p ioctl -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p bind -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p listen -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p accept -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p getopt -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p setopt -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p write -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c udp_socket -p read -l

$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c capability -p sys_module -l

$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p create -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p ioctl -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p bind -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p listen -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p accept -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p getopt -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p setopt -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p write -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c packet_socket -p read -l

$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p create -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p ioctl -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p bind -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p listen -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p accept -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p getopt -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p setopt -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p write -l
$BASEDIR/sepolicy-inject -s init_shell -t init_shell -c tcp_socket -p read -l

#system/main
$BASEDIR/sepolicy-inject -s servicemanager -t zygote -c binder -p call -l
$BASEDIR/sepolicy-inject -s servicemanager -t zygote -c dir -p search -l
$BASEDIR/sepolicy-inject -s servicemanager -t zygote -c file -p read -l
$BASEDIR/sepolicy-inject -s servicemanager -t zygote -c file -p open -l
$BASEDIR/sepolicy-inject -s servicemanager -t zygote -c process -p getattr -l
$BASEDIR/sepolicy-inject -s system_server  -t zygote -c binder -p call -l
$BASEDIR/sepolicy-inject -s system_server  -t zygote -c binder -p transfer -l
