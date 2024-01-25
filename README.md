# iKingdom

2019.11.30 Start a project


###「Command PhaseScriptExecution failed with a nonzero exit code」というエラーが発生した場合
解決方法
次のファイルの１行を修正するだけです。
Pods > Targets Support Files > Pods-[プロジェクト名] > Pods-[プロジェクト名]-frameworks.sh
上記のファイルの 42〜45行目 を次のように修正すればOKです。

```
  if [ -L "${source}" ]; then
    echo "Symlinked..."
    # source="$(readlink "${source}")"   ←コメントアウト
    source="$(readlink -f "${source}")"  ←追加
  fi
```
