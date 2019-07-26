# 反射

## 基础


## 代理

代理设计模式是Java常用的设计模式之一。

### 特点

1. 委托类和代理类有共同的接口或者父类；
2. 代理类负责为委托类处理消息，并将消息转发给委托类
3. 委托类和代理类对象通常存在关联关系，一个代理类对象与一个委托类对象关联
4. 代理类本身不是真正的实现者，而是通过调用委托类方法来实现代理功能

### 静态代理
由我们程序猿或者特定的工具自动生成了源代码，在程序运行之前，class文件已经存在了；例如在serviceImpl.java中调用dao.xx()，真正的实现者是dao，service就可以理解为一个代理类；

### 动态代理

* 步骤
    1. 创建被代理的接口和类
    2. 创建InvocationHandler接口的实现类，在invoke方法中实现代理逻辑
    3. 通过Proxy的静态方法newProxyInstance( ClassLoaderloader, Class[] interfaces, InvocationHandler h)创建一个代理对象
    4. 使用代理对象。

* Demo 
    1. 创建被代理的接口和类
    ```
    public interface Cat {
        void run(int speed);
    }
    ```
    ```
    public class BmwCat implements Cat {
        public void run(int speed) {
            System.out.println("bmw is running and the speed is " + speed + "km/h");
        }
    }
    ```

    2. InvocationHandler
    此接口为动态代理类的实现接口,此接口只有一个invoke方法
    ```
    public Object invoke(Object proxy, Method method, Object[] args)
        throws Throwable;
    ```
    参数说明:
    ```
    proxy：代理类对象
    method：被代理的方法
    args：被代理方法的参数列表
    ```
    具体实现
    ```
    public class CatInvocationHandler implements InvocationHandler {
        private Object target;
    
        public CatInvocationHandler(Object target) {
            this.target = target;
        }
    
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            System.out.println("start run");
            Object returnValue = method.invoke(target, args);
            System.out.println("run end");
            return returnValue;
        }
    }    
    ```
    3. Proxy创建和调用
    ```
    public class Main {
        public static void main(String[] args) {
            Cat a = new BmwCat();
            CatInvocationHandler catInvocationHandler = new CatInvocationHandler(a);
            Cat proxy = (Cat) Proxy.newProxyInstance(
                    Main.class.getClassLoader(),
                    a.getClass().getInterfaces(),
                    catInvocationHandler
            );
            proxy.run(100);
        }
    }
    ```
    
    4. 运行结果:
    ```
    start run
    bmw is running and the speed is 100km/h
    run end
    ```
    
* 源码解读
    * `newProxyInstance`的实现
    
    `Proxy.newProxyInstance( ClassLoaderloader, Class[] interfaces, InvocationHandler h)`
        
    ```
    public static Object newProxyInstance(ClassLoader loader,
                                          Class<?>[] interfaces,
                                          InvocationHandler h)
        throws IllegalArgumentException{
        //检验h不为空，h为空抛异常
        Objects.requireNonNull(h);
        //接口的类对象拷贝一份
        final Class<?>[] intfs = interfaces.clone();
        //进行一些安全性检查
        final SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
            checkProxyAccess(Reflection.getCallerClass(), loader, intfs);
        }
        /*
         * Look up or generate the designated proxy class.
         *  查询（在缓存中已经有）或生成指定的代理类的class对象。
         */
        Class<?> cl = getProxyClass0(loader, intfs);
        /*
         * Invoke its constructor with the designated invocation handler.
         */
        try {
            if (sm != null) {
                checkNewProxyPermission(Reflection.getCallerClass(), cl);
            }
            //得到代理类对象的构造函数，这个构造函数的参数由constructorParams指定
            //参数constructorParames为常量值：private static final Class<?>[] constructorParams = { InvocationHandler.class };
            final Constructor<?> cons = cl.getConstructor(constructorParams);
            final InvocationHandler ih = h;
            if (!Modifier.isPublic(cl.getModifiers())) {
                AccessController.doPrivileged(new PrivilegedAction<Void>() {
                    public Void run() {
                        cons.setAccessible(true);
                        return null;
                    }
                });
            }
            //这里生成代理对象，传入的参数new Object[]{h}后面讲
            return cons.newInstance(new Object[]{h});
        } catch (IllegalAccessException|InstantiationException e) {
            throw new InternalError(e.toString(), e);
        } catch (InvocationTargetException e) {
            Throwable t = e.getCause();
            if (t instanceof RuntimeException) {
                throw (RuntimeException) t;
            } else {
                throw new InternalError(t.toString(), t);
            }
        } catch (NoSuchMethodException e) {
            throw new InternalError(e.toString(), e);
        }
    }
    ```
    
    * `getProxyClass0`
    
    ```
    private static Class<?> getProxyClass0(ClassLoader loader,
                                           Class<?>... interfaces) {
        if (interfaces.length > 65535) {
            throw new IllegalArgumentException("interface limit exceeded");
        }
        // If the proxy class defined by the given loader implementing
        // the given interfaces exists, this will simply return the cached copy;
        // otherwise, it will create the proxy class via the ProxyClassFactory
        //意思是：如果代理类被指定的类加载器loader定义了，并实现了给定的接口interfaces，
        //那么就返回缓存的代理类对象，否则使用ProxyClassFactory创建代理类。
        return proxyClassCache.get(loader, interfaces);
    }
    ```

 




    