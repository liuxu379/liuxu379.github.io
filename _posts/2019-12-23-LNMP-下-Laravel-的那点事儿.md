---
layout:     post
title:      LNMP 下 Laravel 的那点事儿
subtitle:   
date:       2019-12-23
author:     liuxu379
header-img: img/post-bg-2015.jpg
catalog: true
tags:
 - LNMP
 - Laravel
---
## 前言
最近在看 Laravel 框架，记录一下这其中遇到的一些问题。

## 安装
当使用 Composer 安装框架时，会报下面错误：
```
  [Symfony\Component\Process\Exception\RuntimeException]                                   
  The Process class relies on proc_open, which is not available on your PHP installation.
```
此时需要去 php.ini 文件内删除 proc_open 和 proc_get_status 两个函数：
```
disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server
```
***
之后会出现 Warning: require(): open_basedir 的错误，这里要修改一下 Nginx  下的 fastcgi.conf 文件：
```
// 将末尾的这行注释掉并重启 Nginx
#fastcgi_param PHP_ADMIN_VALUE "open_basedir=$document_root/:/tmp/:/proc/";
```
***
如果项目里面有 .user.ini 文件需要修改或删除，须事先执行：
```
chattr -i .user.ini
```