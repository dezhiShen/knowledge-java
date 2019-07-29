# JAVA API


## org.apache.zookeeper. ZooKeeper

### 方法列表
方法名|方法功能描述
---|---
String create(String path, byte[] data, List<ACL> acl,CreateMode createMode)|	创建一个给定的目录节点 path, 并给它设置数据，CreateMode 标识有四种形式的目录节点，分别是 PERSISTENT：持久化目录节点，这个目录节点存储的数据不会丢失；PERSISTENT_SEQUENTIAL：顺序自动编号的目录节点，这种目录节点会根据当前已近存在的节点数自动加 1，然后返回给客户端已经成功创建的目录节点名；EPHEMERAL：临时目录节点，一旦创建这个节点的客户端与服务器端口也就是 session 超时，这种节点会被自动删除；EPHEMERAL_SEQUENTIAL：临时自动编号节点
Stat exists(String path, boolean watch)|	判断某个 path 是否存在，并设置是否监控这个目录节点，这里的 watcher 是在创建 ZooKeeper 实例时指定的 watcher，exists方法还有一个重载方法，可以指定特定的watcher
Stat exists(String path,Watcher watcher)|	重载方法，这里给某个目录节点设置特定的 watcher，Watcher 在 ZooKeeper 是一个核心功能，Watcher 可以监控目录节点的数据变化以及子目录的变化，一旦这些状态发生变化，服务器就会通知所有设置在这个目录节点上的 Watcher，从而每个客户端都很快知道它所关注的目录节点的状态发生变化，而做出相应的反应
void delete(String path, int version)|	删除 path 对应的目录节点，version 为 -1 可以匹配任何版本，也就删除了这个目录节点所有数据
List<String>getChildren(String path, boolean watch)|	获取指定 path 下的所有子目录节点，同样 getChildren方法也有一个重载方法可以设置特定的 watcher 监控子节点的状态
Stat setData(String path, byte[] data, int version)|	给 path 设置数据，可以指定这个数据的版本号，如果 version 为 -1 怎可以匹配任何版本
byte[] getData(String path, boolean watch, Stat stat)|	获取这个 path 对应的目录节点存储的数据，数据的版本等信息可以通过 stat 来指定，同时还可以设置是否监控这个目录节点数据的状态
voidaddAuthInfo(String scheme, byte[] auth)|	客户端将自己的授权信息提交给服务器，服务器将根据这个授权信息验证客户端的访问权限。
Stat setACL(String path,List<ACL> acl, int version)|	给某个目录节点重新设置访问权限，需要注意的是 Zookeeper 中的目录节点权限不具有传递性，父目录节点的权限不能传递给子目录节点。目录节点 ACL 由两部分组成：perms 和 id。Perms 有 ALL、READ、WRITE、CREATE、DELETE、ADMIN 几种 而 id 标识了访问目录节点的身份列表，默认情况下有以下两种：ANYONE_ID_UNSAFE = new Id("world", "anyone") 和 AUTH_IDS = new Id("auth", "") 分别表示任何人都可以访问和创建者拥有访问权限。
List<ACL>getACL(String path,Stat stat)|获取某个目录节点的访问权限列表

### 基本操作

```
public static void main(String[] ags){
    // 创建一个与服务器的连接
     ZooKeeper zk = new ZooKeeper("localhost:" + CLIENT_PORT, 
            ClientBase.CONNECTION_TIMEOUT, new Watcher() { 
                // 监控所有被触发的事件
                public void process(WatchedEvent event) { 
                    System.out.println("已经触发了" + event.getType() + "事件！"); 
                } 
            }); 
     // 创建一个目录节点
     zk.create("/testRootPath", "testRootData".getBytes(), Ids.OPEN_ACL_UNSAFE,
       CreateMode.PERSISTENT); 
     // 创建一个子目录节点
     zk.create("/testRootPath/testChildPathOne", "testChildDataOne".getBytes(),
       Ids.OPEN_ACL_UNSAFE,CreateMode.PERSISTENT); 
     System.out.println(new String(zk.getData("/testRootPath",false,null))); 
     // 取出子目录节点列表
     System.out.println(zk.getChildren("/testRootPath",true)); 
     // 修改子目录节点数据
     zk.setData("/testRootPath/testChildPathOne","modifyChildDataOne".getBytes(),-1); 
     System.out.println("目录节点状态：["+zk.exists("/testRootPath",true)+"]"); 
     // 创建另外一个子目录节点
     zk.create("/testRootPath/testChildPathTwo", "testChildDataTwo".getBytes(), 
       Ids.OPEN_ACL_UNSAFE,CreateMode.PERSISTENT); 
     System.out.println(new String(zk.getData("/testRootPath/testChildPathTwo",true,null))); 
     // 删除子目录节点
     zk.delete("/testRootPath/testChildPathTwo",-1); 
     zk.delete("/testRootPath/testChildPathOne",-1); 
     // 删除父目录节点
     zk.delete("/testRootPath",-1); 
     // 关闭连接
     zk.close(); 
 }
```