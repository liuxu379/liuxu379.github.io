---
layout:     post
title:      Linux 下 MongoDB 环境配置
subtitle:   
date:       2019-12-28
author:     liuxu379
header-img: img/post-bg-2015.jpg
catalog: true
tags:
 - MongoDB
 - Linux
---




## 前言
面试的时候经常被问到 NoSQL 数据库，之前一直用的 Redis，虽然也有听说 MongoDB，但一直没用上，这次刚好有机会用到，所以记录一下这中间的学习和使用过程。

#### 文档

- [官方文档](https://docs.mongodb.com/)

#### 连接工具

- **[Studio 3T](https://robomongo.org/)**：收费，功能强大，美观
- [Robo 3T](https://robomongo.org/)：免费，功能一般

***

## 安装
因为用 Linux 比较多，所以这里只介绍一下 CentOS 和 Ubuntu 的安装过程。
#### CentOS
```
sudo touch /etc/yum.repos.d/mongodb-org-4.2.repo
vim /etc/yum.repos.d/mongodb-org-4.2.repo

#粘贴以下内容
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc

sudo yum install -y mongodb-org
```

如果需要卸载，可执行下面的命令
```
sudo service mongod stop
sudo yum erase $(sudo rpm -qa | grep mongodb-org)
sudo rm -r /var/log/mongodb
sudo rm -r /var/lib/mongo
```

***
#### Ubuntu
官方 MongoDB 仅支持 Ubuntu 16.04 和 18.04，且不支持 WSL(Windwos Linux)，不要搞错了。
这里我以 Ubuntu 18.04 系统来做示例，16.04 版本略有不同，可以参照[官方文档](https://docs.mongodb.com/)。
```
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org
```

如果需要卸载，可执行下面的命令
```
sudo service mongod stop
sudo apt-get purge mongodb-org*
sudo rm -r /var/log/mongodb
sudo rm -r /var/lib/mongodb
```

***
## 管理
启动：sudo service mongod start
状态：sudo service mongod status
停止：sudo service mongod stop
重启：sudo service mongod restart
连接：mongo