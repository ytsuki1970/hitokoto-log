# ひとことログ

1行つぶやくだけで、自動で分類して数字を拾い、統計とSNS下書きにするアプリ。
作成：2026年9月6日／第1段（MVP）

**公開URL：https://hitokoto-log.pages.dev/**
（Cloudflare Pages。公開しているのはアプリのファイルだけで、**記録の中身は端末内から出ない**）

```
つぶやく（1行）
   ↓ 辞書で即時分類・数字の抜き出し・日付の読み取り
カテゴリ ＋ タグ ＋ 数値（30分／5km／30ページ）で保存
   ↓
草・連続日数・カテゴリ内訳・つみあげ
   ↓
SNS下書き →【自分の手で投稿】
```

---

## 使いかた

`index.html` をブラウザで開くだけ。スマホはホーム画面に追加して使う（PWA）。

### 入力の書きかた

| 書くと | こうなる |
|---|---|
| `朝ラン5km 30分` | 運動／km 5・分 30 |
| `昨日 提案書を仕上げた` | 前日の記録として保存 |
| `3日前 ジムで筋トレ 45分` | 3日前の記録 |
| `9/1 英単語 20分` | 9月1日の記録 |
| `#継続` | タグとして保存（検索できる） |
| `運動: ヨガ` | 辞書を無視してカテゴリを指定 |

拾う数値：**分・時間・km・ページ・冊・社/件/軒・回/セット・kg**

### 記録を直す

一覧の行をタップすると編集シートが開く。カテゴリを直すと「おぼえることば」欄に候補が入り、
保存すると**その語が辞書に追加される**（次から自動で当たるようになる）。

---

## カテゴリ

運動 / 読書 / 学習 / 交流 / 仕事 / 生活 / 未分類 の7つ。
分類は **端末内のキーワード辞書** で行う。通信ゼロ・オフラインでも動く。
辞書は「設定 → 分類のことば」で自由に足せる。

判定ルール：**いちばん長く一致したことばのカテゴリが勝つ**。
同じ長さなら `CATS` の並び順（運動→読書→学習→交流→仕事→生活）が先勝ち。

---

## 公開／非公開

本文に次のいずれかが入っていると、**自動で「非公開」**になる。

```
株式会社 / 有限会社 / (有) / (株) / 様 / 円 / ¥ / 万 / 見積 / 請求
```

非公開の行は SNS下書きに出ない（チェックを入れれば出せる）。
得意先名や金額をうっかり投稿しないための保険。**投稿前に必ず自分の目で読むこと。**

---

## SNS下書き

「まとめ」タブで 今日／昨日／この7日／今月 × 箇条書き／数字だけ を選んで生成する。
生成物は**下書きまで**。投稿はしない、できない。

生成文と手直し後の文は「ことばを点検」で `tsuki-voice` の禁止ルールに照らす：

- 「〜ですよ」「〜ですよね」「〜なんです」
- 「是非」「ぜひ」「お気軽に」
- 「最高品質」「業界最安」
- 「皆様」「各位」／冒頭の挨拶
- 絵文字3個以上／同じ語尾の3連続／140字超え

ルールを増やしたら `index.html` の `const NG = [...]` に足す。
**正値は `tsuki-voice` スキル。**片方だけ直さないこと。

---

## データ

- 保存先：**端末内の IndexedDB のみ**（DB名 `hitokoto-log`）。外には一切出ない
- ストア：`entries`（記録）／`settings`（辞書・クイックボタン・テーマ）
- 書き出し：JSON（丸ごと復元用）／CSV（Excel用・BOM付き）
- 読み込み：JSON。**同じidは飛ばして追加**するので、二重取り込みにならない

> 機種変・ブラウザのデータ削除で消える。**月に一度はJSONで書き出す。**

### 1件のかたち

```json
{
  "id": "e...", "ts": 1757000000000, "date": "2026-09-06",
  "text": "朝ラン5km 30分", "cat": "exercise", "tags": [],
  "nums": { "min": 30, "km": 5 },
  "mood": 0, "pub": true, "created": 0, "updated": 0
}
```

---

## ファイル構成

```
hitokoto-log/
├─ public/            ← これがデプロイされる
│   ├─ index.html     ← 本体（これ1つで動く）
│   ├─ manifest.json  ← PWA
│   ├─ sw.js          ← オフライン用。https か localhost でのみ登録される
│   └─ icon-192.png / icon-512.png / apple-touch-icon.png
├─ wrangler.jsonc     ← Cloudflare Pages の設定
├─ package.json       ← npm run deploy / npm run dev
├─ start.bat          ← ローカルサーバで開く（http://localhost:8932）
└─ README.md
```

`public/index.html` を `file://` で直接開いても動くが、**Service Worker は登録されない**
（オフライン化とホーム画面追加は `start.bat` か公開URL経由で）。

---

## スマホで使うには

**公開URL：https://hitokoto-log.pages.dev/**

1. スマホでこのURLを開く
2. 共有メニューから「ホーム画面に追加」
3. 以後はアイコンから起動。オフラインでも動く（Service Worker）

> 公開されているのは**アプリのファイルだけ**。記録の中身は開いた端末の中に残り、
> Cloudflare にもGitHubにも送られない。URLを他人が開いても、その人の空のアプリが立ち上がるだけ。

---

## デプロイ（Cloudflare Pages）

```bash
cd C:\Users\ytsuk\dev\hitokoto-log
npm run deploy        # = npx wrangler pages deploy
```

10〜20秒で反映される。**GitHubへのpushでは反映されない**（Git連携はしていない）。
ソースの控えとして push もしておくこと。

```bash
git add -A && git commit -m "変更の説明" && git push
```

- プロジェクト名：`hitokoto-log`（Cloudflare アカウント ytsuki1970@otouki.biz）
- 設定：`wrangler.jsonc`（`pages_build_output_dir: "public"`）
- デプロイされるのは **`public/` の中だけ**。README・start.bat・wrangler.jsonc は上がらない
- 履歴：`npx wrangler pages deployment list --project-name hitokoto-log`

> **GitHub Pages は停止済み**（2026-09-06）。二重に公開すると、URLごとに記録が別々に貯まって
> 混乱するため。戻すなら `gh api -X POST repos/ytsuki1970/hitokoto-log/pages -f "source[branch]=main" -f "source[path]=/"`

### PCだけで使いたいとき

`start.bat` をダブルクリック → `http://localhost:8932/`（`public/` を配信する）。
`npm run dev` でも動く（`wrangler pages dev`。将来 `functions/` を足したらこちらを使う）。

> **注意**：`localhost` と `hitokoto-log.pages.dev` は**別のオリジン扱い**なので、記録は共有されない。
> 片方で貯めた記録をもう片方へ移すには、JSONで書き出して読み込む。

---

## これから足すもの（第2段以降）

- 端末間の同期（まなびログと同じ Cloudflare Pages Functions ＋ D1 ＋ Access 方式）
  → `functions/api/sync.js` を作り、`wrangler.jsonc` のコメント欄の d1 設定を有効にする。
  まなびログ `dev\manabi-log\functions\api\sync.js` と `sync-schema.sql` がそのまま参考になる
- 独自ドメイン（例 `log.otouki.biz`）。**当てるならデータを貯める前に**（オリジンが変わると記録が引き継がれない）
- 夜のリマインド通知
- 「去年の今日」／年末の1年ふりかえり生成
- Claude による夜間の再分類（辞書で外したものを直す）
- 記憶ノート・Googleカレンダーとの突き合わせ

---

## 申し送り

- **分類の精度より、入力の速さが先。** 続かなければ統計もSNSも中身が空になる
- 迷ったものは「未分類」に落ちる。あとでまとめて直せば辞書が育つ
- 数字は本文から拾っているだけで、**推計は一切していない**。統計に出るのは打ち込んだ実測値のみ
