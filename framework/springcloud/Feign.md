# Feign
单纯基于Ribbon的调用不够优雅,可以使用Feign进行封装,开发人员在使用时,会和调用本地接口一样无感
**Feign内部默认集成Ribbon进行负载均衡**
**整合了Hystrix，具有熔断的能力**

## 核心
`@FeignClient`
```
@FeignClient(value = "service-hi")
public interface ServiceHi {
    @RequestMapping(value = "/hi",method = RequestMethod.GET)
    String sayHiFromClientOne(@RequestParam(value = "name") String name);
}
```

`@FeignClient` 配置服务名,使用`@RequestMapping`配置远程方法

## Hystrix
`feign.hystrix.enabled=true`打开断路由
* fallback

在`@FeignClient`中属性`fallback`填写当前类的实现,每个方法可以写自己的fallback

* fallbackFactory

可以对fallback进行统一处理,实现接口`FallbackFactory`






