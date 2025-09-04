[简体中文](README.md)|繁體中文

# DoroHelperLegacy - NIKKE PC 端日常任務助手

**免責聲明：** 本專案僅供個人學習研究使用，嚴禁用於商業用途。使用任何腳本程序均有封號風險，請謹慎。

**介紹：**

DoroHelperLegacy 是一個 NIKKE (勝利女神：妮姬) PC 端的日常任務自動化助手。
它支援國際服和港澳台服客戶端，並延續 DoroHelper v0.1.22 的功能，支援視窗模式。

![預覽圖片](https://github.com/kevinboy666/DoroHelperLegacy/blob/master/img/preview.png)

**警告：** 使用任何腳本程式都存在封號的風險。請務必謹慎使用，並理解潛在的風險。

**重要提示：**

*   此程式是根據開發者自身的帳號進度編寫的，可能與其他玩家的帳號不完全相容。
*   第一次使用時，請務必在旁邊觀察程式的運行情況，以確保一切正常。
*   如果 DoroHelper 失控，請立即按下 `Ctrl + Z` 組合鍵來結束程式。

**下載：**

你可以在右側的 [Releases](https://github.com/kevinboy666/DoroHelperLegacy/releases) 頁面下載已編譯好的 `.exe` 檔案。

**進階用法：**

如果你不信任編譯好的檔案，或者想要修改程式碼以適應自己的情況，你可以：

1.  下載程式碼。
2.  安裝 [AutoHotkey V2.0](https://www.autohotkey.com/)。
3.  以**管理員模式**運行 `DoroHelperLegacy.ahk`。
4.  (可選) 使用任何文字編輯器打開 `DoroHelperLegacy.ahk`，修改程式碼以適配自己的情況。
5.  (可選) 使用 [Ahk2Exe](https://www.autohotkey.com/docs/v2/Converter.htm) 將 `DoroHelperLegacy.ahk` 編譯成 `.exe` 執行檔。

**功能介紹：**

DoroHelper 旨在減輕玩家在 NIKKE 日常任務中重複勞動和長時間讀取條的負擔。它可以一鍵清理多項日常事務 (按順序執行)：

*   **前哨基地防禦：** 執行 1 次一舉殲滅，並收取 2 次收菜。
*   **付費商店：** 領取每日、每週、每月免費鑽石。
*   **免費商店：**
    *   每日在普通商店白嫖 2 次免費刷新。
    *   在競技場商店購買自定義數量的屬性技能書。
    *   購買公司武器熔爐。
*   **派遣遠征和收菜**
*   **收取和贈送好友點數**
*   **模擬室 5C 通關**
*   **新人競技場：** 進行自定義數量的戰鬥，並收取 pjjc 囤積超過 50% 的菜。
*   **好感度諮詢：** 進行自定義次數的好感度諮詢，支援補充諮詢圖鑑。
*   **光速爬塔失敗：** 進行 1 次爬塔並快速放棄，以獲得每日任務點數。
*   **爬企業塔**
*   **自動異常攔截戰**
*   **郵箱收取**
*   **每日任務收取**
*   **通行證收取**

**使用說明：**

對於大多數老玩家來說，DoroHelper 的設定保持默認即可。

**重要：** 如果 DoroHelper 失控，請立即按下 `Ctrl + Z` 組合鍵來結束程式。

**系統需求：**

*   **顯示設定：**
    *   【設定 - 畫質 - 全螢幕模式 + 16:9 的顯示器比例】（推薦）
    *   或 【16:9 的視窗模式】（窗口儘量拉大，否則像素識別可能出現誤差）
*   **遊戲設定：**
    *   設定 - 畫質 - 開啟光暈效果
    *   設定 - 畫質 - 開啟顏色分級
    *   遊戲語言設定為簡體中文
*   **執行權限：** 以**管理員身份**運行 DoroHelper。
*   **其他：** 請勿開啟 Windows HDR 顯示。

**使用步驟：**

1.  打開 NIKKE 啟動器。
2.  點擊「啟動」。
3.  等待右下角騰訊 ACE 反作弊系統掃描完畢，NIKKE 主程式中央 SHIFT UP logo 出現後，再切換出來點擊 DoroHelper 的「DORO!」按鈕。
4.  如果看到滑鼠開始在左下角連點，表示啟動成功。
5.  等待 DoroHelper 完成任務。

**提示：** 你也可以在遊戲處於大廳介面時（有看板娘的頁面）切換出來點擊「DORO!」按鈕啟動程式。

**重要：** 請在遊戲更新完成後再使用 DoroHelper。

**疑難排解：**

*   **死循環：** 如果出現死循環，請提高點擊間隔。
*   **效能：** 如果您的電腦配置較好，可以嘗試降低點擊間隔。
*   **參考設定：** 推薦的設定如下：

    ![設定 1](https://github.com/kyokakawaii/DoroHelper/blob/67486160e97713900c43cc2c68e176dd65e1f442/img/setting1.png)
    ![設定 2](https://github.com/kyokakawaii/DoroHelper/blob/67486160e97713900c43cc2c68e176dd65e1f442/img/setting2.png)

**鳴謝：**

*   [Github.ahk-API-for-AHKv2](https://github.com/samfisherirl/Github.ahk-API-for-AHKv2)
