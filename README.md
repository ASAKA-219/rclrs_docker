#  Docker container for ROS 2 humble Hawkisible
皆さんご存知のROS 2 humble環境をDockerコンテナで持ち運べるリポジトリになります。提供パッケージ(tb3_vision)はOpenCVを使って遊べます。
### セットアップ
- docker
- docker-compose
- 画像ファイルをコンテナにマウントする

### 画像のマウント方法
1. 画像ファイルを入れた `image` ディレクトリをこのディレクトリ直下に用意する。
2. docker-compose.yamlを編集し、`volumes`タグの中にディレクトリを追加する。
   ```yaml
   volumes:
     - ./image:/home/${USER_NAME}/image
   ```

## コンテナ起動方法
シェルスクリプトから起動できます。
```bash
./entry_exec.sh
```
Nvidia製GPUドライバー付きのパソコンの場合は、-gpuオプションを付けてください。
```bash
./entry_exec.sh -gpu
```
そこで試しに
```bash
ros2 run tb3_vision smile_cascade_node
```
とすると、写真が表示されます。（写真ファイルをコンテナにマウントさせると可）
> 4月14日更新
