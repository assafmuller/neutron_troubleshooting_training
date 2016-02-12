#!/bin/bash

# Stop L3 agent, mess up interface_driver configuration, create resources.

. ~/overcloudrc

ssh heat-admin@overcloud-controller-0 'sudo pcs resource unmanage neutron-l3-agent-clone'

for i in {0..2}
do
ssh heat-admin@overcloud-controller-$i 'sudo systemctl stop neutron-l3-agent'
ssh heat-admin@overcloud-controller-$i 'sudo crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver'
done

neutron router-create exercise_04
neutron net-create exercise_04
neutron subnet-create --name exercise_04 exercise_04 40.0.0.0/8
neutron router-interface-add exercise_04 exercise_04
