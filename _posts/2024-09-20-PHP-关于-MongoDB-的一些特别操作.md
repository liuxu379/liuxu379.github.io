---
layout:     post
title:      PHP 关于 MongoDB 的一些特别操作
subtitle:   
date:       2024-09-20
author:     liuxu379
header-img: img/post-bg-2015.jpg
catalog: true
tags:
 - Code
---

* 目录
  {:toc}

最近在做风控相关的工作，中间涉及到宽表需求，单表字段可能会有两三千字段，通过对运维、上手难度等方面考量，最终选择了 mongoDB，实际使用效果还不错，但是因为和 MySQL 还是有一定差异，所以记录一下相关操作。



## 删除某些字符串开头的字段

```php
$documents = PuDao::query()->where()->get();

foreach ($documents as $doc) {
    $unsetFields = [];

    // 遍历文档，找到以 `xxxx` 开头的字段
    foreach ($doc->toArray() as $key => $value) {
        if (str_starts_with($key, 'xxxx')) {
            $unsetFields[$key] = 1; // 构建 unset 的字段列表
        }
    }

    // 如果找到了字段，则执行 $unset 删除
    if (!empty($unsetFields)) {
        PuDao::where('_id', $doc->_id)
            ->update(['$unset' => $unsetFields]); // 使用 MongoDB 的 $unset 操作符
    }
}
```





