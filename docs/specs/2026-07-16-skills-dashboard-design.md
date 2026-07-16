# Skills Dashboard — 設計文件

日期：2026-07-16
狀態：已定案（roadmap 順序由使用者拍板：#1 → #9）

## 目標

一個本地網頁 dashboard，可視化瀏覽 Claude Code 的所有 skills（自建＋plugin）。
v1 唯讀：只負責「看」，建立/修改 skill 仍回 Claude Code 對話裡做。

## 核心決策（已拍板）

| 決策 | 選擇 | 理由 |
| :--- | :--- | :--- |
| 載體 | 網頁 dashboard | 使用者指定 |
| 技術 | Sinatra（Ruby） | 使用者主場是 Ruby；無 DB 需求，Rails 太重；之後要加編輯只需加 route |
| 讀寫範圍 | v1 唯讀，之後慢慢擴充 | 架構最簡、避免網頁直接寫檔風險 |
| 專案位置 | `~/Documents/skills-dashboard`（獨立 repo） | 真 app（Gemfile、RSpec），不混進 vault |
| 視覺範本 | 深色卡片牆（使用者提供截圖） | 統計卡＋搜尋＋chips＋卡片 grid |
| 使用追蹤 | 推遲到 v1 之後（#5、#6） | v1 純掃描渲染，零基礎建設 |
| 健檢 | 推遲到 v1 之後（#7） | 使用者剛整理完 skills，暫無此痛點 |

## 架構

```
瀏覽器 → Sinatra (localhost:4567)
              │ 每次 request 現場讀檔案系統，無 DB、無 cache
              └─ SkillScanner
                   ├─ ~/.claude/skills/*/SKILL.md                      （自建）
                   └─ ~/.claude/plugins/cache/**/skills/*/SKILL.md     （plugin）
```

- `SkillScanner`：掃描兩個來源、parse YAML frontmatter、統計 SKILL.md 大小／
  附加檔案數（skill 資料夾內 SKILL.md 以外的檔案）／最後更新日期。
- lib class 都是 plain Ruby、不碰 HTTP，可獨立測試；Sinatra route 只組裝與渲染 ERB。
- frontmatter 壞掉的 skill 標記為異常、照常列出，不讓頁面 crash。

## 畫面（v1）

範本：使用者提供的深色主題卡片牆截圖。

### 總覽頁 `/`

- 四張統計卡：技能總數、來源數、平均 SKILL.md 大小、附加參考文件數
- 搜尋框：client-side JS 過濾名稱／description／關鍵字
- 來源 filter chips：自建、superpowers、code-review…（每來源一色）
- 卡片：skill 名稱、來源 badge、description 節錄（約三行）、footer（更新日期＋檔案大小）

### 詳情

- 點卡片 → modal 渲染完整 SKILL.md（markdown → HTML）
- modal 內連結 → 獨立詳情頁 `/skills/:source/:name`（frontmatter 原文、附加檔案列表）

## Roadmap（開發順序已定，每項一個 branch）

| # | 項目 | 內容 | 依賴 |
| :- | :--- | :--- | :--- |
| 1 | 專案骨架＋掃描核心 | Gemfile（sinatra、rspec）、`SkillScanner`、fixture 測試；純 lib 無畫面 | — |
| 2 | 總覽頁（卡片牆） | route＋ERB：統計卡、卡片牆、深色主題 | #1 |
| 3 | 搜尋＋來源 chips | client-side JS 過濾與篩選 | #2 |
| 4 | Skill 詳情 | modal 渲染 SKILL.md＋獨立詳情頁 | #2 |
| 5 | 使用追蹤基礎建設 | PostToolUse hook（matcher: Skill）寫 `~/.claude/logs/skill-usage.jsonl`＋`bin/backfill` 掃現存 transcript 回填（去重、可重跑） | — |
| 6 | 使用統計上畫面 | 卡片顯示使用次數／最後使用、「從沒用過」統計卡、詳情頁使用紀錄 | #5 |
| 7 | 健檢規則 | frontmatter 驗證、名稱不符、description 過弱、候選淘汰（依賴 #5）、疑似重複；卡片狀態燈號＋filter | #1（部分依賴 #5） |
| 8 | 自訂分類 | frontmatter `metadata` 加分類欄位，chips 改依分類分組 | #3 |
| 9 | 編輯類功能 | 範本中的拖曳排序、匯出設定檔等；範圍待細化 | 到時再定 |

## 測試與完成標準

- RSpec：lib class 用 fixture 目錄測（假 skills 樹）；route 用 rack-test 測。
- 每個 issue 完成標準：檢查指令全綠（rspec＋rubocop）、瀏覽器實際打開驗到畫面。
- Git：一個 issue 一個 branch；issue 內子任務縱切 commit；Conventional Commits 英文單行；不自 merge。

## 已標明的隱含決策

1. 使用 log 放 `~/.claude/logs/`（不放 vault）——機器產生的資料，避免弄髒 vault git 歷史。（#5 才用到）
2. hook 只記「哪個 skill、何時」，不記對話內容。（#5 才用到）
3. v1 卡片圖示用來源固定圖示——skills 沒有 emoji 資料，不硬湊。
