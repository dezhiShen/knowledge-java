# ZNode

## 节点类型
```
PERSISTENT                持久化节点
PERSISTENT_SEQUENTIAL     顺序自动编号持久化节点，这种节点会根据当前已存在的节点数自动加 1
EPHEMERAL                 临时节点， 客户端session超时这类节点就会被自动删除
EPHEMERAL_SEQUENTIAL      临时自动编号节点
```