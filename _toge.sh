#!/bin/bash

# togelack投げる君
# 入れるメッセージ、入れないメッセージの取捨選択は大変なので
# 一気に全部入りで投稿してしまい、必要ない分だけを編集で取り除くスタイル

# chrome dev toolsのnetworkタブからコピペ
session=""
csrf=""

# your togelack host
toge_host="https://example-togelack.herokuapp.com"

title=""
description=""

# 1000msg/まとめ 30msg/urlなので33個くらいが限度
urls=(
 "https://example.slack.com/archives/demo/p1111111111111111"
)

if [ "$1" == "-h" ]; then
  echo "with no option: dry run"
  echo "--post: execute post"
  echo "-h: help"
fi

for url in "${urls[@]}"; do
  msgs=$(curl -s "${toge_host}/api/histories.json?url=$url" -H "Cookie: _togelack_session=$session" | jq -r '.result')
  echo "$(echo $msgs | sed 's/\\n//g' | jq -r '. | map(.text)[] | .[0:80]')"
  msg_ids=$(echo "$msg_ids" $(echo $msgs | jq -r '. | map(.id)[]'))
done
msg_array=($msg_ids)
echo "メッセージ件数: ${#msg_array[@]}/1000"
joined_ids=$(for id in $msg_ids; do printf "&messages[]=%s" "$id"; done)

if [ "$1" == "--post" ]; then
  curl  -s "${toge_host}/summaries.json" -H "X-CSRF-Token: $csrf" -H "Cookie: _togelack_session=$session" --data "title=$title&description=$description$joined_ids"
fi

