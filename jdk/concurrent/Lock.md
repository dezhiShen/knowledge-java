# Lock
这是一个接口,定义了Lock的一些必要方法
简单来说，相对于synchronized ，锁是一种更灵活和精巧的线程同步机制。

Lock接口从Java 1.5后出现，在java.util.concurrent.lock包中定义了Lock接口，并提供了锁的一些扩展操作。

## synchronized和Lock API的使用有一些不同之处
* synchronized block 只能在一个方法内– Lock API的 lock() 和 unlock() 操作可以在不同的方法中
* synchronized 不支持公平锁，锁释放后处于等待的线程都有可能获得锁，也就是不能指定优先级。 而我们却可以通过Lock API指定参数来实现公平锁，确保等待时间最长的线程最先获得锁
如果线程无法访问synchronized块，就会发生阻塞。Lock API提供了 **tryLock() 
方法，只有在锁可用而且没有被其他线程持有时去获得锁** ，这减小了线程等待锁的阻塞时间
* 处于“waiting”状态的线程获得synchronized块时，不能被中断。而Lock API提供了lockInterruptibly() 方法，可以中断正在等待锁的线程

## API列表
* void lock() – 如果锁可用就获得锁，如果锁不可用就阻塞直到锁释放
* void lockInterruptibly() – 和 lock()方法相似, 但阻塞的线程可中断，抛出 java.lang.InterruptedException异常
* boolean tryLock() –lock() 方法的非阻塞版本;尝试获取锁，如果成功返回true
* boolean tryLock(long timeout, TimeUnit timeUnit) – 和tryLock()方法相似，只是 在放弃尝试获取锁之前等待指定的时间。
* void unlock() – 释放锁

## ReadWriteLock 

除了Lock 接口，还有一个ReadWriteLock 接口，ReadWriteLock 接口维护了一对锁。一个只用于读操作，一个用于写操作。只有没有写入操作，读锁可以同时被多个线程持有。 
ReadWriteLock 声明了获取读或写的锁:
* Lock readLock() – 返回读线程的锁
* Lock writeLock() – 返回写线程的锁

## 具体实现

###  ReentrantLock 
* ReentrantLock 类实现了 Lock 接口，不仅提供了跟synchronized 方法和语句使用的隐式monitor锁相同的并发和内存语义 ，而且扩展了其功能。 
使用
```
public class LockTest {
    public static void main(String[] args) {
        ReentrantLock reentrantLock = new ReentrantLock();
        new Thread(() ->
        {
            reentrantLock.lock();
            System.out.println(System.currentTimeMillis() + "\tt1");
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            reentrantLock.unlock();
        }
        ).start();
        new Thread(() ->
        {
            reentrantLock.lock();
            System.out.println(System.currentTimeMillis() + "\tt2");
            reentrantLock.unlock();
        }
        ).start();

    }
}

输出:
1564217928539	t1
1564217930540	t2
```

### ReentrantReadWriteLock
内置 ReadLock和WriteLock,获取锁后使用方式和 ReentrantLok类似


### Condition 类提供了在临界区线程可以等待某些条件发生时再去执行。 
这种情况发生在当线程获得了临界区的访问但没有必要的条件去执行某些操作。比如，一个读线程获得了共享式队列的锁，但是没有任何数据用于消费。
一般来说，Java提供了wait(), notify() 和 notifyAll() 用于线程间通信，Conditions 类的有着类似的通信机制，除此之外，可以指定多个条件.
`await()`,`signal()`,`signalAll()`,
```
public class ReentrantLockWithCondition {

    Stack<String> stack = new Stack<>();
    int CAPACITY = 5;

    ReentrantLock lock = new ReentrantLock();
    Condition stackEmptyCondition = lock.newCondition();
    Condition stackFullCondition = lock.newCondition();

    public void pushToStack(String item){
        try {
            lock.lock();
            while(stack.size() == CAPACITY){
                stackFullCondition.await();
            }
            stack.push(item);
            stackEmptyCondition.signalAll();
        } finally {
            lock.unlock();
        }
    }

    public String popFromStack() {
        try {
            lock.lock();
            while(stack.size() == 0){
                stackEmptyCondition.await();
            }
            return stack.pop();
        } finally {
            stackFullCondition.signalAll();
            lock.unlock();
        }
    }
}
```