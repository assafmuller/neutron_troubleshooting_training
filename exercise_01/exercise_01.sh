#!/bin/bash

# Enable l2pop on the controllers, but not OVS agents. Tunnels will not be formed.

for i in {0..2}
do
ssh heat-admin@overcloud-controller-$i 'sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers openvswitch'
ssh heat-admin@overcloud-controller-$i 'sudo crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini agent l2_population True'
ssh heat-admin@overcloud-controller-$i 'for port in `sudo ovs-vsctl list-ports br-tun | grep vxlan`; do sudo ovs-vsctl del-port br-tun $port; done'
ssh heat-admin@overcloud-controller-$i 'sudo systemctl restart neutron-server'
ssh heat-admin@overcloud-controller-$i 'sudo systemctl restart neutron-openvswitch-agent'
done

. ~/overcloudrc

neutron router-create exercise_01
neutron net-create exercise_01
neutron subnet-create --name exercise_01 exercise_01 11.0.0.0/8
neutron router-interface-add exercise_01 exercise_01
