buri
====

### About Buri

[Buri](https://github.com/viafoura/buri) is a toolkit geared specifically towards working with the [components that Netflix has made open-source](http://netflix.github.io) for bonkers-scale computing. They have made huge portions of their infrastructure components available on GitHub, and others have made available integrations from both an application focus, such as [Flux Capacitor](http://fluxcapacitor.com/), or from a deployment focus, such as [netflixoss-ansible](http://answersforaws.com/code/netflixoss/).

If you're new to these Netflix components, please checkout [this set of introduction slides](http://jhohertz.github.io/netflixoss-slides/), and the ones it links to.

Buri works to address the various challenges of bootstrapping the stack into the cloud, and setting up a local all-in-one development stack.

The all-in-one deploys a complete complement of the various components that Flux Capacitor uses, that can run outside of the cloud. Besides setting up sudo and an ssh key before running Buri, in one command, you get an operational and integrated:

- Flux Capacitor edge and middle tier services.
- [Cassandra](http://cassandra.apache.org/) running without [Priam](https://github.com/Netflix/Priam), as it needs a cloud ASG
- [Eureka](https://github.com/Netflix/eureka), with the edge and middle tier registering and discovering though it
- [Exhibitor](https://github.com/Netflix/exhibitor), with the attachment Flux Capacitor provides for [Archaius](https://github.com/Netflix/archaius) [Zookeeper](http://zookeeper.apache.org/) support
- [Turbine](https://github.com/Netflix/turbine), aggregating runtime metrics from the middle / edge instances
- [Hystrix Dashboard](https://github.com/Netflix/Hystrix/tree/master/hystrix-dashboard), for visualizing real time system performance information.
- [Graphite](http://graphite.wikidot.com/), for longer term data collection, provided by Servo, providing hundreds of data points even for the simple demonstration application Flux Capacitor provides.

All of the above, except for Cassandra and Graphite, will be build from sources by default on the all-in-one VM. This allows for easy development that follows the repositories you are working with, and allows continuous integration and delivery setups to be made.

Buri can also generate cloud-ready images for EC2 enabling the cloud features of the NetflixOSS components.  See the <a href="../../wiki/Getting-started">getting started guide</a> for information on getting started using Buri in that manner. It should be possible to use Buri in more traditional [Ansible](http://ansible.com) setups as well. There is also now a [provisioner plugin](https://github.com/aminator-plugins/buri-provisioner) for [aminator](https://github.com/Netflix/aminator), for using it versus Buri's AMI resnap operation. (Better for high volume setups due to better error handling, locking, etc)

See the <a href="../../wiki/Buri-overview">Buri overview</a> page on the <a href="../../wiki">wiki</a> for general info.

### Quick start, using Vagrant

Requirements:

- Vagrant and Virtualbox installed
- Ansible 1.6.10 installed
- Vagrant host shell plugin installed, via:

    vagrant plugin install vagrant-host-shell

- Run from the buri checkout:

    vagrant up

- Sometimes, this might fail on the first try, we might need to add a delay some where. if it does, run:

    vagrant provision

This will do all the below setups, letting you skip most of the following section, so you can get right to using it. (May still want to get that coffee mind you...)

### Quick start, Flux-in-a-Box

To setup the above configuration:

1. Setup a Ubuntu 14.04 server VM (64-bit), with a user named 'dev' that can sudo with a NOPASSWD rule, and an ssh key. (IE: Ansible friendly). You're going to want the VM in bridged mode, or be you'll be setting up a lot of port forwards to use it. You should give it at least 3GB RAM. Passwordless sudo can be setup by running the following on the VM:
   ```
   echo 'dev ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/91-dev
   ```

2. Clone Buri from GitHub on your host:

   ```
   git clone https://github.com/viafoura/buri.git
   ```

3. Make sure you have Ansible 1.6.x installed. You can use a version installed with python-pip, by running:

   ```
   pip install ansible==1.6.10
   ```

   Which will get you the latest version of Ansible. This is the method used when Buri sets up a builder for cloud images. You should probably also install python-dev before running the pip install, you should be able to get all you need via running the following script on Ubuntu:

   ```
   ./install-dependencies.sh
   ```

   Note that both LTS versions of Ubuntu tested with buri do not have Ansible 1.6 available in the package repositories, so use the pip method above.

4. From the checkout, run:

   ```
   ./buri fluxdemo <IP-of-your-VM>
   ```

5. Go for a coffee. If all goes well, in 10-20 minutes, ansible should be done. It may take up to 3-5 minutes more, or on reboots of the VM, for everything to fully come up.

### Testing/Using the Flux-in-a-Box

Change the IP below to the the one you provisioned. All examples use the IP the Vagrantfile specifies, for demonstration purposes.

1. First check on Eureka with this URL, you should see an EDGE, EUREKA, and MIDDLETIER instance registered when fully booted. Don't worry about the eureka URL never moving from unavailable-replicas to available-replicas. There are no replicas in this configuration. It will block the requests coming in until it goes through an internal cluster discovery sequence, then decide to initialize a new one. That's what takes the most time for initializing on boot.

   ```
   http://192.168.33.10:8400/eureka/jsp/status.jsp
   ```

2. Have a look at Exhibitor/Zookeeper status here. When the status is green/serving, and the server id is a positive integer, zookeeper is fully running. A negative number means it's still initializing. Node editing is enabled in the all-in-one for dev tinkering.

   ```
   http://192.168.33.10:8401
   ```

3. Pull up the Hystrix dashboard and use the turbine URL following for the stream on its page. Keep it visible as you run edge tests.

   ```
   http://192.168.33.10:8403/hystrix-dashboard
   http://192.168.33.10:8402/turbine/turbine.stream?cluster=fluxdemo-edge
   ```

4. Generate some edge requests, run a few of the first and then the second URL. You should see graphs in real time generated on the hystrix dashboard page with very little latentcy.

   ```
   # Stuff a message onto the numbered log
   curl -D- http://192.168.33.10:8299/service/edge/v1/log/1234?log=blahblah
   # Get the messages logged against the numbered log
   curl -D- http://192.168.33.10:8299/service/edge/v1/logs/1234
   ```

5. Have a look at the graphite console, you should see on opening the Graphite folder, trees of metrics for both the flux-edge, and flux-middletier coming from Servo. These also come in very close to real-time:

   ```
   http://192.168.33.10:7070
   ```

6. Poke around the Karyon consoles, Eureka tab should match with step #1, and looking @ the Archaius tab is educational on what that provides:

   ```
   Edge  : http://192.168.33.10:9299
   Middle: http://192.168.33.10:9399
   ```

### Status

Buri is approaching an initial beta release. The overall structure for configuration to the end user, allowing localization of configuration, extending with local roles, and managing that as a seperate entity, and has met all current goals. We have most of the mechanisms we need, and a fairly complete set of role templates for provisioning a good base of the NetflixOSS component stack, both to a VM and EC2. It has also reached the goal of integrating back to Aminator vs. supplanting it, and going forward, aims to become a supplementary tool, compatible to Aminator to the greatest extent possible in terms of its own internal AMI handling. This is not currently the case, mostly around metadata concerns.

The core is not expected to change much from this point, and we should mostly be focusing on component integration and implementations as roles going forward, with the following exceptions:
- Names of variables may yet change, but not dramatically, and only for specific areas.
- Non-role plays/tasks are to be re-organized, but no major functional changes planned.
