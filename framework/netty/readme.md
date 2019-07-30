# Netty

## 简介
netty是jboss提供的、开源的、基于nio的网络编程框架。
提供异步的、事件驱动的、高可靠的、高性能的服务，
简化了开发复杂度，提高了可靠性。
开发过程包含连接、io处理、拆包和粘包、编码和解码。
* [NIO](/../../jdk/io/NIO.md)
## 基础类

完整类名|说明
---|---
io.netty.channel.nio.NioEventLoopGroup|事件处理的线程组
io.netty.bootstrap.ServerBootstrap|启动服务的辅助类
io.netty.bootstrap.Bootstrap|客户端连接服务的辅助类
io.netty.channel.ChannelHandlerAdapter|通常继承该类，重写核心方法,详情[ChannelHandlerAdapter](#ChannelHandlerAdapter)
io.netty.channel.ChannelHandlerContext|上下文,连接ChannelHandler和ChannelPipeline
io.netty.channel.ChannelPipeline|当通道建立时，自动创建自己的pipline
io.netty.channel.ChannelHandler|处理io事件及io操作

### ChannelHandlerAdapter
* public void channelActive(ChannelHandlerContext ctx)
    * 通道可用时调用该方法。
* channelRead(ChannelHandlerContext ctx, Object msg)
    * 收到消息时调用该方法。
* exceptionCaught(ChannelHandlerContext ctx, Throwable cause)
    * 连接异常时调用该方法。
    
## 拆包和粘包
tcp数据是没有边界的流，上层协议在使用时，需要考虑拆包和粘包。
### 含义
* 折包
    * 即是一份数据，分多份传输
* 粘包
    * 即是多份数据，合成一份数据提供给上层
### 时机
* 发送数据大于ByteBuffer缓冲区时;
* 数据传输中进行了tcp分段或ip分片
### 解决方案
* 消息定长，不足补空格
* 包尾添加分隔符，如使用回车换行符
* 消息分开消息头和消息体，消息头中指定消息长度
### Netty常用类(Netty中的实现)
* io.netty.handler.codec.LineBasedFrameDecoder
    * 以换行符拆包和粘包
* io.netty.handler.codec.DelimiterBasedFrameDecoder
    * 以指定分隔符拆包和粘包
* io.netty.handler.codec.FixedLengthFrameDecoder
    * 以固定长度拆包和粘包

## 简单示例
* maven依赖
    ```
    <dependency>
        <groupId>io.netty</groupId>
        <artifactId>netty-all</artifactId>
        <version>5.0.0.Alpha2</version>
    </dependency>
    ```

* 服务端
```
package netty;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.DelimiterBasedFrameDecoder;
import io.netty.handler.codec.FixedLengthFrameDecoder;
import io.netty.handler.codec.LineBasedFrameDecoder;
import io.netty.handler.codec.string.StringDecoder;

import java.util.Scanner;

public class NettyServerMain {
    public static void main(String[] args) throws Exception {
        int port = 7001;
        //主线程组，接收网络请求
        EventLoopGroup bossGroup = new NioEventLoopGroup();
        //worker线程组，对接收到的请求进行读写处理
        EventLoopGroup workerGroup = new NioEventLoopGroup();
        //启动服务的启动类（辅助类）
        ServerBootstrap bootstrap = new ServerBootstrap();
        bootstrap.group(bossGroup, workerGroup)  // 添加主线程组和worker线程组
                .channel(NioServerSocketChannel.class)  //设置channel为服务端NioServerSocketChannel
                .childHandler(new ChannelInitializer<NioSocketChannel>() { //绑定io事件处理类
                    @Override
                    protected void initChannel(NioSocketChannel nioSocketChannel) throws Exception {
                        ChannelPipeline pipeline = nioSocketChannel.pipeline();

                        //以指定分隔符$拆包和粘包
//                        pipeline.addLast(new DelimiterBasedFrameDecoder(1024, Unpooled.copiedBuffer("$".getBytes())));
                        //以固定长度拆包和粘包
//                        pipeline.addLast(new FixedLengthFrameDecoder(10));
                        //以换行符拆包和粘包
                        pipeline.addLast(new LineBasedFrameDecoder(1024));

                        pipeline.addLast(new StringDecoder()); //将收到对象转为字符串
                        pipeline.addLast(new IODisposeHandler()); //添加io处理器
                    }
                })
                .option(ChannelOption.SO_BACKLOG, 128) //设置日志
                .option(ChannelOption.SO_SNDBUF, 32 * 1024) //设置发送缓存
                .option(ChannelOption.SO_RCVBUF, 32 * 1024)  //接收缓存
                .childOption(ChannelOption.SO_KEEPALIVE, true);  //是否保持连接

        //绑定端口，同步等待成功
        ChannelFuture future = bootstrap.bind(port).sync();
        System.out.println("服务启动,等待连接");

        //关闭监听端口，同步等待
        future.channel().closeFuture().sync();

        //退出，释放线程资源
        bossGroup.shutdownGracefully();
        workerGroup.shutdownGracefully();
    }

    static class IODisposeHandler extends ChannelHandlerAdapter {
        private WriteThread writeThread;

        /**
         * 建立连接
         *
         * @param ctx
         * @throws Exception
         */
        @Override
        public void channelActive(ChannelHandlerContext ctx) throws Exception {
            System.out.println("收到连接:" + ctx.channel());
            //新起写数据线程
            writeThread = new WriteThread(ctx);
            writeThread.start();
        }

        /**
         * 消息读取
         *
         * @param ctx
         * @param msg
         * @throws Exception
         */
        @Override
        public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
            System.out.println("server receive msg:" + msg);
            // System.out.println("server receive msg:"+((ByteBuf)msg).toString(CharsetUtil.UTF_8));
            // 不使用StringDecoder解码时，则需使用此类解码
        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            cause.printStackTrace();
            writeThread.runFlag = false;
            ctx.close();
        }
    }

    /**
     * 写数据线程
     */
    static class WriteThread extends Thread {
        ChannelHandlerContext ctx;
        //线程关闭标志位
        volatile boolean runFlag = true;

        public WriteThread(ChannelHandlerContext ctx) {
            this.ctx = ctx;
        }

        @Override
        public void run() {
            try {
                Scanner scanner = new Scanner(System.in);
                while (runFlag) {
                    System.out.print("server send msg:");
                    String msg = scanner.nextLine();
                    msg += System.lineSeparator();
                    //发送数据
                    ctx.channel().writeAndFlush(Unpooled.copiedBuffer(msg.getBytes()));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

```

* 客户端
```
package netty;

import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.LineBasedFrameDecoder;
import io.netty.handler.codec.string.StringDecoder;

import java.util.Scanner;

public class NettyClientMain {
    public static void main(String[] args) throws Exception {
        EventLoopGroup workerGroup = new NioEventLoopGroup();
        Bootstrap bootstrap = new Bootstrap();
        bootstrap.group(workerGroup)
                .channel(NioSocketChannel.class)
                .handler(new ChannelInitializer<NioSocketChannel>() {
                    @Override
                    protected void initChannel(NioSocketChannel nioSocketChannel) throws Exception {
                        ChannelPipeline pipeline = nioSocketChannel.pipeline();
                        //以指定分隔符$拆包和粘包
//                        pipeline.addLast(new DelimiterBasedFrameDecoder(1024, Unpooled.copiedBuffer("$".getBytes())));
                        //以固定长度拆包和粘包
//                        pipeline.addLast(new FixedLengthFrameDecoder(10));
                        //以换行符拆包和粘包
                        pipeline.addLast(new LineBasedFrameDecoder(1024));

                        pipeline.addLast(new StringDecoder());
//                        pipeline.addLast(new StringEncoder());
                        pipeline.addLast(new IODisposeHandler());
                    }
                });
        ChannelFuture future = bootstrap.connect("127.0.0.1", 7001).sync();
        future.channel().closeFuture().sync();
        workerGroup.shutdownGracefully();
    }

    /**
     * io事件处理
     */
    static class IODisposeHandler extends ChannelHandlerAdapter {

        WriteThread writeThread;

        /**
         * 建立连接
         *
         * @param ctx
         * @throws Exception
         */
        @Override
        public void channelActive(ChannelHandlerContext ctx) throws Exception {
            System.out.println("收到连接:" + ctx.channel());

            //新起写数据线程
            writeThread = new WriteThread(ctx);
            writeThread.start();
        }


        /**
         * 消息读取
         *
         * @param ctx
         * @param msg
         * @throws Exception
         */
        @Override
        public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
            System.out.println("server receive msg:" + msg);
        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            System.out.println("连接出错");
            writeThread.runFlag = false;
            ctx.close();
        }
    }


    /**
     * 写数据线程
     */
    static class WriteThread extends Thread {
        ChannelHandlerContext ctx;
        //线程关闭标志位
        volatile boolean runFlag = true;

        public WriteThread(ChannelHandlerContext ctx) {
            this.ctx = ctx;
        }

        @Override
        public void run() {
            try {
                Scanner scanner = new Scanner(System.in);
                while (runFlag) {
                    System.out.print("server send msg:");
                    String msg = scanner.nextLine();
                    msg += System.lineSeparator();
                    //发送数据
                    ctx.channel().writeAndFlush(Unpooled.copiedBuffer(msg.getBytes()));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

```


    
    
    
