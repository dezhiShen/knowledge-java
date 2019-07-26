# IO

## IO分类

### 按操作分类

* 文件 (file)
FileInputStream FileOutputStream FileReader FileWriter
* 数组 (\[\])
    * 字节数组(byte\[\])
        * `ByteArrayInputStream`
        * `ByteArrayOutputStream`
    * 字符数组 (char\[\])
        * `CharArrayReader`
        * `CharArrayWriter`
* 管道操作
    * `PipedInputStream`
    * `PipedOutputStream`
    * `PipedReader`
    * `PipedWriter`
* 基本数据类型
    * `DataInputStream`
    * `DataOutputStream`
* 缓冲操作
    * `BufferedInputStream `
    * `BufferedOutputStream`
    * `BufferedReader`
    * `BufferedWriter`
* 打印
    * `PrintStream`
    * `PrintWriter`
* 对象序列化反序列化
    * `ObjectInputStream`
    * `ObjectOutputStream`
* 转换
    * `InputStreamReader`
    * `OutputStreamWriter`
* ~~字符串 (String)Java8中已废弃~~
    * ~~`StringBufferInputStream`~~
    * ~~`StringBufferOutputStream`~~
    * ~~`StringReader`~~
    * ~~`StringWriter`~~

### 按数据传输方式分类

* 字节流

    字节流是以一个字节单位来运输的，比如一杯一杯的取水。
* 字符流

    字符流是以多个字节来运输的，比如一桶一桶的取水，一桶水又可以分为几杯水。
    
* 区别
    ```
    字节流读取单个字节，
    字符流读取单个字符（一个字符根据编码的不同，
    对应的字节也不同，
    如 UTF-8 编码是 3 个字节，中文编码是 2 个字节。）
    字节流用来处理二进制文件
    （图片、MP3、视频文件），
    字符流用来处理文本文件（可以看做是特殊的二进制文件，
    使用了某种编码，人可以阅读）。
    简而言之，字节是个计算机看的，字符才是给人看的。
    ```
!\[\](../../assets/img/ioStream.png)

## io接口类说明

### InputStream 

方法|方法介绍
---|---
public abstract int read()|读取数据
public int read(byte b\[\])|将读取到的数据放在 byte 数组中，该方法实际上是根据下面的方法实现的，off 为 0，len 为数组的长度
public int read(byte b\[\], int off, int len)|从第 off 位置读取 len 长度字节的数据放到 byte 数组中，流是以 -1 来判断是否读取结束的 **这里读取的虽然是一个字节，但是返回的却是 int 类型 4 个字节**
public long skip(long n)|跳过指定个数的字节不读取，类似看电影跳过片头片尾
public int available()|返回可读的字节数量
public void close()|读取完，关闭流，释放资源
public synchronized void mark(int readlimit)|标记读取位置，下次还可以从这里开始读取，使用前要看当前流是否支持，可以使用 markSupport() 方法判断
public synchronized void reset()|重置读取位置为上次 mark 标记的位置
public boolean markSupported()|判断当前流是否支持标记流，和上面两个方法配套使用

### OutputStream 
方法|方法介绍
---|---
public abstract void write(int b)|写入一个字节，可以看到这里的参数是一个 int 类型，对应上面的读方法，int 类型的 32 位，只有低 8 位才写入，高 24 位将舍弃。
public void write(byte b\[\])|将数组中的所有字节写入，和上面对应的 read() 方法类似，实际调用的也是下面的方法。
public void write(byte b\[\], int off, int len)|将 byte 数组从 off 位置开始，len 长度的字节写入
public void flush()|强制刷新，将缓冲中的数据写入
public void close()|关闭输出流，流被关闭后就不能再输出数据了

### Reader

方法|方法介绍
---|---
public int read(java.nio.CharBuffer target)|读取字节到字符缓存中
public int read()|读取单个字符
public int read(char cbuf\[\])|读取字符到指定的 char 数组中
abstract public int read(char cbuf\[\], int off, int len)|从 off 位置读取 len 长度的字符到 char 数组中
public long skip(long n)|返回可读的字节数量
public boolean ready()|和上面的 available() 方法类似
public boolean markSupported()|判断当前流是否支持标记流
public void mark(int readAheadLimit)|标记读取位置，下次还可以从这里开始读取，使用前要看当前流是否支持，可以使用 markSupport() 方法判断
public void reset()|重置读取位置为上次 mark 标记的位置
abstract public void close()|关闭流释放相关资源

### Writer 
方法|方法介绍
---|---
public void write(int c)|写入一个字符
public void write(char cbuf\[\])|写入一个字符数组
abstract public void write(char cbuf\[\], int off, int len)|从字符数组的 off 位置写入 len 数量的字符
public void write(String str)|写入一个字符串
public void write(String str, int off, int len)|从字符串的 off 位置写入 len 数量的字符
public Writer append(CharSequence csq)|追加写入一个字符序列
public Writer append(CharSequence csq, int start, int end)|追加写入一个字符序列的一部分，从 start 位置开始，end 位置结束
public Writer append(char c)|追加写入一个 16 位的字符
abstract public void flush()|强制刷新，将缓冲中的数据写入
abstract public void close()|关闭输出流，流被关闭后就不能再输出数据了


 

