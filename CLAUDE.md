# Project: skills-dashboard

本地 Sinatra 唯讀 dashboard，可視化瀏覽 Claude Code skills（自建＋plugin）。
規格與 roadmap：`docs/specs/2026-07-16-skills-dashboard-design.md`；各 issue 計畫在 `docs/plans/`。

## Stack
- Ruby 3.4.7（rbenv，`.ruby-version` 釘版）、Sinatra 4.2＋erubi（escape_html 全域開）、無 DB
- 測試：RSpec ＋ rack-test；Lint：RuboCop（`NewCops: enable`）
- lib 三個 plain-Ruby class：`Skill`（單一 skill＋frontmatter 解析）、
  `SkillScanner`（掃描兩來源、plugin 多版本去重、`#plugin_links` 來源連結）、
  `ZhDict`（sidecar 中文說明 `data/zh.yml`）

## Commands
- 檢查總入口：`bin/check`（rubocop＋bundler-audit＋rspec；merge 第一關）
- 測試：`bundle exec rspec`；單檔：`bundle exec rspec <path>:<line>`
- Lint：`bundle exec rubocop -a`
- Dev：`bin/dashboard`（啟動 127.0.0.1:4567）
- Ruby 一律經 rbenv：指令前綴 `RBENV_VERSION=3.4.7`（system ruby 是 2.6，會炸）

## 慣例
- lib class 是 plain Ruby、不碰 HTTP，可獨立測試；route 只組裝與渲染
- 路徑一律可注入：ENV `SKILLS_DIR`／`PLUGINS_DIR`／`MARKETPLACES_DIR`／`ZH_FILE`；
  測試用 `spec/fixtures/` 假目錄樹，不碰真實 `~/.claude`
- 錯誤哲學：frontmatter 壞掉的 skill 標 error 照常列出；plugin.json／marketplace.json／
  zh.yml 任何解析失敗都降級（沒連結／沒翻譯），不得讓頁面 crash、不得 raise
- escape 態勢：skill 與翻譯文字一律 `<%=`；raw `<%==` 僅 layout 的 `yield` 與
  show 頁的 `@html`（kramdown 輸出）兩處，不得新增
- 樣式只用 `public/style.css` `:root` 的 9 個 token，`:root` 外不出現 hex 色碼
- 新 skill 中文說明：`data/zh.yml` 對應 source 底下加 `skill名: 一句中文用途。`

## 坑
- `bin/dashboard` 不熱 reload `app.rb`／`lib/`（ERB template 會）——改後端要重啟
  server，否則舊 code＋新 template 可能 500
- Sinatra route param 含 `/`（即使 percent-encoded）會先被切成路徑段再匹配 → 404
- rack-test 需 `RACK_ENV=test`（spec_helper 已設）繞過 HostAuthorization

## 邊界
- 唯讀：不寫入任何 `~/.claude` 底下的檔案（roadmap #8 使用追蹤動工前需另行拍板）
- 不加 gem（先問）；secrets 不進 repo
- 一個 roadmap issue 一條 branch（feature/NN-*），不自 merge
- merge 走 GitHub PR（2026-07-17 起）：branch 推 origin → 開 PR →
  使用者在 GitHub review＋merge；remote 為 github.com/jfchen19/skills-dashboard
