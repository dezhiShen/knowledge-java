# 实现
List接口的最终实现由ArrayList、LinkedList、Vector

## [ArrayList](./ArrayList.md)
 ArrayList继承了AbstractList，实现了List接口，内部是一个数组，非线程安全

## [Vector](./Vector.md)
Vector只是把ArrayList的方法前加了个synchronized，线程安全

## [LinkedList](./LinkedList.md)
LinkedList继承了AbstractSequentialList，
AbstractSequentialList了继承AbstractList，
实现了List接口，内部是一个链表。
另外，LinkedList也实现了Deque接口，
意味着它也是个双向队列，这个就跟下面的Queue接口有交叉了。
可以注意到，ArrayList和Vector都实现了RandomAccess接口，
这个接口只是个标记，
比如标记ArrayList和Vector可以通过下标快速get到元素，
因为他们是通过数组实现的，
这样在使用算法时可以针对数据采用更快的算法，
而不是跟LinkedList一样的算法。

