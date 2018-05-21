## GlusterFS分布式存储应用 - 复制卷基于Keepalived高可用

### GlusterFS

GFS数据存储分区准备
    
    mkdir -p /glusterfs/storage1
    echo "/dev/VolGroup01/lv_data1    /glusterfs/storage1    ext4    defaults    0 0" >> /etc/fstab
    mount -a

安装GlusterFS服务
    
    yum install centos-release-gluster -y
    yum install glusterfs glusterfs-server glusterfs-cli glusterfs-geo-replication glusterfs-rdma -y
    /etc/init.d/glusterd start

安装Glusterfs客户端
    
    yum install glusterfs-fuse

添加信任节点
    
    gluster peer probe data-node-02
    gluster peer probe data-node-01

    gluster peer status

创建复制卷
    
    mkdir /glusterfs/storage1/rep_vol1
    gluster volume create rep_vol1 replica 2 data-node-01:/glusterfs/storage1/rep_vol1 data-node-02:/glusterfs/storage1/rep_vol1

启动复制卷
    
    gluster volume start rep_vol1

查看数据卷状态
    
    gluster volume status
    gluster volume info

客户端挂载数据卷
    
    mount -t glusterfs data-node-01:rep_vol1 /data/

测试数据
    
    for i in `seq -w 1 3`;do cp -rp /var/log/messages /data/test-$i;done

### Keepalived

安装Keepalived
    
    yum install gcc gcc-c++ pcre-devel openssl-devel popt-devel libnfnetlink libnfnetlink-devel libnl3-devel net-snmp-devel
    wget http://www.keepalived.org/software/keepalived-1.3.2.tar.gz
    
    ./configure --prefix=/usr/local/keepalived --enable-snmp --with-kernel-dir=/usr/src/kernels/`uname -r`
    make && make install
    
    cp keepalived/etc/init.d/keepalived /etc/init.d/keepalived
    cp keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived
    chmod 755 /etc/init.d/keepalived
    cp /usr/local/keepalived/sbin/keepalived /usr/sbin/
    cp /usr/local/keepalived/bin/genhash /usr/bin/

    vim /etc/sysconfig/keepalived
    KEEPALIVED_OPTIONS="-D -f /usr/local/keepalived/etc/keepalived/keepalived.conf"

    scp /etc/init.d/keepalived data-node-02:/etc/init.d/keepalived
    scp /etc/sysconfig/keepalived data-node-02:/etc/sysconfig/keepalived

    chkconfig keepalived on

添加vrrp防火墙规则
    
    iptables -I INPUT -p vrrp -s 192.168.2.0/24 -j ACCEPT
    tcpdump -vv -i eth0 vrrp

启动keepalived服务
    
    /etc/init.d/keepalived start

使用VIP挂载GFS挂载卷
    
    mount -t glusterfs 192.168.2.220:rep_vol1 /data/


