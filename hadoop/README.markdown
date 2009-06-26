"Easily" setup a monitored Hadoop / Hive Cluster in EC2 with PoolParty
======================================================================

Summary
=======

Setting up a scalable Hadoop cluster isn't easy, but PoolParty makes it easier
and manageable.

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



What to do when something goes wrong
====================================
* Checkout the [PoolParty IRC channel](http://auser.github.com/poolparty/community.html), we're always around and ready to help #poolpartyrb. 

References
==========
* [PoolParty Documentation](http://auser.github.com/poolparty/docs/index.html)

