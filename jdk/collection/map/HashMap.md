# HashMap

## 底层

底层使用`数组`与`链表`实现,首先通过hashcode求模的方式获得`数组`下标,然后进行链表(元素大于1时)处理

## 方法

![HashMap](../../../assets/img/HashMap.png)

## hash实现方式
数组定位
```
  static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```
假定hashCode为1

表达式|二进制|十进制
---|---|---
1      |  0000 0001 |1
1>>>16 |  0000 0000 |0
1^(1>>>16)|0000 0001|1

`^`见[位移运算符](../../运算符.md#逻辑运算符)


## putVal
```
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```
查看原码可知,数组下标的计算方法为
`i = (n - 1) & hash`,其中`n`为内部数组长度,hash为之前hash计算得出,进行`&`运算后得到数组下标,
如果元素为空,则将该`value`构建一个node放入数组该位置,
如果不为空,则遍历链表,根据key的hash和eq判断,进行替换操作,
如果到最后一个节点`p.next==null`仍然没有结束遍历,则追加新节点