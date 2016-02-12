#!/bin/bash

for i in {0..2}
do
ssh heat-admin@overcloud-controller-$i 'sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers openvswitch'
ssh heat-admin@overcloud-controller-$i 'sudo crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population False'
ssh heat-admin@overcloud-controller-$i 'sudo systemctl restart neutron-server'
ssh heat-admin@overcloud-controller-$i 'sudo systemctl restart neutron-openvswitch-agent'
done

. ~/overcloudrc

public_id=`neutron net-show default-external -F id --format=value`
for fip_id in `neutron floatingip-list --floating_network_id=$public_id -F id --format=value`; do neutron floatingip-disassociate $fip_id; done
neutron router-gateway-clear exercise_01

neutron router-interface-delete exercise_01 exercise_01
neutron router-delete exercise_01
subnet_id=`neutron subnet-show -F id --format=value exercise_01`
nova_port_ids=`neutron port-list --device_owner=compute:None --fixed_ips=subnet_id=$subnet_id -F id --format=value`
nova_ids=`for port_id in $nova_port_ids; do neutron port-show $port_id -F device_id --format=value; done`
for nova_id in $nova_ids; do nova delete $nova_id; done
for port_id in `neutron port-list --fixed_ips=subnet_id=$subnet_id -F id --format=value`; do neutron port-delete $port_id; done
neutron net-delete exercise_01
