---
layout:     post
title:      简单的编码及接口规范
subtitle:   
date:       2020-05-14
author:     liuxu379
header-img: img/post-bg-2015.jpg
catalog: true
tags:
 - PHP
---




## 编码规范

- 遵循 **PSR-2**;







## 注释规范

- 接口用途
- 作者、日期
- 参数+参数说明







## RESTful API 规范

#### 请求方式

- GET(SELECT)：获取数据；
- POST(CREATE)：新增数据；
- PUT(UPDATE)：更新数据；
- DELETE(DELETE)：删除数据；

> 当移动端使用 **GET** 方式请求数据时，需要求移动端传递参数 **sortby(排序字段)** 和 **orderby(顺序)**;



#### 状态码

- 200 OK - [GET]：服务器成功返回用户请求的数据；
- 201 CREATED - [POST/PUT]：用户新建或修改数据成功；
- 204 NO CONTENT - [DELETE]：用户删除数据成功；
- 400 INVALID REQUEST - [POST/PUT]：用户发出的请求有错误，服务器没有进行新建或修改数据的操作；
- 401 Unauthorized - [*]：表示用户没有权限（令牌、用户名、密码错误）；
- 410 Gone -[GET]：用户请求的资源被删除；
- 422 Unprocesable entity - [POST/PUT/PATCH] 当创建一个对象时，发生一个验证错误；
- 500 INTERNAL SERVER ERROR - [*]：服务器发生错误，用户将无法判断发出的请求是否成功；