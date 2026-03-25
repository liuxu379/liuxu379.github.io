# liuxu379 Blog

基于 Jekyll 的个人博客，当前生产域名为 [hsbc.cc.cd](https://hsbc.cc.cd)。

## 本地开发

1. 安装 Ruby `3.1.6` 或更高版本，并安装 Bundler。
2. 安装依赖：

```bash
bundle install
```

3. 本地启动：

```bash
bundle exec jekyll serve --livereload
```

4. 构建静态产物：

```bash
bundle exec jekyll build
```

## 文章巡检

仓库内提供了一个轻量巡检脚本，用来扫描文章常见问题：

```bash
ruby scripts/audit_posts.rb
```

当前会检查：

- front matter 是否缺少常用字段
- 文件名与 front matter 日期是否不一致
- 文件名是否包含空格
- 是否使用了外链图片
- 是否存在空 alt 图片
- 是否混用了原始 HTML 图片标签

## 前端资源

如果需要重新生成主题 CSS / JS：

```bash
npm install
npm run assets
```

持续监听：

```bash
npm run assets:watch
```

## 发布

推送到 `main` 后，GitHub Actions 会自动构建并发布到 GitHub Pages。
