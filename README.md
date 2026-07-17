# Skills Dashboard

本地網頁 dashboard，可視化瀏覽 Claude Code 的所有 skills（自建＋plugin）。
唯讀——只負責「看」，建立與修改 skill 仍回 Claude Code 對話裡做。

## 功能現況

- **總覽頁**：檔案總管式 layout——左側來源樹（own／各 plugin，含數量）＋統計
  （技能總數、來源數、異常數、附加參考文件），右側高密度列表（預設）與索引卡片
  兩種視圖，一鍵切換並記憶偏好（localStorage）。
- **搜尋與過濾**：client-side 即時過濾（名稱／用途／關鍵字，中英文皆可），
  `/` 快捷鍵聚焦搜尋框；來源樹點選過濾，與搜尋 AND 疊加。
- **詳情**：點列／卡片開 modal 渲染完整 SKILL.md（kramdown），modal 內可跳獨立
  詳情頁 `/skills/:source/:name`。
- **中文說明**：sidecar 翻譯檔 `data/zh.yml`（不動 plugin 原檔），每個 skill
  一句中文用途，列表／卡片／詳情頁共用；無譯文 fallback 英文。
- **來源連結**：plugin skill 的詳情頁顯示原始碼連結——優先讀 plugin 的
  `plugin.json`（`repository`／`homepage`），缺了 fallback 到 marketplace 的
  `marketplace.json`。
- **容錯**：frontmatter 壞掉的 skill 標記異常照常列出；任何 metadata 解析失敗
  都不讓頁面 crash。

## 啟動

需求：Ruby 3.4.7（rbenv，`.ruby-version` 已釘版）。

```bash
bundle install
bin/dashboard        # → http://127.0.0.1:4567
```

預設掃描 `~/.claude/skills`（自建）與 `~/.claude/plugins/cache`（plugin，
多版本自動取最新）。路徑可用環境變數覆寫：`SKILLS_DIR`、`PLUGINS_DIR`、
`MARKETPLACES_DIR`、`ZH_FILE`。

每次 request 現場讀檔案系統，無 DB、無 cache——skill 有變動重整頁面即生效；
但改到 `app.rb`／`lib/` 程式碼需重啟 server（不熱 reload）。

## 開發

```bash
bin/check                  # rubocop + bundler-audit + rspec（merge 前第一關）
bundle exec rspec          # 只跑測試
bundle exec rubocop -a     # lint + autocorrect
```

新 skill 的中文說明：在 `data/zh.yml` 對應 source 底下加一行
`skill名: 一句中文用途。`，沒加就顯示英文 description。

## 文件

- 設計與 roadmap：`docs/specs/2026-07-16-skills-dashboard-design.md`
- 各 issue 實作計畫：`docs/plans/`
