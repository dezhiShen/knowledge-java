# NIO
JDK 1.4中的java.nio.*包中引入新的Java I/O库，其目的是提高速度。实际上，**"旧"的I/O包已经使用NIO重新实现过，即使我们不显式的使用NIO编程，也能从中受益。**


### IO和NIO的区别

IO是面向流`Stream`的处理，NIO是面向块(缓冲区)`Buffer`的处理,NIO非阻塞,需要Selectors协助
* 面向流的I/O,系统一次一个字节地处理数据
* 面向块(缓冲区)的I/O系统以块的形式处理数据。

### NIO核心

* Buffer缓冲区
* Channel管道
* Selector选择器

在NIO中并不是以流的方式来处理数据的，而是以buffer缓冲区和Channel管道配合使用来处理数据。
**Channel管道比作成铁路，buffer缓冲区比作成火车(运载着货物)**
NIO就是通过Channel管道运输着存储数据的Buffer缓冲区的来实现数据的处理！
* Channel只运输数据
* Buffer才是数据








