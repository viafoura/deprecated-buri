#!/bin/bash
NAT_ID=

function sendalert () {
    NAT_TOPIC=`aws ec2 describe-instances --query 'Reservations[0].Instances[0].Tags' --instance-ids $INSTANCE_ID --output text|grep '^NatTopic'|awk '{print $2;}'`
    aws sns publish --topic-arn $NAT_TOPIC --message "$1" 
    echo "$1"
}

# Specify the EC2 region that this will be running in (e.g. https://ec2.us-east-1.amazonaws.com)
export AWS_DEFAULT_REGION=`curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

# Health Check variables
NUM_PINGS={{ nat_number_of_pings }}
PING_TIMEOUT={{ nat_ping_timeout }}
WAIT_BETWEEN_PINGS={{ nat_wait_between_pings }}
DETACH_THRESHOLD={{ nat_detach_threshold }}
export INSTANCE_ID=`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/instance-id`
# Get the other NAT instance's IP

while [[ -z $NAT_GROUP || -z $ENI_ID ]]; do
    sleep 2
    NAT_GROUP=`aws ec2 describe-instances --query 'Reservations[0].Instances[0].Tags' --instance-ids $INSTANCE_ID --output text|grep '^NatGroup'|awk '{print $2;}'`
    ENI_ID=`aws ec2 describe-instances --query 'Reservations[0].Instances[0].Tags' --instance-ids $INSTANCE_ID --output text|grep '^NatInterface'|awk '{print $2;}'`
done
sendalert "`date` -- Starting NAT monitor on $INSTANCE_ID"
VPC_ID=`aws ec2 describe-instances --query 'Reservations[0].Instances[0].VpcId' --instance-ids $INSTANCE_ID --output text`
VPC_CIDR=`aws ec2 describe-vpcs --vpc-ids $VPC_ID --query Vpcs[0].CidrBlock --output text`
sed s,VPC_CIDR,$VPC_CIDR,g /etc/iptables.save | iptables-restore

DEFAULT_ROUTE=`ip route|grep default|awk '{print $3}'`
trap "{ ip route add default via $DEFAULT_ROUTE || true; }" EXIT
eniused=`aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].Status' --output text`
if [[ $eniused == "available" ]]; then
    aws ec2 attach-network-interface --network-interface-id $ENI_ID --instance-id $INSTANCE_ID --device-index 1
    ip route del default via $DEFAULT_ROUTE
    sleep 10
fi

while [ . ]; do
  while [[ -e /sys/class/net/eth1 ]]; do
      sleep 1
  done
  ## eth1 disappeared. readd default route to use aws api
  ip route add default via $DEFAULT_ROUTE &> /dev/null
  # Other nat instance might have been replaced. update information
    NAT_ID=`aws ec2 describe-instances --query 'Reservations[*].Instances[0].InstanceId' --filters Name=tag:NatGroup,Values="$NAT_GROUP" Name=instance-state-name,Values=running --output text|tr '\t' '\n'|grep -v $INSTANCE_ID|head -n1`
    NAT_IP=`aws ec2 describe-instances --query 'Reservations[0].Instances[0].PrivateIpAddress' --instance-ids $NAT_ID --output text`
  # Check health of other NAT instance
  if [[ -n $NAT_IP ]]; then
      pingresult=`ping -c $NUM_PINGS -W $PING_TIMEOUT $NAT_IP | grep time= | wc -l`
  else
      # there's nobody else. take over
      pingresult=0
  fi
  # Check to see if any of the health checks succeeded, if not
  if [[ "$pingresult" == "0" ]]; then
    sendalert "WARNING: Machine $NAT_ID seems unhealthy. $INSTANCE_ID took over NAT duties."
    # Set HEALTHY variables to unhealthy (0)
    NAT_HEALTHY=0
    NAT_DETACHED=0
    NAT_REQUESTED_DETACH=0
    while [[ $NAT_HEALTHY -eq 0 ]]; do
      # NAT instance is unhealthy, loop while we try to fix it
      attachment=`aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query NetworkInterfaces[0].Attachment.AttachmentId --output text`
      if [[ $attachment == "None" ]]; then
          NAT_DETACHED=1
      else
          attacht=`aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query NetworkInterfaces[0].Attachment.AttachTime --output text`
          td=$((`date "+%s"`-`date --date="$attachst" "+s"`))
          if [[ $td -le $DETACH_THRESHOLD ]]; then
              sendalert "Interface $ENI_ID was attached less than $DETACH_THRESHOLD seconds ago. Probably a false positive, $INSTANCE_ID not taking over"
              NAT_HEALTHY=1
              break
          fi
      fi

      if [[ $NAT_DETACHED -eq 0 && $NAT_REQUESTED_DETACH -eq 0 ]]; then
          result=`aws ec2 detach-network-interface --attachment-id $attachment --output text`
          if [[ $result == "true" ]]; then
              NAT_REQUESTED_DETACH=1
              sleep 5
          fi
      fi
      if [[ $NAT_DETACHED -eq 1 ]]; then
          result=`aws ec2 attach-network-interface --network-interface-id $ENI_ID --instance-id $INSTANCE_ID --device-index 1 --output text`
          if [[ -n $result ]]; then
              ip route del default via $DEFAULT_ROUTE
              NAT_HEALTHY=1
          else
              sleep 1
          fi
      fi
    done
    ## attached the interface to this machine. now stop monitoring until we lose it again
    sleep 10
  else
    sleep $WAIT_BETWEEN_PINGS
  fi
done

