# Eureka 服务注册中心

## 服务端

* 结合springboot 增加启动类注解`@EnableEurekaServer`,启动后即可完成最简单的eureka服务注册中心

```

@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run( EurekaServerApplication.class, args );
    }
}

```
* 配置

在默认情况下erureka server也是一个eureka client ,必须要指定一个 server
```
server:
  port: 8761

eureka:
  instance:
    hostname: localhost
  client:
    registerWithEureka: false
    fetchRegistry: false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/

spring:
  application:
    name: eurka-server
```
`eureka.client.registerWithEureka:false`,`eureka.client.fetchRegistry:false`表明自己是一个eureka server



## 客户端

当client向server注册时，它会提供一些元数据，例如主机和端口，URL，主页等。Eureka server 从每个client实例接收心跳消息。 如果心跳超时，则通常将该实例从注册server中删除。
* 结合springboot 增加启动类注解`@EnableEurekaClient`,启动后即可完成最简单的eureka服务注册中心
```
@SpringBootApplication
@EnableEurekaClient
@RestController
public class ServiceHiApplication {

    public static void main(String[] args) {
        SpringApplication.run( ServiceHiApplication.class, args );
    }
}
```

* 配置
```
server:
  port: 8762

spring:
  application:
    name: service-xxx

eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/

```
