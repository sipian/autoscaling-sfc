sudo apt-get install npm vim git git-review diffstat bridge-utils -y
sudo apt-get install -y python-pip

    cd $HOME
    sudo apt-get install -y git libtool m4 autoconf automake make libssl-dev libcap-ng-dev python3 python-six vlan iptables \
         graphviz debhelper dh-autoreconf python-all python-qt4 python-twisted-conch
    git clone https://github.com/openvswitch/ovs.git
    git clone https://github.com/yyang13/ovs_nsh_patches.git
    cd ovs
    git reset --hard 7d433ae57ebb90cd68e8fa948a096f619ac4e2d8
    cp ../ovs_nsh_patches/*.patch ./
    git config user.email odl@opendaylight.org
    git config user.name odl
    git am *.patch
    sudo DEB_BUILD_OPTIONS='parallel=8 nocheck' fakeroot debian/rules binary
    sudo dpkg -i $HOME/openvswitch-datapath-dkms* $HOME/openvswitch-common* $HOME/openvswitch-switch* ../python-openvswitch*
    