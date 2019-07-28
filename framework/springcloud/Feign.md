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

## 内部实现





