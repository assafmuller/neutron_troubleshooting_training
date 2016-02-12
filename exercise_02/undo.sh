#!/bin/bash

. ~/overcloudrc

public_id=`neutron net-show default-external -F id --format=value`
for fip_id in `neutron floatingip-list --floating_network_id=$public_id -F id --format=value`; do neutron floatingip-disassociate $fip_id; done
neutron router-gateway-clear exercise_02

neutron router-interface-delete exercise_02 exercise_02
neutron router-delete exercise_02
subnet_id=`neutron subnet-show -F id --format=value exercise_02`
nova_port_ids=`neutron port-list --device_owner=compute:None --fixed_ips=subnet_id=$subnet_id -F id --format=value`
nova_ids=`for port_id in $nova_port_ids; do neutron port-show $port_id -F device_id --format=value; done`
for nova_id in $nova_ids; do nova delete $nova_id; done
for port_id in `neutron port-list --fixed_ips=subnet_id=$subnet_id -F id --format=value`; do neutron port-delete $port_id; done
neutron net-delete exercise_02
