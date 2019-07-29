# zookeeper常用命令

## zkServer.sh
参数|说明
---|---
start|启动
status|状态


## 节点相关
* 使用zkCli.sh连接服务端
### ls
* 查看节点
* `ls /`
### get
* 获取信息
* `get /`
* 说明

    名称|说明
    ---|---
    cZxid|创建节点的id
    ctime| 节点的创建时间
    mZxid|修改节点的id
    mtime|修改节点的时间
    pZxid|子节点的id
    cversion|子节点的版本
    dataVersion| 当前节点数据的版本
    aclVersion|权限的版本
    ephemeralOwner|判断是否是临时节点
    dataLength| 数据的长度
    numChildren|子节点的数量

### stat
* 获取,更新信息
* 与get类似

### ls2
* ls命令和stat命令的整合

### 



