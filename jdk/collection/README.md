# Collection
## 方法:
    * size 
    * isEmpty
    * contains
    * iterator
    * T[] toAarry()
    * T[] toAarry(T [])
    * boolean add(E) 
    * boolean remove(E)
    * containsAll(Collection<?>)
    * addAll(Collection<?>)
    * removeAll(Collection<?>)
    * removeIf(Predicate<? super E>)
    * clear()
    * equals()
    * hashcode()
    * spliterator()
    * stream()
    * parallelStream()
    
    
## Collection
```
Collection的子接口有
List 
Set 
Queue
他们各自都有一个抽象实现类
AbstractCollection、
AbstractList、
AbstractSet、
AbstractQueue，
而AbstractList、
AbstractSet、
AbstractQueue
同时又是继承AbstractCollection的。
这些抽象类实现了Collection、List、Set、Queue接口的部分方法。
```