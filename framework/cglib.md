# CGLIB
cglib是针对类来实现代理的,原理是对指定的业务类生成一个子类,并覆盖其中业务方法实现代理。因为采用的是继承,所以不能对final修饰的类进行代理。

## 实现步骤
1. 首先定义业务类,无需实现接口（当然,实现接口也可以,不影响的）
```
public class BookFacadeImpl1 {  
    public void addBook() {  
        System.out.println("新增图书...");  
    }  
}  
```
2. 实现`MethodInterceptor`方法代理接口,创建代理类
```
public class BookFacadeCglib implements MethodInterceptor {  
    private Object target;//业务类对象,供代理方法中进行真正的业务方法调用
  
    //相当于JDK动态代理中的绑定
    public Object getInstance(Object target) {  
        this.target = target;  //给业务对象赋值
        Enhancer enhancer = new Enhancer(); //创建加强器,用来创建动态代理类
        enhancer.setSuperclass(this.target.getClass());  //为加强器指定要代理的业务类（即：为下面生成的代理类指定父类）
        //设置回调：对于代理类上所有方法的调用,都会调用CallBack,而Callback则需要实现intercept()方法进行拦
        enhancer.setCallback(this); 
       // 创建动态代理类对象并返回  
       return enhancer.create(); 
    }
    // 实现回调方法 
    public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable { 
        System.out.println("预处理——————");
        proxy.invokeSuper(obj, args); //调用业务类（父类中）的方法
        System.out.println("调用后操作——————");
        return null; 
    }
} 
```
3. 创建业务类和代理类对象,然后通过  代理类对象.getInstance(业务类对象)  返回一个动态代理类对象（它是业务类的子类,可以用业务类引用指向它）。最后通过动态代理类对象进行方法调用。
```
    public static void main(String[] args) {      
        BookFacadeImpl1 bookFacade=new BookFacadeImpl1()；
        BookFacadeCglib  cglib=new BookFacadeCglib();  
        BookFacadeImpl1 bookCglib=(BookFacadeImpl1)cglib.getInstance(bookFacade);  
        bookCglib.addBook();  
    } 
```

## 比较
* 静态代理:
    * 静态代理是通过在代码中显式定义一个业务实现类一个代理,在代理类中对同名的业务方法进行包装,用户通过代理类调用被包装过的业务方法；
* JDK动态代理:
    * 通过接口中的方法名,在动态生成的代理类中调用业务实现类的同名方法;
* CGlib动态代理:
    * 通过继承业务类,生成的动态代理类是业务类的子类,通过重写业务方法进行代理





 


