NAT role
=========

This is a role implementing a highly available NAT system. It is assumed that this will be used on Amazon EC2

Expected Configuration
--------

Instances launched with this role are expected to be in pairs [although they can be terminated at will with little downtime as long as one is left running].

They need to be tagged like this

  - NatGroup: [GroupName]
  - NatInterface: eni-[interface-id]
  - NatTopic: arn:[arn of sns topic]

 
 Make sure to launch the machines in the same PUBLIC subnet, with public IPs assigned to them [this is because they need to reach aws api endpoints]. This subnet needs to be in the same zone as the network interface you plan to use.
 
 The network interface needs to be in a different public subnet with an elastic IP attached to it, and should be available when the first machine of a nat group is launched
 
 Networks that will utilize this NAT group need to use a routing table that has a default route [or a route to the subnets where their IPs should be masqueraded] pointing to the network interface configured for the group.
 
 The machines in this group need to allow pings with each other [set up security groups accordingly].
 
 It is also assumed that the IAM role they are launched with has the following permissions [you can restrict them to the specific interface you're using, etc]
 
 ```
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface",
        "ec2:DetachNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "sns:Publish"
```
