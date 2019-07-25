# Elasticsearch

Elasticsearch 是一个分布式可扩展的实时搜索和分析引擎,
一个建立在全文搜索引擎 Apache Lucene(TM) 基础上的搜索引擎.

## 功能:

* 分布式实时文件存储,并将每一个字段都编入索引,使其可以被搜索.

* 实时分析的分布式搜索引擎.

* 可以扩展到上百台服务器,处理PB级别的结构化或非结构化数据.

## 基本概念:

先说Elasticsearch的文件存储,Elasticsearch是面向文档型数据库,一条数据在这里就是一个文档,用JSON作为文档序列化的格式,比如下面这条用户数据：
`Elasticsearch  ⇒ 索引(Index)   ⇒ 类型(type)  ⇒ 文档(Documents)  ⇒ 字段(Fields)  
`

## 索引

Elasticsearch 是通过 Lucene 的倒排索引技术实现比关系型数据库更快的过滤.
特别是它对多条件的过滤支持非常好,比如年龄在 18 和 30 之间,性别为女性这样的组合查询.

![](../../assets/img/ElasticsearchTermIndex.jpg)

* `Posting List`
    
    倒排索引是 per field 的,一个字段由一个自己的倒排索引.
    18,20 这些叫做 term,而 `[1,3]` 就是 posting list.
    Posting list 就是一个 int 的数组,存储了所有符合某个 term 的文档 id.

* `Term Dictionary`

    假设我们有很多个 term,比如：
    **Carla,Sara,Elin,Ada,Patty,Kate,Selena**
    如果按照这样的顺序排列,找出某个特定的 term 一定很慢,
    因为 term 没有排序,需要全部过滤一遍才能找出特定的 term.
    排序之后就变成了：
    **Ada,Carla,Elin,Kate,Patty,Sara,Selena**
    好处是可以采用二分法进行查询,这个就是`Term Dictionary`

* `Term Index`

    有了 Term Dictionary 之后,可以用 logN 次磁盘查找得到目标.
    但是磁盘的随机读操作仍然是非常昂贵的(一次`random access`大概需要`10ms`的时间)
    .所以尽量少的读磁盘,有必要把一些数据缓存到内存里.
    但是整个`Term Dictionary`本身又太大了,无法完整地放到内存里.
    于是就有了`Term Index`.
    `Term Index`有点像一本字典的大的章节表.
    实际的`Term Index`是一棵 `trie树`
    
![`FST`,`Finite State Transducers`,有穷状态转换器](../../assets/img/Elasticsearch_Trie.png) 

    这棵树不会包含所有的term,它包含的是term的一些前缀.通过term index可以快速地定位到term dictionary的某个offset,然后从这个位置再往后顺序查找.
    
* 压缩技巧
    针对Posting List进行压缩
    `增量编码压缩,将大数变小数,按字节存储`
    通过增量,将原来的大数变成小数仅存储增量值,
    再精打细算按bit排好队,
    最后通过字节存储,
    而不是大大咧咧的尽管是2也是用int(4个字节)来存储.
    
    **Roaring bitmaps**
    
    `bitmap`:用0/1标识是否存在,例如`[1,3,4,7,10]`=>`[1,0,1,1,0,0,1,0,0,1]`
    
    将posting list按照65535为界限分块,
    比如第一块所包含的文档id范围在0\~65535之间,
    第二块的id范围是65536\~131071,以此类推.
    再用<商,余数>的组合表示每一组id,这样每组里的id范围都在0\~65535内了,
    剩下的就好办了,既然每组id不会变得无限大,那么我们就可以通过最有效的方式对这里的id存储.
    如果是大块,用节省点用`bitset`存,小块就豪爽点,2个字节我也不计较了,用一个`short[]`存着方便.
    
    PS:*65535是一个经典值,因为它=2^16-1,正好是用2个字节能表示的最大数*
    
* 联合索引:
    * 利用跳表(`Skip list`)的数据结构快速做“与”运算
    * 利用上面提到的`bitset`按位“与”
    
    **跳表Skip list**
    
    跳表数据结构:

![](../../assets/img/Elasticsearch_skiplist.png)

将一个有序链表level0,挑出其中几个元素到level1及level2,
每个level越往上,选出来的指针元素越少,
查找时依次从高level往低查找,比如55,
先找到level2的31,再找到level1的47,最后找到55,
一共3次查找,查找效率和2叉树的效率相当,
但也是用了一定的空间冗余来换取的.

如果使用`bitset`,就很直观了,直接按位与,得到的结果就是最后的交集.

## Shard(分片)

一个Shard就是一个Lucene实例,是一个完整的搜索引擎.一个索引可以只包含一个Shard,只是一般情况下会用多个分片,可以拆分索引到不同的节点上,分担索引压力.



## Segment

* elasticsearch中的每个分片包含多个segment,
每一个segment都是一个倒排索引;
在查询的时,会把所有的segment查询结果汇总归并后
最为最终的分片查询结果返回; 
* 在创建索引的时候,elasticsearch会把文档信息写到内存buffer中(为了安全,也一起写到`translog`),
定时(可配置)把数据写到segment缓存小文件中,然后刷新查询,使刚写入的segment可查. 
虽然写入的segment可查询,但是还没有持久化到磁盘上.因此,还是会存在丢失的可能性的. 
* 所以,elasticsearch会执行flush操作,把segment持久化到磁盘上并清除`translog`的数据(因为这个时候,数据已经写到磁盘上,不在需要了). 
当索引数据不断增长时,对应的segment也会不断的增多,查询性能可能就会下降.
因此,Elasticsearch会触发segment合并的线程,把很多小的segment合并成更大的segment,然后删除小的segment. 
* segment是不可变的,当我们更新一个文档时,会把老的数据打上已删除的标记,
然后写一条新的文档.在执行flush操作的时候,才会把已删除的记录物理删除掉.



    
    
    


    

    
    
    
















