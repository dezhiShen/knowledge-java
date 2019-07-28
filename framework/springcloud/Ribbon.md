# Ribbon

[参考文档](https://blog.csdn.net/hry2015/article/details/78357990)

## 描述
ribbon是一个负载均衡客户端，可以很好的控制htt和tcp的一些行为。Feign默认集成了ribbon。

## 核心

`@LoadBalanced`
```
    @Bean
    @LoadBalanced
    RestTemplate restTemplate() {
        return new RestTemplate();
    }

```
向程序的ioc注入一个bean: restTemplate;
并通过`@LoadBalanced`注解表明这个restTemplate开启负载均衡的功能。

## 调用示例

```
@Service
public class HelloService {

    @Autowired
    RestTemplate restTemplate;

    public String hiService(String name) {
        return restTemplate.getForObject("http://SERVICE-HI/hi?name="+name,String.class);
    }


}
```
其中 SERVICE-HI 是服务名称

## `REGION` `ZONE`说明
这篇文章非常清晰
[参考文档](https://segmentfault.com/a/1190000014107639)

## 组件

### IRule
* 功能

根据特定算法中从服务列表中选取一个要访问的服务 

* 常用实现类
    * RoundRobinRule
    ```
    轮询规则，默认规则。同时也是更高级rules的回退策略
    ```
    * AvailabilityFilteringRule
    ``` 
        这个负载均衡器规则，会先过滤掉以下服务：
        * 由于多次访问故障而处于断路器跳闸状态
        * 并发的连接数量超过阈值
        然后对剩余的服务列表按照RoundRobinRule策略进行访问
    ```
    * WeightedResponseTimeRule 
    ```
    根据平均响应时间计算所有服务的权重，响应时间越快，服务权重越重、被选中的概率越高。
    刚启动时，如果统计信息不足，则使用RoundRobinRule策略，等统计信息足够，
    会切换到WeightedResponseTimeRule。
    ```
    * RetryRule 
    ```
    先按照RoundRobinRule的策略获取服务，
    如果获取服务失败，则在指定时间内会进行重试，获取可用的服务
    ```
    
    * BestAvailableRule 
    ```        
    此负载均衡器会先过滤掉由于多次访问故障而处于断路器跳闸状态的服务，
    然后选择一个 并发量最小 的服务
    ```
    
    * RandomRule 
    ```
    随机获取一个服务
    ```
    
### IPing

在后台运行的一个组件，用于检查服务列表是否都活
* 常用实现类
    * NIWSDiscoveryPing 
    ```
    不执行真正的ping。如果Discovery Client认为是在线，则程序认为本次心跳成功，服务活着
    ```    
    * PingUrl 
    ```
    此组件会使用HttpClient调用服务的一个URL，如果调用成功，则认为本次心跳成功，表示此服务活着。
    ```
    * NoOpPing 
    ```
    永远返回true，即认为服务永远活着
    ```
    
    * DummyPing 
    ```
    默认实现，默认返回true，即认为服务永远活着
    ```
### ServerList
[参考文档](https://blog.csdn.net/weixin_33913377/article/details/87994167)
* 功能
```
存储服务列表。分为静态和动态。如果是动态的，后台有个线程会定时刷新和过滤服务列表
```    
* 常用实现
    * ConfigurationBasedServerList 
        * 静态,从配置文件获取
    举例:`sample-client.ribbon.listOfServers=www.microsoft.com:80,www.yahoo.com:80,www.google.com:80`
    * DiscoveryEnabledNIWSServerList 
        * 从Eureka Client中获取服务列表。此值必须通过属性中的VipAddress来标识服务器集群。
        `DynamicServerListLoadBalancer`会调用此对象动态获取服务列表
    * DomainExtractingServerList 
        代理类，根据ServerList的值实现具体的逻辑
    
### ServerListFilter
* 该接口允许过滤配置或动态获取的具有所需特性的服务器列表。`ServerListFilter`是`DynamicServerListLoadBalancer`用于过滤从`ServerList`
实现返回的服务器的组件。
* 常用ServerListFilter
    * ZoneAffinityServerListFilter 
 
    过滤掉所有的不和客户端在相同zone的服务，如果和客户端相同的zone不存在，
    才不过滤不同zone有服务。
    配置`<clientName>.ribbon.EnableZoneAffinity=true`
    
    * ZonePreferenceServerListFilter 
    ```
    Spring Cloud的ZonePreferenceServerListFilter
    继承了eureka的ZoneAffinityServerListFilter，
    重写了getFilteredListOfServers方法，
    即eureka的ZoneAffinityServerListFilter计算出来没有根据zone过滤的话，
    那么它会再过滤一次，选出跟实例相同zone的server
    。注意这里进行了判断，如根据zone过滤出来为空，
    则返回父类过滤出来server，即不再根据zone进行过滤。
    ```


    
    




    

    
    



 
 






