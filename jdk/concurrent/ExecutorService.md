# ExecutorService

ExecutorService是异步处理的完整解决方案。
它管理内存中队列并根据线程可用性计划提交的任务。

## 线程池

   ```
   ThreadPoolExecutor
   构造方法:
    public ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> workQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler) {
        if (corePoolSize < 0 ||
            maximumPoolSize <= 0 ||
            maximumPoolSize < corePoolSize ||
            keepAliveTime < 0)
            throw new IllegalArgumentException();
        if (workQueue == null || threadFactory == null || handler == null)
            throw new NullPointerException();
        this.acc = System.getSecurityManager() == null ?
                null :
                AccessController.getContext();
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }
   ```
   
   参数说明:
   
   名称|描述
   ---|---
   corePoolSize|线程池维护线程的最少数量
   maximumPoolSize|线程池维护线程的最大数量
   keepAliveTime|线程池维护线程所允许的空闲时间
   unit|线程池维护线程所允许的空闲时间的单位
   workQueue|线程池所使用的缓冲队列
   handler|线程池对拒绝任务的处理策略

## 线程池类型

* newCachedThreadPool创建一个可缓存线程池，如果线程池长度超过处理需要，可灵活回收空闲线程，若无可回收，则新建线程。
* newFixedThreadPool创建一个定长线程池，可控制线程最大并发数，超出的线程会在队列中等待。
* newScheduledThreadPool 创建一个定长线程池，支持周期和定时任务
* newSingleThreadExecutor创建一个单线程化的线程池，只会用工作线程来执行任务，保证顺序

## 任务队列

* ArrayBlockingQueue:
    基于数组实现的一个阻塞队列，
    在创建ArrayBlockingQueue对象时必须制定容量大小。
    并且可以指定公平性与非公平性，默认情况下为非公平的，
    即不保证等待时间最长的队列最优先能够访问队列。

* LinkedBlockingQueue:
    基于链表实现的一个阻塞队列，
    在创建LinkedBlockingQueue对象时如果不指定容量大小，
    则默认大小为Integer.MAX_VALUE。

* PriorityBlockingQueue:
    以上2种队列都是先进先出队列，
    而PriorityBlockingQueue却不是，
    它会按照元素的优先级对元素进行排序，
    按照优先级顺序出队，
    每次出队的元素都是优先级最高的元素。
    注意，此阻塞队列为无界阻塞队列，
    即容量没有上限（通过源码就可以知道，它没有容器满的信号标志），
    前面2种都是有界队列。

* DelayQueue:
    基于PriorityQueue，一种延时阻塞队列，
    DelayQueue中的元素只有当其指定的延迟时间到了，
    才能够从队列中获取到该元素。
    DelayQueue也是一个无界队列，
    因此往队列中插入数据的操作（生产者）永远不会被阻塞，
    而只有获取数据的操作（消费者）才会被阻塞。

## 拒绝策略

如果此时线程池中的数量大于corePoolSize，缓冲队列workQueue满，
并且线程池中的数量等于maximumPoolSize，
那么通过 handler所指定的策略来处理此任务。
也就是：处理任务的优先级为：
核心线程corePoolSize、
任务队列workQueue、
最大线程maximumPoolSize，
如果三者都满了，
使用handler处理被拒绝的任务。

名称|说明
---|---
AbortPolicy(默认)|抛出java.util.concurrent.RejectedExecutionException异常
CallerRunsPolicy|用于被拒绝任务的处理程序，它直接在execute方法的调用线程中运行被拒绝的任务；如果执行程序已关闭，则会丢弃该任务。
DiscardOldestPolicy|对拒绝任务不抛弃，而是抛弃队列里面等待最久的一个线程，然后把拒绝任务加到队列。
DiscardPolicy |对拒绝任务直接无声抛弃，没有异常信息。



 

