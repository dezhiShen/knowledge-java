# 安装Zookeeper

* 从官网下载指定版本
* 解压到指定目录`tar -zxvf zookeeper.{version}.tar.gz`

* 增加环境变量
    * 修改/etc/profile`vim /etc/profile`
    * 增加ZOOKEEPER_HOME `export ZOOKEEPER_HOME={安装根目录}`
    * 增加PATH `export PATH=$PATH:$ZOOKEEPER_HOME/bin`
    * 更新环境变量`source /etc/profile`

* 配置文件
    * 目录 `{安装根目录}/conf/zoo.cfg`,没有则使用`zoo_sample.cfg`进行复制创建`cp zoo_sample.cfg zoo.cfg`
    * 详细说明 见 [配置文件](config.md)
    
* 启动
    * 如无特殊说明,以下命令均在`安装根目录`,`root用户`下执行
    * 启动服务
        * `bin/zkServer.sh start`
    * 启动CLI
        * `bin/zkCli.sh`
        * 依赖`zip,unzip`
     