# pihidproxy

Bluetooth キーボードを USB キーボードとして PC に認識させるブリッジです。

![概要図](https://i.imgur.com/cpGkjXw.png)

## これは何をするもの？

Bluetooth キーボードは、PC の BIOS やブートローダーでは使えません（Bluetooth スタックが動いていないため）。

pihidproxy は Raspberry Pi Zero を仲介役にして、Bluetooth キーボードの入力を USB キーボードとして PC に転送します。PC 側からは「普通の USB キーボードが刺さっている」ように見えます。

```
[Bluetooth キーボード] --BT--> [Raspberry Pi Zero] --USB--> [PC]
```

## 必要なもの

- Raspberry Pi Zero / Zero W / Zero 2W（USB OTG 対応機種）
- Bluetooth キーボード
- microSD カード（Raspberry Pi OS インストール済み）
- USB ケーブル（Pi の「USB」ポートと PC を接続）

> **注意:** Pi Zero には USB ポートが 2 つあります。「PWR IN」ではなく「USB」と書かれた方を PC に接続してください。

## セットアップ手順

### 1. Raspberry Pi OS のインストール

Raspberry Pi Imager で microSD カードに Raspberry Pi OS Lite をインストールします。
SSH を有効にしておくと、後の作業が楽になります。

### 2. このリポジトリをクローン

Pi にログインして、以下を実行します。

```bash
git clone https://github.com/amber-color/pihidproxy.git
cd pihidproxy
```

### 3. USB OTG（USB ガジェット機能）を有効化

Pi を USB キーボードとして動作させるために必要な設定です。

```bash
# Raspberry Pi OS Bookworm（最新版）の場合
echo "dtoverlay=dwc2" | sudo tee -a /boot/firmware/config.txt

# Bullseye 以前の場合はこちら
# echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt

echo "dwc2" | sudo tee -a /etc/modules
echo "libcomposite" | sudo tee -a /etc/modules
```

どちらのバージョンか分からない場合：

```bash
cat /etc/os-release | grep VERSION_CODENAME
```

### 4. Python ライブラリのインストール

```bash
sudo apt update
sudo apt install python3-evdev
```

### 5. Bluetooth キーボードとペアリング（初回のみ）

キーボードをペアリングモードにしてから、以下を実行します。

```bash
sudo bash pair.sh
```

画面に 6 桁の数字（パスキー）が表示されたら、**その数字をキーボードで入力** して Enter を押してください。

```
[agent] Passkey: 381949   ← この数字をキーボードで入力
```

`Connection successful` と表示されればペアリング完了です。次回以降は自動接続されます。

### 6. 自動起動の設定

PC に USB を挿したときに自動で起動するように設定します。
**pihidproxy のディレクトリ内で** 以下を実行してください。

```bash
sed "s|REPODIR|$(pwd)|" pihidproxy.service | sudo tee /etc/systemd/system/pihidproxy.service
sudo systemctl daemon-reload
sudo systemctl enable pihidproxy.service
```

### 7. 再起動

```bash
sudo reboot
```

以上で設定完了です。

## 使い方

1. Pi の「USB」ポートと PC を USB ケーブルで接続します
2. Pi が起動すると、自動的に HHKB と接続し、PC に USB キーボードとして認識されます
3. Bluetooth キーボードで入力すると、そのまま PC に届きます

## 動作確認

サービスの状態を確認するには：

```bash
sudo systemctl status pihidproxy.service
```

ログをリアルタイムで見るには：

```bash
sudo journalctl -fu pihidproxy.service
```

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `pair.sh` | Bluetooth キーボードに接続するスクリプト |
| `setuphid.sh` | Pi を USB キーボードとして設定するスクリプト |
| `keys.py` | キーボード入力を USB に転送するメインプログラム |
| `pihidproxy.service` | 自動起動用の systemd サービス定義ファイル |

## トラブルシューティング

**キーボードが認識されない場合**

```bash
# USB ガジェットが作成されているか確認
ls /dev/hidg0

# Bluetooth 接続状態を確認
bluetoothctl info <MACアドレス>
```

**再ペアリングが必要な場合**

```bash
sudo bash pair.sh
```

**サービスを手動で再起動する場合**

```bash
sudo systemctl restart pihidproxy.service
```
