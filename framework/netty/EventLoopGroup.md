# EventLoopGroup

## NioEventLoopGroup

### 过程
1. NioEventLoop创建
2. NioEventLoop启动
3. NioEventLoop执行逻辑

```
//接收客户端的TCP连接
private EventLoopGroup bossGroup = new NioEventLoopGroup(1);
//用于处理I/O相关的读写操作，或者执行Task
private EventLoopGroup workerGroup = new NioEventLoopGroup();
```
服务端启动的时候，创建了两个NioEventLoopGroup，它们实际是两个独立的Reactor线程池。一个用于接收客户端的TCP连接，另一个用于处理I/O相关的读写操作，或者执行系统Task、定时任务Task等。

Netty用于接收客户端请求的线程池职责如下。
* 接收客户端TCP连接，初始化Channel参数
* 将链路状态变更事件通知给ChannelPipeline

Netty处理I/O操作的Reactor线程池职责如下。
* 异步读取通信对端的数据报，发送读事件到ChannelPipeline；
* 异步发送消息到通信对端，调用ChannelPipeline的消息发送接口
* 执行系统调用Task
* 执行定时任务Task，例如链路空闲状态监测定时任务
 


