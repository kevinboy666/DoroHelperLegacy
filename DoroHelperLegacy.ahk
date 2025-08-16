#Requires AutoHotkey >=v2.0

#Include %A_ScriptDir%\lib\github.ahk
CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"

;操作间隔（单位：毫秒）
sleepTime := 1500
scrRatio := 1.0

;consts
stdScreenW := 3840
stdScreenH := 2160
waitTolerance := 50
colorTolerance := 15

currentVersion := "v0.1.0"
usr := "kevinboy666"
repo := "DoroHelperLegacy"

;utilities
IsSimilarColor(targetColor, color) {
    tr := Format("{:d}", "0x" . substr(targetColor, 3, 2))
    tg := Format("{:d}", "0x" . substr(targetColor, 5, 2))
    tb := Format("{:d}", "0x" . substr(targetColor, 7, 2))

    pr := Format("{:d}", "0x" . substr(color, 3, 2))
    pg := Format("{:d}", "0x" . substr(color, 5, 2))
    pb := Format("{:d}", "0x" . substr(color, 7, 2))

    ;MsgBox tr tg tb pr pg pb

    distance := sqrt((tr - pr) ** 2 + (tg - pg) ** 2 + (tb - pb) ** 2)

    if (distance < colorTolerance)
        return true

    return false
}

ClickOnCheckForUpdate(*) {
    latestObj := Github.latest(usr, repo)
    if currentVersion != latestObj.version {
        userResponse := MsgBox(
            "DoroHelper存在更新版本:`n"
            "`nVersion: " latestObj.version
            "`nNotes:`n"
            . latestObj.change_notes
            "`n`n是否下载?", , '36')

        if (userResponse = "Yes") {
            try {
                Github.Download(latestObj.downloadURLs[1], A_ScriptDir "\DoroDownload")
            }
            catch as err {
                MsgBox "下载失败，请检查网络。"
            }
            else {
                FileMove "DoroDownload.exe", "DoroHelper-" latestObj.version ".exe"
                MsgBox "已下载至当前目录。"
                ExitApp
            }
        }
    }
    else {
        MsgBox "当前Doro已是最新版本。"
    }
}
; 自動更新
CheckForUpdate() {
    latestObj := Github.latest(usr, repo)
    if currentVersion != latestObj.version {
        userResponse := MsgBox(
            "DoroHelper存在更新版本:`n"
            "`nVersion: " latestObj.version
            "`nNotes:`n"
            . latestObj.change_notes
            "`n`n是否下载?", , '36')

        if (userResponse = "Yes") {
            try {
                Github.Download(latestObj.downloadURLs[1], A_ScriptDir "\DoroDownload")
            }
            catch as err {
                MsgBox "下载失败，请检查网络。"
            }
            else {
                FileMove "DoroDownload.exe", "DoroHelper-" latestObj.version ".exe"
                MsgBox "已下载至当前目录。"
                ExitApp
            }
        }
    }
}

;functions
UserClick(sX, sY, k := scrRatio) {
    uX := Round(sX * k)
    uY := Round(sY * k)
    Send "{Click " uX " " uY "}"
}

;檢查使用者
UserCheckColor(sX, sY, sC, k := scrRatio) {
    loop sX.Length {
        uX := Round(sX[A_Index] * k)
        uY := Round(sY[A_Index] * k)
        uC := PixelGetColor(uX, uY)
        if (!IsSimilarColor(uC, sC[A_Index]))
            return 0
    }
    return 1
}

isAutoOff(sX, sY, k) {
    uX := Round(sX * k)
    uY := Round(sY * k)
    uC := PixelGetColor(uX, uY)

    r := Format("{:d}", "0x" . substr(uC, 3, 2))
    g := Format("{:d}", "0x" . substr(uC, 5, 2))
    b := Format("{:d}", "0x" . substr(uC, 7, 2))

    if Abs(r - g) < 10 && Abs(r - b) < 10 && Abs(g - b) < 10
        return true
    return false
}

autoBurstOn := false
autoAimOn := false

CheckAutoBattle() {
    global autoBurstOn
    global autoAimOn

    if !autoAimOn && UserCheckColor([216], [160], ["0xFFFFFF"]) {
        if isAutoOff(60, 57, scrRatio) {
            UserClick(60, 71)
            Sleep sleepTime
        }
        autoAimOn := true
    }

    if !autoBurstOn && UserCheckColor([216], [160], ["0xFFFFFF"]) {
        if isAutoOff(202, 66, scrRatio) {
            Send "{Tab}"
            Sleep sleepTime
        }
        autoBurstOn := true
    }
}

Login() {
    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime

        if UserCheckColor([1973, 1969], [1368, 1432], ["0x00ADFB", "0x00ADFB"]) {
            UserClick(2127, 1400)
            Sleep sleepTime
        }

        if UserCheckColor([1965, 1871], [1321, 1317], ["0x00A0EB", "0xF7F7F7"]) {
            UserClick(2191, 1350)
            Sleep sleepTime
        }

        if UserCheckColor([1720, 2111], [1539, 1598], ["0x00AEFF", "0x00AEFF"]) {
            UserClick(1905, 1568)
            Sleep sleepTime
        }

        if A_Index > waitTolerance {
            MsgBox "登录失败！"
            ExitApp
        }
    }
}

BackToHall() {
    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            ExitApp
        }
    }
}

;=============================================================
;1: 防御前哨基地奖励
OutpostDefence() {
Start:
    targetX := 1092
    targetY := 1795
    UserClick(targetX, targetY)
    Sleep sleepTime

    ;standard checkpoint
    checkX := [1500, 1847]
    checkY := [1816, 1858]
    desiredColor := ["0xF8FCFD", "0xF7FCFD"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入防御前哨失败！"
            ExitApp
        }

        if A_Index > 10 {
            BackToHall()
            goto Start
        }
    }

    ;一举歼灭
    targetX := 1686
    targetY := 1846
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1500, 1847]
    checkY := [1816, 1858]
    desiredColor := ["0xF8FCFD", "0xF7FCFD"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入一举歼灭失败！"
            ExitApp
        }

        if A_Index > 10 {
            BackToHall()
            goto Start
        }
    }

    ;如有免费次数则扫荡，否则跳过
    checkX := [1933]
    checkY := [1648]
    desiredColor := ["0xE9ECF0"]

    if !UserCheckColor(checkX, checkY, desiredColor) {
        targetX := 2093
        targetY := 1651
        UserClick(targetX, targetY)
        Sleep sleepTime
        ;UserClick(targetX, targetY)
        ;Sleep sleepTime

        checkX := [1933]
        checkY := [1648]
        desiredColor := ["0x11ADF5"]

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime

            if UserCheckColor([2088], [1327], ["0x00A0EB"]) {
                UserClick(2202, 1342)
            }

            if A_Index > 10 {
                BackToHall()
                goto Start
            }
        }

        ;如果升级，把框点掉
        checkX := [2356]
        checkY := [1870]
        desiredColor := ["0x0EAFF4"]
        targetX := 2156
        targetY := 1846

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime

            if UserCheckColor([2088], [1327], ["0x00A0EB"]) {
                UserClick(2202, 1342)
            }

            if A_Index > 10 {
                BackToHall()
                goto Start
            }
        }
    }
    else {
        checkX := [2356]
        checkY := [1870]
        desiredColor := ["0x0EAFF4"]
        targetX := 2156
        targetY := 1846

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime

            if UserCheckColor([2088], [1327], ["0x00A0EB"]) {
                UserClick(2202, 1342)
            }

            if A_Index > 10 {
                BackToHall()
                goto Start
            }
        }
    }

    ;获得奖励
    targetX := 2156
    targetY := 1846
    UserClick(targetX, targetY)
    Sleep sleepTime
    ;UserClick(targetX, targetY)
    ;Sleep sleepTime // 2
    ;多点一下，以防升级
    ;UserClick(targetX, targetY)
    ;Sleep sleepTime // 2

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if UserCheckColor([2088], [1327], ["0x00A0EB"]) {
            UserClick(2202, 1342)
        }
        if A_Index > waitTolerance {
            MsgBox "前哨基地防御异常！"
            ExitApp
        }
        if A_Index > 10 {
            BackToHall()
            goto Start
        }
    }
}

;=============================================================
;2: 付费商店每日每周免费钻
CashShop() {
    ;进入商店
    targetX := 1163
    targetY := 1354
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [158, 199]
    checkY := [525, 439]
    desiredColor := ["0x0DC2F4", "0x3B3E41"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        if UserCheckColor([2047], [1677], ["0x00A0EB"]) or UserCheckColor([2047], [1677], ["0x9A9B9A"],
        scrRatio) {
            UserClick(1789, 1387)
            Sleep sleepTime
            UserClick(1789, 1387)
            Sleep sleepTime
            UserClick(2144, 1656)
            Sleep sleepTime
            while UserCheckColor([2047], [1677], ["0x00A0EB"]) {
                UserClick(2144, 1656)
                Sleep sleepTime
            }
            break
        }

        UserClick(targetX, targetY)
        Sleep sleepTime
        if UserCheckColor([2088], [1327], ["0x00A0EB"]) {
            UserClick(2202, 1342)
        }
        if A_Index > waitTolerance {
            MsgBox "进入付费商店失败！"
            ExitApp
        }
    }

    Sleep sleepTime
    if UserCheckColor([2047], [1677], ["0x00A0EB"]) or UserCheckColor([2047], [1677], ["0x9A9B9A"]) {
        UserClick(1789, 1387)
        Sleep sleepTime
        UserClick(1789, 1387)
        Sleep sleepTime
        UserClick(2144, 1656)
        Sleep sleepTime
        while UserCheckColor([2047], [1677], ["0x00A0EB"]) {
            UserClick(2144, 1656)
            Sleep sleepTime
        }
    }

    delta := false

    checkX := [52]
    checkY := [464]
    desiredColor := ["0xF7FCFD"]

    if UserCheckColor(checkX, checkY, desiredColor)
        delta := true

    targetX := 256
    if delta
        targetX := 432
    targetY := 486
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [194]
    if delta
        checkX := [373]
    checkY := [436]
    desiredColor := ["0x0FC7F5"]
    if delta
        desiredColor := ["0x0BC7F4"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入礼包页面失败！"
            ExitApp
        }
    }

    checkX := [514]
    checkY := [1018]
    desiredColor := ["0xF2F8FC"]

    if UserCheckColor(checkX, checkY, desiredColor) {
        targetX := targetX - 172
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
    }

    del := 336

    checkX := [1311]
    checkY := [612]
    desiredColor := ["0xA0A0AC"]

    if UserCheckColor(checkX, checkY, desiredColor)
        del := 0

    ;每日
    targetX := 545 - del
    targetY := 610
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [431 - del]
    checkY := [594]
    desiredColor := ["0x0EC7F5"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入每日礼包页面失败！"
            ExitApp
        }
    }

    targetX := 212
    targetY := 1095
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2

    ;每周
    targetX := 878 - del
    targetY := 612
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [769 - del]
    checkY := [600]
    desiredColor := ["0x0CC8F4"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入每周礼包页面失败！"
            ExitApp
        }
    }

    targetX := 212
    targetY := 1095
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2

    ;每月
    targetX := 1211 - del
    targetY := 612
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1114 - del]
    checkY := [600]
    desiredColor := ["0x0CC8F4"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入每月礼包页面失败！"
            ExitApp
        }
    }

    targetX := 212
    targetY := 1095
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2

    ;回到大厅
    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "退出付费商店失败！"
            ExitApp
        }
    }
}

;=============================================================
;3: 免费商店
BuyThisBook(coor, k) {
    uX := Round(coor[1] * k)
    uY := Round(coor[2] * k)

    uC := PixelGetColor(uX, uY)

    R := Format("{:d}", "0x" . substr(uC, 3, 2))
    G := Format("{:d}", "0x" . substr(uC, 5, 2))
    B := Format("{:d}", "0x" . substr(uC, 7, 2))

    if B > G and B > R {
        return isCheckedBook[2]
    }

    if G > R and G > B {
        return isCheckedBook[3]
    }

    if R > G and G > B and G > Format("{:d}", "0x50") {
        return isCheckedBook[5]
    }

    if R > B and B > G and B > Format("{:d}", "0x50") {
        return isCheckedBook[4]
    }

    return isCheckedBook[1]
}

FreeShop(numOfBook) {
    ;进入商店
    targetX := 1193
    targetY := 1487
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [118]
    checkY := [908]
    desiredColor := ["0xF99217"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入普通商店失败！"
            ExitApp
        }
    }

    ;如果今天没白嫖过
    checkX := [349]
    checkY := [1305]
    desiredColor := ["0x127CD7"]

    if !UserCheckColor(checkX, checkY, desiredColor) {
        ;白嫖第一次
        targetX := 383
        targetY := 1480
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [2063]
        checkY := [1821]
        desiredColor := ["0x079FE4"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime // 2
            if A_Index > waitTolerance {
                MsgBox "普通商店白嫖异常！"
                ExitApp
            }
        }

        targetX := 2100
        targetY := 1821
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [118]
        checkY := [908]
        desiredColor := ["0xF99217"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime // 2
            if A_Index > waitTolerance {
                MsgBox "普通商店白嫖异常！"
                ExitApp
            }
        }

        ;如果还有免费次数，则白嫖第二次
        checkX := [697]
        checkY := [949]
        desiredColor := ["0xFB5C24"]

        if UserCheckColor(checkX, checkY, desiredColor) {
            ;刷新
            targetX := 476
            targetY := 981
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [2133]
            checkY := [1345]
            desiredColor := ["0x00A0EB"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "普通商店刷新异常！"
                    ExitApp
                }
            }

            targetX := 2221
            targetY := 1351
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [118]
            checkY := [908]
            desiredColor := ["0xF99217"]
            targetX := 588
            targetY := 1803

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "普通商店刷新异常！"
                    ExitApp
                }
            }

            ;第二次白嫖
            targetX := 383
            targetY := 1480
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [2063]
            checkY := [1821]
            desiredColor := ["0x079FE4"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "普通商店白嫖异常！"
                    ExitApp
                }
            }

            targetX := 2100
            targetY := 1821
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [118]
            checkY := [908]
            desiredColor := ["0xF99217"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "普通商店白嫖异常！"
                    ExitApp
                }
            }
        }

    }

    ;废铁商店检查是否已经购买
    targetX := 137
    targetY := 1737
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [137]
    checkY := [1650]
    desiredColor := ["0xFB931A"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "废铁商店进入异常！"
            ExitApp
        }
    }

    if sleepTime < 1500
        Sleep 500

    global isBoughtTrash

    checkX := [349]
    checkY := [1305]
    desiredColor := ["0x137CD5"]

    if !UserCheckColor(checkX, checkY, desiredColor) {
        isBoughtTrash := 0
    }
    else {
        isBoughtTrash := 1
    }

    ;如果需要，则购买竞技场商店前三本书
    if numOfBook >= 1 or isCheckedCompanyWeapon {
        targetX := 134
        targetY := 1403
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [134]
        checkY := [1316]
        desiredColor := ["0xFA9318"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime // 2
            if A_Index > waitTolerance {
                MsgBox "竞技场商店进入异常！"
                ExitApp
            }
        }

        if sleepTime < 1500
            Sleep 500
    }

    if numOfBook >= 1 {
        ;购买第一本书
        ;如果今天没买过
        checkX := [349]
        checkY := [1305]
        desiredColor := ["0x127CD7"]

        ;如果今天没买过
        if !UserCheckColor(checkX, checkY, desiredColor) and BuyThisBook([378, 1210], scrRatio) {
            targetX := 384
            targetY := 1486
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [2067]
            checkY := [1770]
            desiredColor := ["0x07A0E4"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "第一本书购买异常！"
                    ExitApp
                }
            }

            targetX := 2067
            targetY := 1770
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [134]
            checkY := [1316]
            desiredColor := ["0xFA9318"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index >= 2 {
                    targetX := 2067
                    targetY := 1970
                }
                if A_Index > waitTolerance {
                    MsgBox "第一本书购买异常！"
                    ExitApp
                }
            }
        }
    }

    if numOfBook >= 2 {
        ;购买第二本书
        ;如果今天没买过
        checkX := [673]
        checkY := [1305]
        desiredColor := ["0x137CD5"]

        if !UserCheckColor(checkX, checkY, desiredColor) and BuyThisBook([702, 1210], scrRatio) {
            targetX := 702
            targetY := 1484
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [2067]
            checkY := [1770]
            desiredColor := ["0x07A0E4"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "第二本书购买异常！"
                    ExitApp
                }
            }

            targetX := 2067
            targetY := 1770
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [134]
            checkY := [1316]
            desiredColor := ["0xFA9318"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index >= 2 {
                    targetX := 2067
                    targetY := 1970
                }
                if A_Index > waitTolerance {
                    MsgBox "第二本书购买异常！"
                    ExitApp
                }
            }
        }
    }

    if numOfBook >= 3 {
        ;购买第三本书
        ;如果今天没买过
        checkX := [997]
        checkY := [1304]
        desiredColor := ["0x147BD4"]

        if !UserCheckColor(checkX, checkY, desiredColor) and BuyThisBook([1025, 1210], scrRatio) {
            targetX := 1030
            targetY := 1485
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [2067]
            checkY := [1770]
            desiredColor := ["0x07A0E4"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "第三本书购买异常！"
                    ExitApp
                }
            }

            targetX := 2067
            targetY := 1770
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [134]
            checkY := [1316]
            desiredColor := ["0xFA9318"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index >= 2 {
                    targetX := 2067
                    targetY := 1970
                }
                if A_Index > waitTolerance {
                    MsgBox "第三本书购买异常！"
                    ExitApp
                }
            }
        }
    }

    if isCheckedCompanyWeapon {
        checkX := [2011]
        checkY := [1213]
        desiredColor := ["0xD65E46"]

        if UserCheckColor(checkX, checkY, desiredColor) {
            targetX := 2017
            targetY := 1485
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [2067]
            checkY := [1770]
            desiredColor := ["0x07A0E4"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index > waitTolerance {
                    MsgBox "公司武器熔炉购买异常！"
                    ExitApp
                }
            }

            targetX := 2067
            targetY := 1770
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [134]
            checkY := [1316]
            desiredColor := ["0xFA9318"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime // 2
                if A_Index >= 2 {
                    targetX := 2067
                    targetY := 1970
                }
                if A_Index > waitTolerance {
                    MsgBox "公司武器熔炉购买异常！"
                    ExitApp
                }
            }
        }
    }

    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "退出免费商店失败！"
            ExitApp
        }
    }
}

;=============================================================
;4: 派遣
Expedition() {
    ;进入前哨基地
    targetX := 1169
    targetY := 1663
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入前哨基地失败！"
            ExitApp
        }
    }

    checkX := [1907, 1963, 1838, 2034]
    checkY := [1817, 1852, 1763, 1877]
    desiredColor := ["0xFFFFFF", "0xFFFFFF", "0x0B1219", "0x0B1219"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入前哨基地失败！"
            ExitApp
        }
    }

    ;派遣公告栏
    ;收菜
    targetX := 2002
    targetY := 2046
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [2113, 2119, 2387]
    checkY := [372, 399, 384]
    desiredColor := ["0x404240", "0x404240", "0x404240"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入派遣失败！"
            ExitApp
        }
    }

    targetX := 2268
    targetY := 1814
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime
    UserClick(targetX, targetY)
    Sleep sleepTime
    UserClick(targetX, targetY)
    Sleep sleepTime

    Sleep 3000

    ;全部派遣
    checkX := [1869, 1977]
    checkY := [1777, 1847]
    desiredColor := ["0xCFCFCF", "0xCFCFCF"]

    ;如果今天没派遣过
    if !UserCheckColor(checkX, checkY, desiredColor) {
        targetX := 1930
        targetY := 1813
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [2199, 2055]
        checkY := [1796, 1853]
        desiredColor := ["0x00ADFF", "0x00ADFF"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "全部派遣失败！"
                ExitApp
            }

            if UserCheckColor([1779], [1778], ["0xCFCFCF"])
                break
        }

        targetX := 2073
        targetY := 1818
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [2199, 2055]
        checkY := [1796, 1853]
        desiredColor := ["0x00ADFF", "0x00ADFF"]

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "全部派遣失败！"
                ExitApp
            }
        }
    }

    ;回到大厅
    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出前哨基地失败！"
            ExitApp
        }
    }
}

;=============================================================
;5: 好友点数收取
FriendPoint() {
    targetX := 3729
    targetY := 553
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入好友界面失败！"
            ExitApp
        }
    }

    checkX := [2104, 2197]
    checkY := [1825, 1838]
    desiredColor := ["0x0CAFF4", "0xF7FDFE"]
    targetX := 2276
    targetY := 1837

    while !UserCheckColor(checkX, checkY, desiredColor) && !UserCheckColor([2104, 2054], [1825, 1876], [
        "0x8B8788", "0x8B8788"], scrRatio) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入好友界面失败！"
            ExitApp
        }
    }

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "赠送好友点数失败"
            ExitApp
        }
    }

    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出好友界面失败！"
            ExitApp
        }
    }
}

;=============================================================
;6: 模拟室5C
SimulationRoom()
{
    targetX := 2689
    targetY := 1463
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    checkX := [1605]
    checkY := [280]
    desiredColor := ["0x01D4F6"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }
    
    ;进入模拟室
    targetX := 1547
    targetY := 1138
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1829, 2024]
    checkY := [1122, 1094]
    desiredColor := ["0xF8FCFD", "0xF8FCFD"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入模拟室失败！"
            ExitApp
        }
    }

    ;MsgBox "ok"

    ;开始模拟
    targetX := 1917
    targetY := 1274
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [2054, 2331]
    checkY := [719, 746]
    desiredColor := ["0xF8FBFD", "0xF8FBFD"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入选关失败！"
            ExitApp
        }
    }

    ;选择5C
    targetX := 2127
    targetY := 1074
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2

    targetX := 2263
    targetY := 1307
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2

    
    ;点击开始模拟
    ;开始模拟
    targetX := 2216
    targetY := 1818
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1991]
    checkY := [1814]
    desiredColor := ["0xFA801A"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "开始模拟失败！"
            ExitApp
        }
    }

    targetX := 1903
    targetY := 1369
    checkX := [304]
    checkY := [179]
    desiredColor := ["0x858289"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入buff选择页面失败！"
            ExitApp
        }
    }

    checkX := [1760]
    yy := 2160
    checkY := [yy]
    desiredColor := ["0xDFE1E1"]
    while !UserCheckColor(checkX, checkY, desiredColor) {
        yy := yy - 30
        checkY := [yy]
        if A_Index > waitTolerance {
            ExitApp
        }
    }

    targetX := 1760
    targetY := yy

    checkX := [2053]
    checkY := [1933]
    desiredColor := ["0x2E77C1"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入战斗准备页面失败！"
            ExitApp
        }
    }


    ;点击进入战斗
    targetX := 2225
    targetY := 2004
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2

    checkX := [1420, 2335]
    checkY := [1243, 1440]
    desiredColor := ["0xFFFFFF", "0xFE0203"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        ;UserClick(targetX, targetY - 300)
        CheckAutoBattle()
        Sleep sleepTime
        if A_Index > waitTolerance * 2 {
            ;MsgBox "模拟室boss战异常！"
            break
        }
    }

    targetX := 1898
    targetY := 1996
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [2115]
    checkY := [1305]
    stdCkptX2 := [2115]
    stdCkptY2 := [1556]
    desiredColor := ["0xEFF3F5"]

    while !UserCheckColor(checkX, checkY, desiredColor) && !UserCheckColor(stdCkptX2, stdCkptY2, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "模拟室结束异常！"
            ExitApp
        }
    }

    if colorTolerance != 15 {
        Sleep 5000
    }

    ;点击模拟结束
    targetX := 1923
    targetY := 1276
    if UserCheckColor(stdCkptX2, stdCkptY2, desiredColor) {
        targetX := 1923
        targetY := 1552
    }
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime // 2
    UserClick(targetX, targetY)
    Sleep sleepTime


    ;退回大厅
    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            ExitApp
        }
    }
}


;=============================================================
;7: 新人竞技场打第三位，顺带收50%以上的菜
RookieArena(times)
{
    ;进入方舟
    targetX := 2689
    targetY := 1463
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    checkX := [1605]
    checkY := [280]
    desiredColor := ["0x01D4F6"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    ;收pjjc菜
    Sleep 1500

    targetX := 2250
    targetY := 955
    UserClick(targetX, targetY)
    Sleep sleepTime
    ; UserClick(targetX, targetY)
    ; Sleep sleepTime

    targetX := 2129
    targetY := 1920

    checkX := [2129]
    checkY := [1920]
    desiredColor := ["0x01D4F6"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "收取競技場獎勵失败！"
            ExitApp
        }
    }


    ; UserClick(targetX, targetY)
    ; Sleep sleepTime // 2
    ; UserClick(targetX, targetY)
    ; Sleep sleepTime // 2

    ;进入竞技场
    targetX := 2254
    targetY := 1184
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1605]
    checkY := [280]
    desiredColor := ["0x01D4F6"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入竞技场失败！"
            ExitApp
        }
    }

    
    checkX := [1683]
    checkY := [606]
    desiredColor := ["0xF7FCFE"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入竞技场失败！"
            ExitApp
        }
    }
    

    ;进入新人竞技场
    targetX := 1647
    targetY := 1164
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [784]
    checkY := [1201]
    desiredColor := ["0xF8FCFE"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime

        ; if A_Index > 5 {
        ;     ;退回大厅
        ;     targetX := 333
        ;     targetY := 2041
        ;     UserClick(targetX, targetY)
        ;     Sleep sleepTime

        ;     checkX := [64]
        ;     checkY := [470]
        ;     desiredColor := ["0xFAA72C"]

        ;     while !UserCheckColor(checkX, checkY, desiredColor) {
        ;         UserClick(targetX, targetY)
        ;         Sleep sleepTime
        ;         if A_Index > waitTolerance {
        ;             MsgBox "退回大厅失败！"
        ;             ExitApp
        ;         }
        ;     }

        ;     return
        ; }
        
        if A_Index > waitTolerance {
            MsgBox "进入新人竞技场失败！"
            ExitApp
        }
    }

    loop times {
        ;点击进入战斗
        targetX := 2371
        targetY := 1847
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [2700]
        checkY := [1691]
        desiredColor := ["0xF7FCFE"]

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "选择对手失败！"
                ExitApp
            }
        }

        ;点击进入战斗
        targetX := 2123
        targetY := 1784
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [2784]
        checkY := [1471]
        desiredColor := ["0xF8FCFD"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "新人竞技场作战失败！"
                ExitApp
            }
        }
    }

    ;退回大厅
    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            ExitApp
        }
    }
}

;=============================================================
;8: 对前n位nikke进行好感度咨询(可以通过收藏把想要咨询的nikke排到前面)
NotAllCollection() {
    checkX := [2447]
    checkY := [1464]
    desiredColor := ["0x444547"]
    return UserCheckColor(checkX, checkY, desiredColor)
}

LoveTalking(times) {
    ;进入妮姬列表
    targetX := 1497
    targetY := 2004
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入妮姬列表失败！"
            ExitApp
        }
    }

    checkX := [1466, 1814]
    checkY := [428, 433]
    desiredColor := ["0x3B3C3E", "0x3B3C3E"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入妮姬列表失败！"
            ExitApp
        }
    }

    ;进入咨询页面
    targetX := 3308
    targetY := 257
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1650]
    checkY := [521]
    desiredColor := ["0x14B0F5"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        ;如果没次数了，直接退出
        if UserCheckColor(checkX, checkY, ["0xE0E0E2"]) {
            targetX := 333
            targetY := 2041
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [64]
            checkY := [470]
            desiredColor := ["0xFAA72C"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime
                if A_Index > waitTolerance {
                    MsgBox "退回大厅失败！"
                    ExitApp
                }
            }
            return
        }
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入咨询页面失败！"
            ExitApp
        }
    }

    ;点进第一个妮姬
    targetX := 736
    targetY := 749
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1504]
    checkY := [1747]
    desiredColor := ["0xF99F22"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入妮姬咨询页面失败！"
            ExitApp
        }
    }

    loop times {
        checkX := [1994]
        checkY := [1634]
        desiredColor := ["0xFA6E34"]

        ;如果能够快速咨询
        if UserCheckColor(checkX, checkY, desiredColor) && !(isCheckedLongTalk && NotAllCollection()) {
            ;点击快速咨询
            targetX := 2175
            targetY := 1634
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [1994]
            checkY := [1634]
            desiredColor := ["0xFA6E34"]

            while UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime
                if A_Index > waitTolerance {
                    MsgBox "进入妮姬咨询页面失败！"
                    ExitApp
                }
            }

            ;点击确定
            targetX := 2168
            targetY := 1346
            UserClick(targetX, targetY)
            Sleep sleepTime

            checkX := [1504]
            checkY := [1747]
            desiredColor := ["0xF99F22"]

            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(targetX, targetY)
                Sleep sleepTime
                if A_Index > waitTolerance {
                    MsgBox "快速咨询失败！"
                    ExitApp
                }
            }
        }
        else {
            ;如果不能快速咨询
            checkX := [1982]
            checkY := [1819]
            desiredColor := ["0x4A4A4C"]
            if !UserCheckColor(checkX, checkY, desiredColor) {
                targetX := 2168
                targetY := 1777
                UserClick(targetX, targetY)
                Sleep sleepTime

                checkX := [1504]
                checkY := [1747]
                desiredColor := ["0xF99F22"]

                while UserCheckColor(checkX, checkY, desiredColor) {
                    UserClick(targetX, targetY)
                    Sleep sleepTime
                    if A_Index > waitTolerance {
                        MsgBox "咨询失败！"
                        ExitApp
                    }
                }

                ;点击确认
                targetX := 2192
                targetY := 1349
                UserClick(targetX, targetY)
                Sleep sleepTime

                checkX := [2109]
                checkY := [1342]
                desiredColor := ["0x00A0EB"]

                while UserCheckColor(checkX, checkY, desiredColor) {
                    UserClick(targetX, targetY)
                    Sleep sleepTime
                    if A_Index > waitTolerance {
                        MsgBox "咨询失败！"
                        ExitApp
                    }
                }

                checkX := [1504]
                checkY := [1747]
                desiredColor := ["0xF99F22"]
                targetX := 1903
                targetY := 1483

                while !UserCheckColor(checkX, checkY, desiredColor) {
                    if Mod(A_Index, 2) == 0
                        UserClick(targetX, targetY)
                    else
                        UserClick(targetX, 1625)
                    Sleep sleepTime // 2
                    if A_Index > waitTolerance * 2 {
                        MsgBox "咨询失败！"
                        ExitApp
                    }
                }
            }
        }

        if A_Index >= times
            break

        ;翻页
        targetX := 3778
        targetY := 940
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [1982]
        checkY := [1819]
        desiredColor := ["0x4A4A4C"]

        numOfTalked := A_Index

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index + numOfTalked >= times + 2
                break 2
            if A_Index > waitTolerance {
                MsgBox "咨询失败！"
                ExitApp
            }
        }
    }

    ;退回大厅
    targetX := 333
    targetY := 2041
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            ExitApp
        }
    }
}

;=============================================================
;9: 爬塔一次(做每日任务)
TribeTower() {
    targetX := 2689
    targetY := 1463
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    checkX := [1605]
    checkY := [280]
    desiredColor := ["0x01D4F6"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    ;进入无限之塔
    targetX := 2278
    targetY := 776
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [2405]
    checkY := [1014]
    desiredColor := ["0xF8FBFE"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入无限之塔失败！"
            ExitApp
        }
    }

    targetX := 1953
    targetY := 934
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [2129, 2305]
    checkY := [1935, 1935]
    desiredColor := ["0x2E77C2", "0x2E77C2"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "选择作战失败！"
            ExitApp
        }
    }

    targetX := 2242
    targetY := 2001
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [2129, 2305]
    checkY := [1935, 1935]
    desiredColor := ["0x2E77C2", "0x2E77C2"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入作战失败！"
            ExitApp
        }
    }

    ;按esc
    checkX := [2065]
    checkY := [1954]
    desiredColor := ["0x238CFD"]
    targetX := 3780
    targetY := 75

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "按esc失败！"
            ExitApp
        }
    }

    ;按放弃战斗
    checkX := [2065]
    checkY := [1954]
    desiredColor := ["0x238CFD"]
    targetX := 1678
    targetY := 1986

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "放弃战斗失败！"
            ExitApp
        }
    }

    ;退回大厅
    targetX := 301
    targetY := 2030
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            ExitApp
        }
    }
}

;=============================================================
MissionCompleted() {
    checkX := [3451, 3756]
    checkY := [2077, 2075]
    desiredColor := ["0x00A1FF", "0x00A1FF"]

    if UserCheckColor(checkX, checkY, desiredColor)
        return true
    else
        return false
}

MissionFailed() {
    checkX := [2306, 1920, 1590, 1560]
    checkY := [702, 1485, 1489, 1473]
    desiredColor1 := ["0xB71013", "0xE9E9E7", "0x161515", "0xE9E9E7"]
    desiredColor2 := ["0xAD080B", "0xE9E9E7", "0x161515", "0xE9E9E7"]

    if UserCheckColor(checkX, checkY, desiredColor1) or UserCheckColor(checkX, checkY, desiredColor2,
        scrRatio)
        return true
    else
        return false
}

MissionEnded() {
    checkX := [3494, 3721, 3526, 3457, 3339, 3407]
    checkY := [2086, 2093, 2033, 2043, 2040, 2043]
    desiredColor := ["0x6F6F6F", "0x6F6F6F", "0x030303", "0x434343", "0xE6E6E6", "0x000000"]

    if UserCheckColor(checkX, checkY, desiredColor)
        return true
    else
        return false
}

failedTower := Array()

CompanyTowerInfo() {
    info := ""
    loop failedTower.Length {
        info := info failedTower[A_Index] " "
    }
    if info != "" {
        info := "`n" info "已经爬不动惹dororo..."
    }
    return info
}

;10: 企业塔
CompanyTower() {
    targetX := 2689
    targetY := 1463
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    checkX := [1605]
    checkY := [280]
    desiredColor := ["0x01D4F6"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    ;进入无限之塔
    targetX := 2278
    targetY := 776
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [2405]
    checkY := [1014]
    desiredColor := ["0xF8FBFE"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入无限之塔失败！"
            ExitApp
        }
    }

    Sleep 1500

    ;尝试进入每座企业塔
    targX := [1501, 1779, 2061, 2332]
    targY := [1497, 1497, 1497, 1497]
    ckptX := [1383, 1665, 1935, 2222]
    ckptY := [1925, 1925, 1925, 1925]

    loop targX.Length {
        i := A_Index

        targetX := targX[i]
        targetY := targY[i]
        checkX := [ckptX[i]]
        checkY := [ckptY[i]]
        desiredColor := ["0x00AAF4"]

        ;如果未开放，则检查下一个企业
        if !UserCheckColor(checkX, checkY, desiredColor)
            continue

        ;点击进入企业塔
        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "进入企业塔失败！"
                ExitApp
            }
        }

        ;直到成功进入企业塔
        checkX := [3738]
        checkY := [447]
        desiredColor := ["0xF8FCFE"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "进入企业塔失败！"
                ExitApp
            }
        }

        ;进入关卡页面
        targetX := 1918
        targetY := 919

        checkX := [992]
        checkY := [2011]
        desiredColor := ["0x000000"]

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "进入企业塔关卡页面失败！"
                ExitApp
            }
        }

        ;如果战斗次数已经用完
        Sleep 1000
        checkX := [2038]
        checkY := [2057]
        desiredColor := ["0x4D4E50"]
        if UserCheckColor(checkX, checkY, desiredColor) {
            checkX := [3738]
            checkY := [447]
            desiredColor := ["0xF8FCFE"]
            while UserCheckColor(checkX, checkY, desiredColor) {
                Send "{Escape}"
                Sleep sleepTime
            }

            checkX := [2405]
            checkY := [1014]
            desiredColor := ["0xF8FBFE"]
            while !UserCheckColor(checkX, checkY, desiredColor)
                Sleep sleepTime

            Sleep 1500
            continue
        }

        ;点击进入战斗
        targetX := 2249
        targetY := 1997
        UserClick(targetX, targetY)
        Sleep sleepTime
        UserClick(targetX, targetY)
        Sleep sleepTime
        UserClick(targetX, targetY)
        Sleep sleepTime

        ;等待战斗结束
WaitForBattleEnd:
        while !(MissionCompleted() || MissionFailed() || MissionEnded()) {
            CheckAutoBattle()
            Sleep sleepTime
            if A_Index > waitTolerance * 20 {
                MsgBox "企业塔自动战斗失败！"
                ExitApp
            }
        }

        ;如果战斗失败或次数用完
        if MissionFailed() || MissionEnded() {
            if MissionFailed() {
                towerName := ""
                global failedTower
                switch i {
                    case 1:
                        towerName := "极乐净土塔"
                    case 2:
                        towerName := "米西利斯塔"
                    case 3:
                        towerName := "泰特拉塔"
                    case 4:
                        towerName := "朝圣者塔"
                    default:
                        towerName := ""
                }
                failedTower.Push towerName
            }

            Send "{Escape}"
            Sleep sleepTime

            while MissionFailed() || MissionEnded() {
                Send "{Escape}"
                Sleep sleepTime
            }

            checkX := [3738]
            checkY := [447]
            desiredColor := ["0xF8FCFE"]
            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(3666, 1390)
                Sleep sleepTime
                if UserCheckColor([2088], [1327], ["0x00A0EB"]) {
                    UserClick(2202, 1342)
                    Sleep sleepTime
                }
            }

            Sleep 5000
            while !UserCheckColor(checkX, checkY, desiredColor) {
                UserClick(3666, 1390)
                Sleep sleepTime
                if UserCheckColor([2088], [1327], ["0x00A0EB"]) {
                    UserClick(2202, 1342)
                    Sleep sleepTime
                }
            }

            while UserCheckColor(checkX, checkY, desiredColor) {
                Send "{Escape}"
                Sleep sleepTime
            }

            checkX := [2405]
            checkY := [1014]
            desiredColor := ["0xF8FBFE"]
            while !UserCheckColor(checkX, checkY, desiredColor)
                Sleep sleepTime

            Sleep 1500
            continue
        }

        ;如果战斗胜利
        while MissionCompleted() {
            Send "t"
            Sleep sleepTime
        }

        goto WaitForBattleEnd
    }

    ;退回大厅
    targetX := 301
    targetY := 2030
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            ExitApp
        }
    }
}

;=============================================================
;11: 进入异拦
Interception() {
    targetX := 2689
    targetY := 1463
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime // 2
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    checkX := [1605]
    checkY := [280]
    desiredColor := ["0x01D4F6"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入方舟失败！"
            ExitApp
        }
    }

    ;进入拦截战
    targetX := 1781
    targetY := 1719
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [1605]
    checkY := [280]
    desiredColor := ["0x01D4F6"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入拦截战失败！"
            ExitApp
        }
    }


    targetX := 559
    targetY := 1571
    UserClick(targetX, targetY)
    Sleep 1000
    UserClick(targetX, targetY)
    Sleep 1000
    UserClick(targetX, targetY)
    Sleep 1000

    ;选择BOSS
    switch InterceptionBoss {
        case 1:
            targetX := 1556
            targetY := 886
            checkX := [1907]
            checkY := [898]
            desiredColor := ["0xFA910E"]

        case 2:
            targetX := 2279
            targetY := 1296
            checkX := [1923]
            checkY := [908]
            desiredColor := ["0xFB01F1"]

        case 3:
            checkX := [1917]
            checkY := [910]
            desiredColor := ["0x037EF9"]

        case 4:
            targetX := 2281
            targetY := 899
            checkX := [1916]
            checkY := [907]
            desiredColor := ["0x00F556"]

        case 5:
            targetX := 1551
            targetY := 1299
            checkX := [1919]
            checkY := [890]
            desiredColor := ["0xFD000F"]

        default:
            MsgBox "BOSS选择错误！"
            ExitApp
    }

    targetX := 1556
    targetY := 886

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep 2000
        if A_Index > waitTolerance {
            MsgBox "选择BOSS失败！"
            ExitApp
        }
    }

    ;点击挑战按钮
    if UserCheckColor([1735], [1730], ["0x28282A"]) {
        targetX := 301
        targetY := 2030
        UserClick(targetX, targetY)
        Sleep sleepTime

        checkX := [64]
        checkY := [470]
        desiredColor := ["0xFAA72C"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退回大厅失败！"
                ExitApp
            }
        }
        return
    }

    targetX := 1924
    targetY := 1779

    checkX := [1390]
    checkY := [1799]
    desiredColor := ["0x01AEF3"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "点击挑战失败！"
            ExitApp
        }
    }

    ;选择编队
    switch InterceptionBoss {
        case 1:
            targetX := 1882
            targetY := 1460
            checkX := [1843]
            checkY := [1428]

        case 2:
            targetX := 2020
            targetY := 1460
            checkX := [1981]
            checkY := [1428]

        case 3:
            targetX := 2151
            targetY := 1460
            checkX := [2113]
            checkY := [1428]

        case 4:
            targetX := 2282
            targetY := 1460
            checkX := [2248]
            checkY := [1428]

        case 5:
            targetX := 2421
            targetY := 1460
            checkX := [2380]
            checkY := [1428]

        default:
            MsgBox "BOSS选择错误！"
            ExitApp
    }

    desiredColor := ["0x02ADF5"]
    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep 1500
        if A_Index > waitTolerance {
            MsgBox "选择编队失败！"
            ExitApp
        }
    }

    ;如果不能快速战斗，就进入战斗
    checkX := [1964]
    checkY := [1800]
    desiredColor := ["0xF96B2F"]

    if !UserCheckColor(checkX, checkY, desiredColor) {
        targetX := 2219
        targetY := 1992
        checkX := [1962]
        checkY := [1932]
        desiredColor := ["0xD52013"]

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "进入战斗失败！"
                ExitApp
            }
        }

        ;退出结算页面
        targetX := 904
        targetY := 1805
        checkX := [3731, 3713, 3638]
        checkY := [2040, 2034, 2091]
        desiredColor := ["0xE6E6E6", "0xE6E6E6", "0x000000"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            CheckAutoBattle()
            Sleep sleepTime
            if A_Index > waitTolerance * 20 {
                MsgBox "自动战斗失败！"
                ExitApp
            }
        }

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退出结算页面失败！"
                ExitApp
            }
        }
    }

    ;检查是否退出
    checkX := [1390]
    checkY := [1799]
    desiredColor := ["0x01AEF3"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出结算页面失败！"
            ExitApp
        }
    }

    ;快速战斗
    targetX := 2229
    targetY := 1842
    checkX := [1964]
    checkY := [1800]
    desiredColor := ["0xF96B2F"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "快速战斗失败！"
                ExitApp
            }
        }

        ;退出结算页面
        targetX := 904
        targetY := 1805
        checkX := [2232, 2391, 2464]
        checkY := [2100, 2099, 2051]
        desiredColor := ["0x000000", "0x000000", "0x000000"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "快速战斗结算失败！"
                ExitApp
            }
        }

        while UserCheckColor(checkX, checkY, desiredColor) {
            UserClick(targetX, targetY)
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退出结算页面失败！"
                ExitApp
            }
        }
        

        ;检查是否退出
        checkX := [1390]
        checkY := [1799]
        desiredColor := ["0x01AEF3"]

        while !UserCheckColor(checkX, checkY, desiredColor) {
            Sleep sleepTime
            if A_Index > waitTolerance {
                MsgBox "退出结算页面失败！"
                ExitApp
            }
        }

        Sleep 1000

        targetX := 2229
        targetY := 1842
        checkX := [1964]
        checkY := [1800]
        desiredColor := ["0xF96B2F"]
    }

    ;退回大厅
    targetX := 301
    targetY := 2030
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY)
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退回大厅失败！"
            ExitApp
        }
    }
}

;=============================================================

;11: 邮箱收取
Mail() {
    targetX := 3667
    targetY := 81
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;检测大厅点邮箱
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入邮箱失败！"
            ExitApp
        }
    }

    checkX := [2085]
    checkY := [1809]
    desiredColor := ["0xCAC7C4"] ;检测灰色的领取按钮
    targetX := 2085
    targetY := 1809
    ;Sleep sleepTime ;加载容错
    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;不是灰色就一直点全部领取
        Sleep sleepTime
    }

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]
    targetX := 2394
    targetY := 291
    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;确认领取+返回直到回到大厅
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出邮箱失败！"
            ExitApp
        }
    }
}

;=============================================================

;12: 任务收取
Mission() {
    targetX := 3341
    targetY := 206
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;检测大厅点任务
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入任务失败！"
            ExitApp
        }
    }
    targetX := 2286
    targetY := 1935
    x0 := 1512 ;用于遍历任务
    y0 := 395

    while UserCheckColor([1365, 2087], [1872, 1997], ["0xF5F5F5", "0xF5F5F5"]) { ;检测是否在任务界面
        Sleep sleepTime
        UserClick(x0, y0) ;点任务标题
        Sleep sleepTime
        if !UserCheckColor([1365, 2087], [1872, 1997], ["0xF5F5F5", "0xF5F5F5"]) { ;退出
            break
        }
        checkX := [2276]
        checkY := [1899]
        desiredColor := ["0x7B7C7B"]
        while !UserCheckColor(checkX, checkY, desiredColor) { ;如果不是灰色就点
            Sleep sleepTime
            UserClick(targetX, targetY) ;点领取
        }
        x0 := x0 + 280 ;向右切换标题
    }

}

;=============================================================

;13: 通行证收取 兼容双通行证 兼容特殊活动

Pass() {
    OnePass()
    checkX := [3395]
    checkY := [368]
    stdCkptY1 := [468] ;活动可能偏移
    desiredColor := ["0xFBFFFF"] ;白色的轮换按钮
    targetX := 3395
    targetY := 368
    stdTargetY1 := 468
    if UserCheckColor(checkX, checkY, desiredColor) {  ;如果轮换按钮存在
        global PassRound
        PassRound := 0
        while (PassRound < 2) {
            UserClick(targetX, targetY) ;转一下
            Sleep sleepTime
            PassRound := PassRound + 1
            checkX := [3437]
            checkY := [338]
            desiredColor := ["0xFE1809"] ;红点
            if UserCheckColor(checkX, checkY, desiredColor) { ;如果转出红点
                Sleep sleepTime
                UserClick(targetX, targetY) ;再转一下
                Sleep sleepTime
                OnePass()
                break
            }
        }

    }

    if UserCheckColor(checkX, stdCkptY1, desiredColor) {  ;检测是否偏移
        global PassRound
        PassRound := 0
        while (PassRound < 2) {
            UserClick(targetX, stdTargetY1) ;转一下
            Sleep sleepTime
            PassRound := PassRound + 1
            checkX := [3437]
            checkY := [438]
            desiredColor := ["0xFE1809"] ;红点
            if UserCheckColor(checkX, checkY, desiredColor) { ;如果转出红点
                Sleep sleepTime
                UserClick(targetX, stdTargetY1) ;再转一下
                Sleep sleepTime
                OnePass()
                break
            }
        }

    }

}

OnePass() { ;执行一次通行证
    targetX := 3633
    targetY := 405
    UserClick(targetX, targetY)
    Sleep sleepTime

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]

    while UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;检测大厅点通行证
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "进入通行证失败！"
            ExitApp
        }
    }

    checkX := [1733]
    checkY := [699]
    desiredColor := ["0xF1F5F6"]
    targetX := 2130
    targetY := 699
    while !UserCheckColor(checkX, checkY, desiredColor) { ;左不是白则点右
        UserClick(targetX, targetY)
        Sleep sleepTime
    }

    checkX := [1824]
    checkY := [1992]
    desiredColor := ["0x7C7C7C"] ;检测灰色的全部领取
    targetX := 1824
    targetY := 1992
    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;不是灰色就一直点领取
        Sleep sleepTime
    }

    checkX := [2130]
    checkY := [699]
    desiredColor := ["0xF1F5F6"]
    targetX := 1733
    targetY := 699
    while !UserCheckColor(checkX, checkY, desiredColor) { ;右不是白则点左
        UserClick(targetX, targetY)
        Sleep sleepTime
    }

    checkX := [1824]
    checkY := [1992]
    desiredColor := ["0x7C7C7C"] ;检测灰色的全部领取
    targetX := 1824
    targetY := 1992
    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;不是灰色就一直点领取
        Sleep sleepTime
    }

    checkX := [64]
    checkY := [470]
    desiredColor := ["0xFAA72C"]
    targetX := 2418
    targetY := 185
    while !UserCheckColor(checkX, checkY, desiredColor) {
        UserClick(targetX, targetY) ;确认领取+返回直到回到大厅
        Sleep sleepTime
        if A_Index > waitTolerance {
            MsgBox "退出通行证失败！"
            ExitApp
        }
    }
    checkX := [3395]
    checkY := [368]
    desiredColor := ["0xFBFFFF"] ;检测是否多通行证
    targetX := 3395
    targetY := 368
    if UserCheckColor(checkX, checkY, desiredColor) {

    }
}

ClickOnOutpostDefence(*) {
    global isCheckedOutposeDefence
    isCheckedOutposeDefence := 1 - isCheckedOutposeDefence
}

ClickOnCashShop(*) {
    global isCheckedCashShop
    isCheckedCashShop := 1 - isCheckedCashShop
}

ClickOnFreeShop(*) {
    global isCheckedFreeShop
    isCheckedFreeShop := 1 - isCheckedFreeShop
}

ClickOnExpedition(*) {
    global isCheckedExpedtion
    isCheckedExpedtion := 1 - isCheckedExpedtion
}

ClickOnFriendPoint(*) {
    global isCheckedFriendPoint
    isCheckedFriendPoint := 1 - isCheckedFriendPoint
}

ClickOnMail(*) {
    global isCheckedMail
    isCheckedMail := 1 - isCheckedMail
}

ClickOnMission(*) {
    global isCheckedMission
    isCheckedMission := 1 - isCheckedMission
}

ClickOnPass(*) {
    global isCheckedPass
    isCheckedPass := 1 - isCheckedPass
}

ClickOnSimulationRoom(*) {
    global isCheckedSimulationRoom
    isCheckedSimulationRoom := 1 - isCheckedSimulationRoom
}

ClickOnRookieArena(*) {
    global isCheckedRookieArena
    isCheckedRookieArena := 1 - isCheckedRookieArena
}

ClickOnLoveTalking(*) {
    global isCheckedLoveTalking
    isCheckedLoveTalking := 1 - isCheckedLoveTalking
}

ClickOnCompanyTower(*) {
    global isCheckedCompanyTower
    isCheckedCompanyTower := 1 - isCheckedCompanyTower
}

ClickOnTribeTower(*) {
    global isCheckedTribeTower
    isCheckedTribeTower := 1 - isCheckedTribeTower
}

ClickOnCompanyWeapon(*) {
    global isCheckedCompanyWeapon
    isCheckedCompanyWeapon := 1 - isCheckedCompanyWeapon
}

ClickOnInterception(*) {
    global isCheckedInterception
    isCheckedInterception := 1 - isCheckedInterception
}

ClickOnLongTalk(*) {
    global isCheckedLongTalk
    isCheckedLongTalk := 1 - isCheckedLongTalk
}

ClickAutoCheckUpdate(*) {
    global isCheckedAutoCheckUpdate
    isCheckedAutoCheckUpdate := 1 - isCheckedAutoCheckUpdate
}

ClickOnFireBook(*) {
    global isCheckedBook
    isCheckedBook[1] := 1 - isCheckedBook[1]
}

ClickOnWaterBook(*) {
    global isCheckedBook
    isCheckedBook[2] := 1 - isCheckedBook[2]
}

ClickOnWindBook(*) {
    global isCheckedBook
    isCheckedBook[3] := 1 - isCheckedBook[3]
}

ClickOnElecBook(*) {
    global isCheckedBook
    isCheckedBook[4] := 1 - isCheckedBook[4]
}

ClickOnIronBook(*) {
    global isCheckedBook
    isCheckedBook[5] := 1 - isCheckedBook[5]
}

ChangeOnNumOfBook(GUICtrl, *) {
    global numOfBook
    numOfBook := GUICtrl.Value - 1
}

ChangeOnNumOfBattle(GUICtrl, *) {
    global numOfBattle
    numOfBattle := GUICtrl.Value + 1
}

ChangeOnNumOfLoveTalking(GUICtrl, *) {
    global numOfLoveTalking
    numOfLoveTalking := GUICtrl.Value
}

ChangeOnInterceptionBoss(GUICtrl, *) {
    global InterceptionBoss
    InterceptionBoss := GUICtrl.Value
}

ChangeOnSleepTime(GUICtrl, *) {
    global sleepTime
    switch GUICtrl.Value {
        case 1: sleepTime := 750
        case 2: sleepTime := 1000
        case 3: sleepTime := 1250
        case 4: sleepTime := 1500
        case 5: sleepTime := 1750
        case 6: sleepTime := 2000
        default: sleepTime := 1500
    }
}

ChangeOnColorTolerance(GUICtrl, *) {
    global colorTolerance
    switch GUICtrl.Value {
        case 1: colorTolerance := 15
        case 2: colorTolerance := 35
        default: colorTolerance := 15
    }
}

ClickOnHelp(*) {
    msgbox "
    (
    #############################################
    使用说明

    对大多数老玩家来说Doro设置保持默认就好。
    万一Doro失控，请按Ctrl + z组合键结束进程。

    ############################################# 
    要求：

    - 【设定-画质-全屏幕模式 + 16:9的显示器比例】（推荐）   或    【16:9的窗口模式（窗口尽量拉大，否则像素识别可能出现误差）】
    - 设定-画质-开启光晕效果
    - 设定-画质-开启颜色分级
    - 游戏语言设置为简体中文
    - 以**管理员身份**运行DoroHelper
    - 不要开启windows HDR显示

    ############################################# 
    步骤：

    -打开NIKKE启动器。点击启动。等右下角腾讯ACE反作弊系统扫完，NIKKE主程序中央SHIFT UP logo出现之后，再切出来点击“DORO!”按钮。如果你看到鼠标开始在左下角连点，那就代表启动成功了。然后就可以悠闲地去泡一杯咖啡，或者刷一会儿手机，等待Doro完成工作了。
    -也可以在游戏处在大厅界面时（有看板娘的页面）切出来点击“DORO!”按钮启动程序。
    -游戏需要更新的时候请更新完再使用Doro。

    ############################################# 
    其他:
    
    -检查是否发布了新版本。
    -如果出现死循环，提高点击间隔可以解决80%的问题。
    -如果你的电脑配置较好的话，或许可以尝试降低点击间隔。
    
    )"

}
; start point
ClickOnDoro(*) {
    WriteSettings()

    title := "勝利女神：妮姬"
    try {
        WinGetClientPos , , &userScreenW, &userScreenH, "勝利女神：妮姬"
    } catch as err {
        title := "ahk_exe nikke.exe"
    }

    numNikke := WinGetCount(title)

    if numNikke = 0 {
        MsgBox "未检测到NIKKE主程序"
        ExitApp
    }

    loop numNikke {

        nikkeID := WinGetIDLast(title)
        WinActivate nikkeID
        WinGetClientPos , , &userScreenW, &userScreenH, nikkeID
        global scrRatio
        scrRatio := userScreenW / stdScreenW

        Login() ;登陆到主界面

        if isCheckedOutposeDefence
            OutpostDefence() ;前哨基地防御奖励

        if isCheckedCashShop  
            CashShop() ;付费商店领免费钻

        if isCheckedFreeShop 
            FreeShop(numOfBook) ;普通商店白嫖

        if isCheckedOutposeDefence
            OutpostDefence() ;前哨基地防御奖励*2(任务)

        if isCheckedExpedtion
            Expedition() ;派遣

        if isCheckedFriendPoint
            FriendPoint() ;好友点数收取

        if isCheckedSimulationRoom
            SimulationRoom() ;模拟室5C(不拿buff)

        if isCheckedRookieArena
            RookieArena(numOfBattle) ;新人竞技场n次打第三位，顺带收50%以上的菜

        if isCheckedLoveTalking
            LoveTalking(numOfLoveTalking) ;;对前n位nikke进行好感度咨询(可以通过收藏把想要咨询的nikke排到前面)

        if isCheckedTribeTower && isCheckedCompanyTower 
            TribeTower() ;爬塔一次(蹭每日任务)

        if isCheckedCompanyTower && !isCheckedTribeTower
            CompanyTower() ;爬塔

        if isCheckedInterception
            Interception() ;打异常拦截

        if isCheckedMail 
            Mail() ;邮箱收取

        if isCheckedMission
            Mission() ;每日奖励收取

        if isCheckedPass
            Pass() ;Pass收取

    }

    if isBoughtTrash == 0
        MsgBox "协同作战商店似乎已经刷新了，快去看看吧"

    MsgBox "Doro完成任务！" CompanyTowerInfo()

    ;ExitApp
    Pause
}

SleepTimeToLabel(sleepTime) {
    return String(sleepTime / 250 - 2)
}

ColorToleranceToLabel(colorTolerance) {
    switch colorTolerance {
        case 15: return "1"
        case 35: return "2"
        default:
            return "1"
    }
}

IsCheckedToString(foo) {
    if foo
        return "Checked"
    else
        return ""
}

NumOfBookToLabel(n) {
    return String(n + 1)
}

NumOfBattleToLabel(n) {
    return String(n - 1)
}

NumOfLoveTalkingToLabel(n) {
    return String(n)
}

InterceptionBossToLabel(n) {
    return String(n)
}

SaveSettings(*) {
    WriteSettings()
    MsgBox "设置已保存！"
}

WriteSettings(*) {
    IniWrite(sleepTime, "settings.ini", "section1", "sleepTime")
    IniWrite(colorTolerance, "settings.ini", "section1", "colorTolerance")
    IniWrite(isCheckedOutposeDefence, "settings.ini", "section1", "isCheckedOutposeDefence")
    IniWrite(isCheckedCashShop, "settings.ini", "section1", "isCheckedCashShop")
    IniWrite(isCheckedFreeShop, "settings.ini", "section1", "isCheckedFreeShop")
    IniWrite(isCheckedExpedtion, "settings.ini", "section1", "isCheckedExpedtion")
    IniWrite(isCheckedFriendPoint, "settings.ini", "section1", "isCheckedFriendPoint")
    IniWrite(isCheckedMail, "settings.ini", "section1", "isCheckedMail")
    IniWrite(isCheckedMission, "settings.ini", "section1", "isCheckedMission")
    IniWrite(isCheckedPass, "settings.ini", "section1", "isCheckedPass")
    IniWrite(isCheckedSimulationRoom, "settings.ini", "section1", "isCheckedSimulationRoom")
    IniWrite(isCheckedRookieArena, "settings.ini", "section1", "isCheckedRookieArena")
    IniWrite(isCheckedLoveTalking, "settings.ini", "section1", "isCheckedLoveTalking")
    IniWrite(isCheckedCompanyTower, "settings.ini", "section1", "isCheckedCompanyTower")
    IniWrite(isCheckedTribeTower, "settings.ini", "section1", "isCheckedTribeTower")
    IniWrite(isCheckedCompanyWeapon, "settings.ini", "section1", "isCheckedCompanyWeapon")
    IniWrite(numOfBook, "settings.ini", "section1", "numOfBook")
    IniWrite(numOfBattle, "settings.ini", "section1", "numOfBattle")
    IniWrite(numOfLoveTalking, "settings.ini", "section1", "numOfLoveTalking")
    IniWrite(isCheckedInterception, "settings.ini", "section1", "isCheckedInterception")
    IniWrite(InterceptionBoss, "settings.ini", "section1", "InterceptionBoss")
    IniWrite(isCheckedLongTalk, "settings.ini", "section1", "isCheckedLongTalk")
    IniWrite(isCheckedAutoCheckUpdate, "settings.ini", "section1", "isCheckedAutoCheckUpdate")
    IniWrite(isCheckedBook[1], "settings.ini", "section1", "isCheckedBook[1]")
    IniWrite(isCheckedBook[2], "settings.ini", "section1", "isCheckedBook[2]")
    IniWrite(isCheckedBook[3], "settings.ini", "section1", "isCheckedBook[3]")
    IniWrite(isCheckedBook[4], "settings.ini", "section1", "isCheckedBook[4]")
    IniWrite(isCheckedBook[5], "settings.ini", "section1", "isCheckedBook[5]")
}

LoadSettings() {
    global sleepTime
    global colorTolerance
    global isCheckedOutposeDefence
    global isCheckedCashShop
    global isCheckedFreeShop
    global isCheckedExpedtion
    global isCheckedFriendPoint
    global isCheckedMail
    global isCheckedMission
    global isCheckedPass
    global isCheckedSimulationRoom
    global isCheckedRookieArena
    global isCheckedLoveTalking
    global isCheckedCompanyTower
    global isCheckedTribeTower
    global isCheckedCompanyWeapon
    global numOfBook
    global numOfBattle
    global numOfLoveTalking
    global isCheckedInterception
    global InterceptionBoss
    global isCheckedLongTalk
    global isCheckedAutoCheckUpdate
    global isCheckedBook

    sleepTime := IniRead("settings.ini", "section1", "sleepTime")
    colorTolerance := IniRead("settings.ini", "section1", "colorTolerance")
    isCheckedOutposeDefence := IniRead("settings.ini", "section1", "isCheckedOutposeDefence")
    isCheckedCashShop := IniRead("settings.ini", "section1", "isCheckedCashShop")
    isCheckedFreeShop := IniRead("settings.ini", "section1", "isCheckedFreeShop")
    isCheckedExpedtion := IniRead("settings.ini", "section1", "isCheckedExpedtion")
    isCheckedFriendPoint := IniRead("settings.ini", "section1", "isCheckedFriendPoint")
    isCheckedSimulationRoom := IniRead("settings.ini", "section1", "isCheckedSimulationRoom")
    isCheckedRookieArena := IniRead("settings.ini", "section1", "isCheckedRookieArena")
    isCheckedLoveTalking := IniRead("settings.ini", "section1", "isCheckedLoveTalking")
    isCheckedTribeTower := IniRead("settings.ini", "section1", "isCheckedTribeTower")
    isCheckedCompanyWeapon := IniRead("settings.ini", "section1", "isCheckedCompanyWeapon")
    numOfBook := IniRead("settings.ini", "section1", "numOfBook")
    numOfBattle := IniRead("settings.ini", "section1", "numOfBattle")
    numOfLoveTalking := IniRead("settings.ini", "section1", "numOfLoveTalking")

    try {
        isCheckedInterception := IniRead("settings.ini", "section1", "isCheckedInterception")
    }
    catch as err {
        IniWrite(isCheckedInterception, "settings.ini", "section1", "isCheckedInterception")
    }

    try {
        InterceptionBoss := IniRead("settings.ini", "section1", "InterceptionBoss")
    }
    catch as err {
        IniWrite(InterceptionBoss, "settings.ini", "section1", "InterceptionBoss")
    }

    try {
        isCheckedCompanyTower := IniRead("settings.ini", "section1", "isCheckedCompanyTower")
    }
    catch as err {
        IniWrite(isCheckedCompanyTower, "settings.ini", "section1", "isCheckedCompanyTower")
    }

    try {
        isCheckedLongTalk := IniRead("settings.ini", "section1", "isCheckedLongTalk")
    }
    catch as err {
        IniWrite(isCheckedLongTalk, "settings.ini", "section1", "isCheckedLongTalk")
    }

    try {
        isCheckedAutoCheckUpdate := IniRead("settings.ini", "section1", "isCheckedAutoCheckUpdate")
    }
    catch as err {
        IniWrite(isCheckedAutoCheckUpdate, "settings.ini", "section1", "isCheckedAutoCheckUpdate")
    }

    try {
        isCheckedBook[1] := IniRead("settings.ini", "section1", "isCheckedBook[1]")
    }
    catch as err {
        IniWrite(isCheckedBook[1], "settings.ini", "section1", "isCheckedBook[1]")
    }

    try {
        isCheckedBook[2] := IniRead("settings.ini", "section1", "isCheckedBook[2]")
    }
    catch as err {
        IniWrite(isCheckedBook[2], "settings.ini", "section1", "isCheckedBook[2]")
    }

    try {
        isCheckedBook[3] := IniRead("settings.ini", "section1", "isCheckedBook[3]")
    }
    catch as err {
        IniWrite(isCheckedBook[3], "settings.ini", "section1", "isCheckedBook[3]")
    }

    try {
        isCheckedBook[4] := IniRead("settings.ini", "section1", "isCheckedBook[4]")
    }
    catch as err {
        IniWrite(isCheckedBook[4], "settings.ini", "section1", "isCheckedBook[4]")
    }

    try {
        isCheckedBook[5] := IniRead("settings.ini", "section1", "isCheckedBook[5]")
    }
    catch as err {
        IniWrite(isCheckedBook[5], "settings.ini", "section1", "isCheckedBook[5]")
    }

    try {
        isCheckedMail := IniRead("settings.ini", "section1", "isCheckedMail")
    }
    catch as err {
        IniWrite(isCheckedMail, "settings.ini", "section1", "isCheckedMail")
    }

    try {
        isCheckedMission := IniRead("settings.ini", "section1", "isCheckedMission")
    }
    catch as err {
        IniWrite(isCheckedMission, "settings.ini", "section1", "isCheckedMission")
    }

    try {
        isCheckedPass := IniRead("settings.ini", "section1", "isCheckedPass")
    }
    catch as err {
        IniWrite(isCheckedPass, "settings.ini", "section1", "isCheckedPass")
    }

}

isCheckedOutposeDefence := 1
isCheckedCashShop := 1
isCheckedFreeShop := 1
isCheckedExpedtion := 1
isCheckedFriendPoint := 1
isCheckedMail := 1
isCheckedMission := 1
isCheckedPass := 1
isCheckedSimulationRoom := 1
isCheckedRookieArena := 1
isCheckedLoveTalking := 1
isCheckedCompanyWeapon := 0
isCheckedInterception := 0
isCheckedCompanyTower := 1
isCheckedTribeTower := 0
isCheckedLongTalk := 1
isCheckedAutoCheckUpdate := 0
isCheckedBook := [0, 0, 0, 0, 0]
InterceptionBoss := 1
numOfBook := 3
numOfBattle := 5
numOfLoveTalking := 10
isBoughtTrash := 1


if !A_IsAdmin {
    MsgBox "请以管理员身份运行Doro"
    ExitApp
}

;读取设置
SetWorkingDir A_ScriptDir
try {
    LoadSettings()
}
catch as err {
    WriteSettings()
}


if isCheckedAutoCheckUpdate {
    CheckForUpdate()
}

;创建gui
doroGui := Gui(, "Doro小帮手" currentVersion)
doroGui.Opt("+Resize")
doroGui.MarginY := Round(doroGui.MarginY * 0.9)
doroGui.SetFont("cred s12")
doroGui.Add("Text", "R1", "紧急停止按ctrl + z 暂停按ctrl + x")
doroGui.Add("Link", " R1", '<a href="https://github.com/kevinboy666/DoroHelperLegacy">项目地址</a>')
doroGui.SetFont()
doroGui.Add("Button", "R1 x+10", "帮助").OnEvent("Click", ClickOnHelp)
doroGui.Add("Button", "R1 x+10", "检查更新").OnEvent("Click", ClickOnCheckForUpdate)
Tab := doroGui.Add("Tab3", "xm") ;由于autohotkey有bug只能这样写
Tab.Add(["doro设置", "收获", "商店", "日常", "默认"])
Tab.UseTab("doro设置")
doroGui.Add("Checkbox", IsCheckedToString(isCheckedAutoCheckUpdate) " R2", "自动检查更新(确保能连上github)").OnEvent("Click",
    ClickAutoCheckUpdate)
doroGui.Add("Text", , "点击间隔(单位毫秒)，谨慎更改")
doroGui.Add("DropDownList", "Choose" SleepTimeToLabel(sleepTime), [750, 1000, 1250, 1500, 1750, 2000]).OnEvent("Change",
    ChangeOnSleepTime)
doroGui.Add("Text", , "色差容忍度，能跑就别改")
doroGui.Add("DropDownList", "Choose" ColorToleranceToLabel(colorTolerance), ["严格", "宽松"]).OnEvent("Change",
    ChangeOnColorTolerance)
doroGui.Add("Button", "R1", "保存当前设置").OnEvent("Click", SaveSettings)
Tab.UseTab("收获")
doroGui.Add("Checkbox", IsCheckedToString(isCheckedOutposeDefence) " R1.2", "领取前哨基地防御奖励+1次免费歼灭").OnEvent("Click",
    ClickOnOutpostDefence)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedCashShop) " R1.2", "领取付费商店免费钻(进不了商店的别选)").OnEvent("Click",
    ClickOnCashShop)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedExpedtion) " R1.2", "派遣委托").OnEvent("Click", ClickOnExpedition)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedFriendPoint) " R1.2", "好友点数收取").OnEvent("Click", ClickOnFriendPoint)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedMail) " R1.2", "邮箱收取").OnEvent("Click", ClickOnMail)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedMission) " R1.2", "任务收取").OnEvent("Click", ClickOnMission)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedPass) " R1.2", "通行证收取").OnEvent("Click", ClickOnPass)
Tab.UseTab("商店")
doroGui.Add("Text", "R1.2 Section", "普通商店")
doroGui.Add("Checkbox", IsCheckedToString(isCheckedFreeShop) " R1.2 xs+15 ", "每日白嫖2次").OnEvent("Click", ClickOnFreeShop
)
doroGui.Add("CheckBox", " R1.2 xs+15", "购买简介个性化礼包")
doroGui.Add("Text", "R1.2 xs", "竞技场商店")
doroGui.Add("Text", "R1.2 xs+15", "购买手册：")
doroGui.Add("Checkbox", IsCheckedToString(isCheckedBook[1]) " R1.2 xs+15", "燃烧").OnEvent("Click", ClickOnFireBook)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedBook[2]) " R1.2 X+1", "水冷").OnEvent("Click", ClickOnWaterBook)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedBook[3]) " R1.2 X+1", "风压").OnEvent("Click", ClickOnWindBook)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedBook[4]) " R1.2 X+1", "电击").OnEvent("Click", ClickOnElecBook)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedBook[5]) " R1.2 X+1", "铁甲").OnEvent("Click", ClickOnIronBook)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedCompanyWeapon) " R1.2 xs+15", "购买公司武器熔炉").OnEvent("Click",
    ClickOnCompanyWeapon)
doroGui.Add("CheckBox", " R1.2", "购买简介个性化礼包")
doroGui.Add("Text", "R1.2 xs Section", "废铁商店（简介个性化礼包和废铁商店还在做）")
doroGui.Add("Checkbox", " R1.2 xs+15", "购买珠宝")
doroGui.Add("Text", " R1.2 xs+15", "购买好感券：")
doroGui.Add("Checkbox", " R1.2 xs+15", "通用")
doroGui.Add("Checkbox", " R1.2 x+1", "朝圣者")
doroGui.Add("Checkbox", " R1.2 x+1", "反常")
doroGui.Add("Checkbox", " R1.2 xs+15", "极乐净土")
doroGui.Add("Checkbox", " R1.2 x+1", "米西利斯")
doroGui.Add("Checkbox", " R1.2 x+1", "泰特拉")
doroGui.Add("Text", " R1.2 xs+15", "购买资源")
doroGui.Add("Checkbox", " R1.2 xs+15", "信用点+盒")
doroGui.Add("Checkbox", " R1.2 x+1", "战斗数据辑盒")
doroGui.Add("Checkbox", " R1.2 x+1", "芯尘盒")
Tab.UseTab("日常")
doroGui.Add("Checkbox", IsCheckedToString(isCheckedSimulationRoom) " R1.2", "模拟室5C(普通关卡需要快速战斗)").OnEvent("Click",
    ClickOnSimulationRoom)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedRookieArena) " R1.2", "新人竞技场(请点开快速战斗)").OnEvent("Click",
    ClickOnRookieArena)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedLoveTalking) " " " R1.2 Section", "咨询妮姬(可以通过收藏改变妮姬排序)").OnEvent(
    "Click", ClickOnLoveTalking)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedLongTalk) " R1.2 XP+15 Y+M", "若图鉴未满，则进行详细咨询").OnEvent("Click",
    ClickOnLongTalk)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedCompanyTower) " R1.2 xs Section", "爬企业塔").OnEvent("Click",
    ClickOnCompanyTower)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedTribeTower) " R1.2 XP+15 Y+M", "只完成每日任务，在进入后退出").OnEvent("Click",
    ClickOnTribeTower)
doroGui.Add("Checkbox", IsCheckedToString(isCheckedInterception) " R1.2 xs", "使用对应编队进行异常拦截自动战斗").OnEvent("Click",
    ClickOnInterception)
doroGui.Add("DropDownList", "Choose" InterceptionBossToLabel(InterceptionBoss), ["克拉肯(石)，编队1", "过激派(头)，编队2",
    "镜像容器(手)，编队3", "茵迪维利亚(衣)，编队4", "死神(脚)，编队5"]).OnEvent("Change", ChangeOnInterceptionBoss)
Tab.UseTab("默认")
doroGui.Add("Text", , "购买几本代码手册？")
doroGui.Add("DropDownList", "Choose" NumOfBookToLabel(numOfBook), [0, 1, 2, 3]).OnEvent("Change", ChangeOnNumOfBook)
doroGui.Add("Text", , "新人竞技场打几次？")
doroGui.Add("DropDownList", "Choose" NumOfBattleToLabel(numOfBattle), [2, 3, 4, 5]).OnEvent("Change",
    ChangeOnNumOfBattle)
doroGui.Add("Text", , "咨询几位妮姬？")
doroGui.Add("DropDownList", "Choose" NumOfLoveTalkingToLabel(numOfLoveTalking), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).OnEvent(
    "Change", ChangeOnNumOfLoveTalking)
Tab.UseTab()
doroGui.Add("Button", "Default w80 xm+100", "DORO!").OnEvent("Click", ClickOnDoro)
doroGui.Show()

^z:: {
    ExitApp
}

^x:: {
    Pause -1
}
