Task2 的任務主要目標是讓學員知道 EFK logs 沒有正常被傳輸時，應該如何 debug，這篇我們埋了兩個階段的錯誤，第一個是 filter 抓錯。Filter 是將 input 進來的 logs 再進行篩選的一層 layer，正常來說，我們應該要從 input 觀察 logs 正確是長怎樣，然後再進行 filter，只是如果你是經手專案，很容易就將config直接複製貼上(正如我們第一題的狀況一樣)。為了確認 input - filter - output 是否有正常運行，我們可以借用官網的 local output 的方式，確認在排除因為output連線、驗證等問題的狀況外，logs 是否有正常產出。第二個難題是儘管 output 有正確出來，但卻傳不到 elasticSearch，當我們遇到類似問題，最好的方式就是找出 logs，但預設的 logs 沒能提供足夠的資訊給我們。所以我們要善用官方提供的 trace error 參數。

1. 使用 'kubectl -n kube-system port-forward <pod name> 8080:5601' 進行對外曝光連線
2. 在瀏覽器打開 'https://localhost:8080/'，並從 Makefile 內找到 password vmVhOB4Pn0wRvQO6xEgj 進行登入。
3. 可以看到畫面提到你可以將 data 送進來。這代表 data 沒有成功送到 elastic Search
4. 為了找出原因，我們將 output 先改成傳到 local tmp folder 下[https://docs.fluentbit.io/manual/pipeline/outputs/file]
```
 [OUTPUT]
      Name file
      Match *
      Path tmp   
```
5. 確認並沒有傳到，我們改成將 filter 拔掉，看看是哪一段出問題，發現 filter 拔掉 logs 就出來了
6. 使用指令進入 fluent bit container 內，我們發現 logs 的 key 不是 message，而是 log
```
k exec -it <fluent bit logs> -n kube-system bash
cd tmp
ls
```
7. 將 filter 改成 log
```
[FILTER]
    Name grep
    Match kube.*
    Regex log 404
```
8. logs 成功傳送到 container 內，但 ElasticSearch 還是沒收到，查看logs發現
```
[2024/04/17 23:44:00] [ warn] [engine] failed to flush chunk '1-1713397401.47804154.flb', retry in 17 seconds: task_id=2, input=tail.0 > output=es.1 (out_id=1)
```
9. 但這個 logs 無法幫忙找到 root cause，所以我們必須新增 trace_error[https://docs.fluentbit.io/manual/v/dev-2.2/pipeline/outputs/elasticsearch]
```
Trace_Error On
```
10. 發現問題在 index 有異常變數，導致空值，間接導致開頭是 '-'，不符合設定
```
{"took":0,"errors":true,"items":[{"create":{"_index":"-application-logs-2024.16","_type":"_doc","_id":null,"status":400,"error":{"type":"invalid_index_name_exception","reason":"Invalid index name [-application-logs-2024.16], must not start with '_', '-', or '+'","index_uuid":"_na_","index":"-application-logs-2024.16"}}},{"create":{"_index":"-application-logs-2024.16","_type":"_doc","_id":null,"status":400,"error":{"type":"invalid_index_name_exception","reason":"Invalid index name [-application-logs-2024.16], must not start with '_', '-', or '+'","index_uuid":"_na_","index":"-application-logs-2024.16"}}},{"create":{"_index":"-application-logs-2024.16","_type":"_doc","_id":null,"status":400,"error":{"type":"invalid_index_name_exception","reason":"Invalid index name [-application-logs-2024.16], must not start with '_', '-', or '+'","index_uuid":"_na_","index":"-application-logs-2024.16"}}},{"create":{"_index":"-application-logs-2024.16","_type":"_doc","_id":null,"status":400,"error":{"type":"invalid_index_name_exception","reason":"Invalid index name [-application-logs-2024.16], must not start with '_', '-', or '+'","index_uuid":"_na_","index":"-application-logs-2024.16"}}}]}
```
11. 將變數移除，即可收到正確資訊