#!/bin/bash

# Stop OVS agent, wait 80 seconds (Longer than agent_down_time), create resources. Ports will fail to bind.

. ~/overcloudrc

ssh heat-admin@overcloud-controller-0 'sudo pcs resource unmanage neutron-l3-agent-clone'
ssh heat-admin@overcloud-controller-0 'sudo pcs resource unmanage neutron-dhcp-agent-clone'
ssh heat-admin@overcloud-controller-0 'sudo pcs resource unmanage neutron-metadata-agent-clone'
ssh heat-admin@overcloud-controller-0 'sudo pcs resource unmanage neutron-openvswitch-agent-clone'

for i in {0..2}
do
ssh heat-admin@overcloud-controller-$i 'sudo systemctl stop neutron-openvswitch-agent'
done

echo 'Sleeping for 80 seconds'
sleep 80

neutron router-create exercise_02
neutron net-create exercise_02
neutron subnet-create --name exercise_02 exercise_02 20.0.0.0/8
neutron router-interface-add exercise_02 exercise_02

echo 'Sleeping for 10 seconds'
sleep 10

for i in {0..2}
do
ssh heat-admin@overcloud-controller-$i 'sudo systemctl start neutron-openvswitch-agent'
done

echo 'Sleeping for 10 seconds'
sleep 10

ssh heat-admin@overcloud-controller-0 'sudo pcs resource manage neutron-l3-agent-clone'
ssh heat-admin@overcloud-controller-0 'sudo pcs resource manage neutron-dhcp-agent-clone'
ssh heat-admin@overcloud-controller-0 'sudo pcs resource manage neutron-metadata-agent-clone'
ssh heat-admin@overcloud-controller-0 'sudo pcs resource manage neutron-openvswitch-agent-clone'
