#!/bin/bash

# Set up bridge mappings for physnet 'public' and create an external network on it. However, br-public is not connected to a physical device.

. ~/overcloudrc

for i in {0..2}
do
ssh heat-admin@overcloud-controller-$i 'sudo crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vlan network_vlan_ranges datacentre,public'
ssh heat-admin@overcloud-controller-$i 'sudo systemctl restart neutron-server'
ssh heat-admin@overcloud-controller-$i 'sudo ovs-vsctl add-br br-public'
ssh heat-admin@overcloud-controller-$i 'sudo crudini --set /etc/neutron/plugins/ml2/openvswitch_agent.ini ovs bridge_mappings datacentre:br-ex,public:br-public'
ssh heat-admin@overcloud-controller-$i 'sudo systemctl restart neutron-openvswitch-agent'
done

neutron router-create exercise_05
neutron net-create exercise_05
neutron subnet-create --name exercise_05 exercise_05 50.0.0.0/8
neutron router-interface-add exercise_05 exercise_05

neutron net-create --provider:physical_network=public --provider:segmentation_id 905 --provider:network_type vlan --router:external public
neutron subnet-create --name public --enable_dhcp=False --allocation-pool=start=10.0.0.230,end=10.0.0.239 --gateway=10.0.0.250 public 10.0.0.0/24
neutron router-gateway-set exercise_05 public

