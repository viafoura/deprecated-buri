buri
====

Ansible driven AMI generation.

See the [About](https://github.com/jhohertz/buri/wiki/About) page on the [wiki](https://github.com/jhohertz/buri/wiki) for more info

howto
=====

In the current state:

1. Boot an official version of Ubuntu in EC2
  - can be a t1.micro (m1.small is better, may be required going forward)
  - 12.04 current testing target, (14.04 also being tested)
  - You boot the version you wish to make a foundation for
  - Need an IAM policy allowing volume/snapshot/ami management, such as the one [here](https://github.com/Netflix/aminator/wiki/Configuration)

2. Install ansible, git, and ec2 api/ami tools. There is a helper script for ubuntu:

```
./setup_ubuntu.sh
```

3. Create a new foundation AMI set, for ubuntu:

```
./create-ubuntu-foundation.sh
```

4. Create a new base AMI set, using as input, the PVM AMI ID from foundation step

```
./resnap.sh <foundation-pvm-ami-ID> base
```

5. Create a role-based AMI set, using as input, the PVM AMI ID from base step
```
./resnap.sh <base-pvm-ami-ID> <role>
```


