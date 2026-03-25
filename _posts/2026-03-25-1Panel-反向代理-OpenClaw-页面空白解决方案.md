---
layout:     post
title:      1Panel 反向代理 OpenClaw 页面空白的解决方案
subtitle:   
date:       2026-03-25
author:     liuxu379
header-img: img/post-bg-debug.png
catalog: true
tags:
 - 1Panel
 - OpenClaw
 - Nginx
 - Proxy
---




## 前言

这篇文章记录一下 **2026-03-25** 这个场景下，使用 **1Panel** 反向代理 **OpenClaw** 后打开域名只有白屏、页面空白的处理方法。

这类问题通常不是 OpenClaw 本身没有启动，而是下面两个点没有同时配好：

- **反向代理路径** 没有指向 OpenClaw 的 `__openclaw__/`；
- **跨域来源** 没有在 `allowedOrigins` 中放行你的反向代理域名。

> 请求链路可以简单理解为：
>
> `浏览器 -> 反向代理域名 -> 1Panel 网站代理 -> https://127.0.0.1:18789/__openclaw__/ -> OpenClaw`

![1Panel 网站代理配置界面]({{site.url}}/img/post-img-1panel-proxy-config.png?raw=true)

***

## 问题现象

常见表现一般是下面这几种：

- 域名可以正常打开，但页面是一片空白；
- 浏览器里没有正常渲染出 OpenClaw 控制台；
- 控制台里可能会看到静态资源加载异常、请求失败，或者跨域相关报错。

如果你确认 OpenClaw 服务本身是启动状态，那优先排查的就不是服务存活，而是 **Nginx 反代路径** 和 **OpenClaw 的来源放行配置**。

***

## 解决思路

这次修复的核心其实很简单，分成两步：

1. 把 1Panel 站点的根路径 `/` 正确代理到 `https://127.0.0.1:18789/__openclaw__/`；
2. 在 OpenClaw 配置文件的 `allowedOrigins` 里加入你的反向代理域名。

这两个条件缺一个，都有可能导致最终打开就是白屏。

***

## 第一步：替换 1Panel 站点的代理配置

直接替换文件：

`/www/sites/xxxx/proxy/root.conf`

其中 `xxxx` 改成你自己的站点目录名称。

替换后的内容如下：

```nginx
location ^~ / {
    proxy_pass https://127.0.0.1:18789/__openclaw__/;
    proxy_set_header Host 127.0.0.1;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-Port 443;
    proxy_http_version 1.1;
    proxy_read_timeout 300s;
    proxy_ssl_server_name on;
    proxy_ssl_verify off;
}
```

这里面最关键的是这一行：

```nginx
proxy_pass https://127.0.0.1:18789/__openclaw__/;
```

如果没有代理到 `__openclaw__/` 这个子路径，OpenClaw 前端资源路径就可能不对，最终表现出来就是页面空白。

另外这几项也建议保留：

- `Upgrade` 和 `Connection`：用于升级连接，避免实时通信异常；
- `X-Forwarded-Proto https`：明确告诉后端当前外部访问是 HTTPS；
- `proxy_ssl_verify off`：适合本地自签或内部 HTTPS 回源场景；
- `proxy_read_timeout 300s`：减少长连接或加载过程中的超时问题。

***

## 第二步：在 OpenClaw 中放行反向代理域名

继续编辑文件：

`/opt/1panel/apps/openclaw/OpenClaw/data/conf/openclaw.json`

找到 `allowedOrigins` 字段，在原有内容里加入你的反向代理域名。

例如你的反代域名是 `https://openclaw.example.com`，那么可以写成：

```json
"allowedOrigins": [
  "https://openclaw.example.com"
]
```

如果你原来已经有别的域名或本地地址，不要覆盖，直接在原数组里追加即可，例如：

```json
"allowedOrigins": [
  "http://127.0.0.1:18789",
  "http://localhost:18789",
  "https://openclaw.example.com"
]
```

这一步的作用是让 OpenClaw 明确允许你的反向代理域名访问它的资源和接口，否则就算 Nginx 代理通了，也可能因为来源校验不过而继续白屏。

***

## 第三步：重载配置并重启服务

配置改完之后，别忘了把相关服务重新加载一遍：

- 在 **1Panel** 中重载该网站的代理配置；
- 重启 **OpenClaw** 应用或容器；
- 浏览器强制刷新页面一次。

如果你是排查生产环境，建议顺手看一下浏览器的 **Network** 和 **Console**：

- JS / CSS 资源是否全部返回 `200`；
- 是否还存在跨域报错；
- WebSocket 或接口请求是否还有异常。

***

## 排查完成后的判断标准

当下面几项都正常时，基本就说明已经修好了：

- 访问域名后页面不再白屏；
- OpenClaw 前端界面可以正常渲染；
- 浏览器控制台没有明显的静态资源 404 或跨域报错；
- 刷新页面后依然可以稳定访问。

***

## 总结

**1Panel 反向代理 OpenClaw 页面空白**，本质上通常就是两个配置没有配套完成：

- 代理路径要指向 `__openclaw__/`；
- `allowedOrigins` 要加入你的反向代理域名。

所以如果你后面再遇到类似问题，不要只盯着 Nginx，也一定要一起检查 OpenClaw 自身的来源放行配置。

如果修改后依然空白，建议继续优先检查这三项：

- `allowedOrigins` 里写的是不是完整域名，是否带了正确协议；
- 反代后的请求是不是确实打到了 `__openclaw__/`；
- 浏览器控制台里是否还有 `CORS`、静态资源路径、或 HTTPS 回源相关报错。
