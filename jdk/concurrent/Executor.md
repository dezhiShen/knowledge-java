# Executor

Executor是一个表示执行提供的任务的对象的接口。
如果任务应在新线程或当前线程上运行，则它取决于特定实现（从启动调用的位置）。
因此，使用此接口，我们可以将任务执行流与实际任务执行机制分离。
这里要注意的一点是，Executor并不严格要求任务执行是异步的。
在最简单的情况下，执行程序可以在调用线程中立即调用提交的任务。
我们需要创建一个调用者来创建执行者实例：
```
    public static void main(String[] args) {
        Executor executor = new Executor() {
            //如何执行任务
            public void execute(Runnable command) {
                command.run();
            }
        };
        executor.execute(new Runnable() {
            public void run() {
                //任务内容
                System.out.println("2");
            }
        });
    }
```



