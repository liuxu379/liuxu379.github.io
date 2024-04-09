---
layout:     post
title:      VMware Workstation 与 Device/Credential Guard 不兼容
subtitle:   
date:       2019-06-12
author:     liuxu379
header-img: img/post-bg-2015.jpg
catalog: true
tags:
 - Windows
 - VMware
---

* 目录
  {:toc}

## 前言

9102年了，Windows 下使用虚拟机已经是个老生常谈的话题了，但还是出现了二者的兼容问题，开启虚拟机后直接导致系统绿屏，连错误提示都没有，不知道是 Windows 的问题还是 VMware 的问题。

还是建议大家**关闭 Windows 的自动更新功能**保平安。

***

#### 解决方案

以管理员身份运行 CMD 终端，执行以下命令：

`bcdedit /set hypervisorlaunchtype off`

重启电脑就可以了。

