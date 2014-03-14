buri
====

An exploration of ansible-driven AMI generation.

Note, there is not yet anything but experimental scripts and notes in this project. This readme will change substantially as something consumable becomes ready.

what
====

The initial goal, is to allow the building of an AMI, from "scratch". That is to say, it does not simply boot an existing AMI, and snapshot itself, but "installs" an OS from a source image/set of files, and configures the minimum needed to run.

It must do so for at a minimum, all combinations of HVM and paravirtualized systems, in either instance storage or EBS-backed root volumes, on Amazon EC2, with aim to also support Eucalyptus clouds as well.

Out of scope for now are supporting any other cloud types, or non-cloud installations.

Ubuntu will be the initial OS target. Others might follow.

how
===

This will be implemented in terms of ansible playbooks, with the intent to be able to be added to a set of more "normal" playbooks, used together to emerge fully setup AMIs to be used in auto-scale groups.

why
===

There seems to be a real lack of knowledge/tools that are generally available for setting up an initial image for EC2, that does not involve booting someone else's image, and snapshotting it. This is especially so for newer setups in EC2 involving HVM machine types.

While I hope a useable product comes out of this effort, as I start it, it's more to put method to the madness of uncovering the nuances of this mysterious art.

who
===

FIXME: add proper credits to those who have blazed trails in this area before I came near these parts.


