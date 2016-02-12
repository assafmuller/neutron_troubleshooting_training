#!/bin/bash

# RDO Manager configures OVS agents tunnel_types to vxlan exclusively. Creating a GRE network will fail to bind ports.

. ~/overcloudrc

neutron router-create exercise_03
neutron net-create --provider:network_type=gre exercise_03
neutron subnet-create --name exercise_03 exercise_03 30.0.0.0/8
neutron router-interface-add exercise_03 exercise_03
