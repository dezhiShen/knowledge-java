# zookeeper配置

## 目录
* [tickTime](#tickTime)
* [dataDir](#dataDir)
* [clientPort](#clientPort)
* [dataLogDir](#dataLogDir)
* [tickTime](#tickTime)

## 独立模式 
### DEMO(独立模式)
```
tickTime=2000
dataDir=/usr/zdatadir
dataLogDir=/usr/zlogdir
clientPort=2181
initLimit=5
syncLimit=2
```

### tickTime
* 基本事件单元，以`毫秒`为单位。它用来控制**心跳和超时**，默认情况下最小的会话超时时间为两倍的tickTime。
### dataDir
是存放内存数据库快照的位置； 
### clientPort
client连接的端口
### dataLogDir
是事务日志目录 

## 复制模式
**把提供相同应用的服务器组称之为一个`quorum`，`quorum`中的所有机器都有相同的配置文件**
### DEMO(复制模式)

```
tickTime=2000
dataDir=/usr/zdatadir
dataLogDir=/usr/zlogdir
clientPort=2181
initLimit=5
syncLimit=2
server.1=cloud:2888:3888
server.2=cloud02:2888:3888
server.3=cloud03:2888:3888
server.4=cloud04:2888:3888
server.5=cloud05:2888:3888
```


### initLimit
* 这个配置项是用来配置 Zookeeper 接受客户端
    (这里所说的客户端不是用户连接 Zookeeper 服务器的客户端,
    而是 Zookeeper 服务器集群中连接到 `Leader` 的 `Follower` 服务器)
    初始化连接时最长能忍受多少个心跳时间间隔数。
    当已经超过5个心跳的时间(也就是 tickTime)长度后 
    Zookeeper服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。
    总的时间长度就是 `5*2000ms=10s` 秒 
### syncLimit
* 这个配置项标识 `Leader` 与 `Follower` 之间发送消息,
请求和应答时间长度,最长不能超过多少个 `tickTime` 的时间长度，
总的时间长度就是 `2*2000ms=4s` 秒 
 
### server.A=B\:C\:D
* A 
    * 代表组成整个服务的机器，当服务启动时，会在数据目录下查找这个文件[myid](#myid),这个文件中存有服务器的号码
* B
    * 这个服务器的 ip 地址
* C 
    * 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口
* D
    * 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口
* 可以启动在同一机器上

### myid
在`dataDir`下新建`myid`文件 ,填入各主机之`ID(server.A=B:C:D中的A)`。如cloud机器的myid文件内容为1。

### 注意事项
**注意节点之间能够互相访问** 


