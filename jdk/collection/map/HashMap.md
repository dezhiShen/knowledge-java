# HashMap

## 底层

底层使用`数组`与`链表`实现,首先通过hashcode求模的方式获得`数组`下标,然后进行链表(元素大于1时)处理

## 方法

![HashMap](../../../assets/img/HashMap.png)

## hash实现方式
```
  static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```


## 