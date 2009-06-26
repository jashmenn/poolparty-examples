"Easily" setup a monitored Hadoop / Hive Cluster in EC2 with PoolParty
======================================================================

Summary
=======

Setting up a scalable Hadoop cluster isn't easy, but PoolParty makes it easier
and manageable.

By the time we're done with this tutorial you'll have a Hadoop cluster consisting of one master node and two slaves.  The slaves are formatted with HDFS and process MapReduce jobs that are delegated to them from the master.  

The whole cluster is monitored by Ganglia.

Benefits of PoolParty
=====================
The nodes are very interdependent. By that I mean that each node needs to have 2 or 3 configuration files that are based on the other currently running nodes in the cluster. As nodes are joining and leaving the cluster each of these files on every node needs to be updated. PoolParty handles this process for you more-or-less automatically. The benefit is that you don't have roll your own methods to do this every time you want to setup a cluster. 

In PoolParty plugins are first-class citizens. This means you can write your own plugins and they are every bit as powerful as the resources that make up PoolParty core itself. This makes it easy to break up server functionality into _modules of code_ . PoolParty, in a sense, gives you object-oriented server configurations. You can, for instance, take a Ganglia object, call a few methods and PoolParty takes care of executing the required commands to deploy a configured Ganglia cluster.

Architecture 
============
PoolParty is built around the notion of _pools_ and _clouds_ . A pool is simply a collection of clouds. A cloud is a homogeneous set of nodes. i.e. **every node in a cloud is _configured_ the same way** . Obviously nodes in a cloud will have different sets of working data as they run, but the idea is any node in a cloud could be substituted for any other node in that same cloud.  

PoolParty itself is designed to be fully distributed and masterless. There is no required concept of "master" and "slave" in PoolParty itself. That said, many pieces of software, such as Hadoop, do have this concept and PoolParty can be configured to take advantage of that. 

We'll be setting up our pool as two clouds `hadoop_master` and `hadoop_slave`. Obviously, `hadoop_slave` will be a cloud (cluster) of nodes configured to be Hadoop slaves. `hadoop_master` will also be a cloud of masters. In our example we're only going to use 1 node as the master. But  you could relatively easily configure everything to have more than one master.  

Software involved
=================

* [Hadoop](http://hadoop.apache.org/core/) 
* [Hive](http://wiki.apache.org/hadoop/Hive)
* [Ganglia](http://ganglia.info/)
* [PoolParty](http://poolpartyrb.com)

Prerequisites
=============
This tutorial assumes that:

1. **You have Amazon EC2 java tools installed**. See [EC2: Getting Started with the Command Line Tools](http://docs.amazonwebservices.com/AWSEC2/latest/GettingStartedGuide/index.html?StartCLI.html)
1. **You have the proper EC2 environment variables setup**. See [Setting up EC2](http://auser.github.com/poolparty/amazon_ec2_setup.html) on the PoolParty website. For instance, a typical PoolParty install would have these variables in `$HOME/.ec2/keys_and_secrets.sh`.
1. **You have PoolParty installed from source**. In theory, you should be able to install the gem. However, _today_  you should probably install from source. Make sure you have `git://github.com/auser/poolparty.git` checked out and then follow the "Installing" directions on [the PoolParty wiki](http://wiki.github.com/auser/poolparty/installing). You only need to complete the two sections **Dependencies required to build gem locally** and **Instructions** . This will install all the development dependency gems and then make sure you have all of the submodules.
1. **You have the [jashmenn/poolparty-examples](http://github.com/jashmenn/poolparty-examples/tree/master) repository**. `git checkout git://github.com/jashmenn/poolparty-examples.git /path/to/poolparty-examples` 
1. **You have the [jashmenn/poolparty-extensions](http://github.com/jashmenn/poolparty-extensions/tree/master) repository**. Note that this directory must be a *sibling* directory to the `poolparty-examples` directory. `git clone git://github.com/jashmenn/poolparty-extensions.git /path/to/poolparty-extensions`

EC2 Security
============
Now that we have the code issue complete, we now need to deal with Amazon's security. (See [here](http://auser.github.com/poolparty/amazon.html) if you are unclear on how EC2 security works.)

Setup Keypairs
--------------
--------------
Every cloud in PoolParty must have its own unique keypair. Thats important enough it's worth repeating: _every cloud in PoolParty must have its own unique keypair_ .

So run the following commands:

    ec2-add-keypair cloud_hadoop_slave > ~/.ssh/cloud_hadoop_slave
    ec2-add-keypair cloud_hadoop_master > ~/.ssh/cloud_hadoop_master

Security Groups
---------------
---------------
You'll also want to create a security group for our _pool_ . 

    ec2-add-group hadoop_pool -d "the pool of hadoop masters and slaves"

**NOTICE:** Hadoop has a crazy number of ports that it requires. The ports below will _work_ but may not be the most secure configuration. If you understand this better than I please recommend better settings. Otherwise proceed knowing that these ports are probably a little _too_ open.

We also need to open a number of ports for this security group:

           ec2-authorize -p 22 hadoop_pool               # ssh
           ec2-authorize -p 8642 hadoop_pool             # poolparty internal daemons
           ec2-authorize -P icmp -t -1:-1 hadoop_pool    # if you want to ping (optional, i guess)
           ec2-authorize -p 80 hadoop_pool               # apache

           ec2-authorize -p 8649 -P udp hadoop_pool      # ganglia UDP
           ec2-authorize hadoop_pool -o hadoop_pool -u xxxxxxxxxxxx # xxxxxxxxxxxx is your amazon account id. ugly but true

Start your cloud
================

What to do when something goes wrong
====================================
* Checkout the [PoolParty IRC channel](http://auser.github.com/poolparty/community.html), we're always around and ready to help #poolpartyrb. 

References
==========
* [PoolParty Documentation](http://auser.github.com/poolparty/docs/index.html)

