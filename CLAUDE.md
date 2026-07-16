# Project: skills-dashboard

本地 Sinatra 唯讀 dashboard，可視化瀏覽 Claude Code skills（自建＋plugin）。
規格與 roadmap：`docs/specs/2026-07-16-skills-dashboard-design.md`。

## Stack
- Ruby 3.4.7（rbenv，`.ruby-version` 釘版）、Sinatra 4.2、ERB views、無 DB
- 測試：RSpec ＋ rack-test；Lint：RuboCop

## Commands
- 檢查總入口：`bin/check`（rubocop＋bundler-audit＋rspec；merge 第一關）
- 測試：`bundle exec rspec`；單檔：`bundle exec rspec <path>:<line>`
- Lint：`bundle exec rubocop -a`
- Dev：`bin/dashboard`（啟動 localhost:4567）

## 慣例
- lib class 是 plain Ruby、不碰 HTTP，可獨立測試；route 只組裝與渲染（見 `lib/skill_scanner.rb`）
- 掃描路徑一律可由建構參數注入，測試用 `spec/fixtures/` 假目錄樹，不碰真實 `~/.claude`
- frontmatter 壞掉的 skill 標 error 照常列出，任何解析失敗不得讓頁面 crash

## 邊界
- v1 唯讀：不寫入任何 `~/.claude` 底下的檔案
- 不加 gem（先問）；secrets 不進 repo
- 一個 roadmap issue 一條 branch（feature/NN-*），不自 merge
