# Ribbon

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



