## dba_utils/mariadb/partition
### 01-partition_isfull_monitoring.sh
* **목적** : MAX도달 파티셔닝 테이블 찾기
* **구현**
1. MAXVAL과 가까운 3개 파티션 테이블에 데이터가 들어있는지 확인
2. 공백을 COMMA로 바꿔 csv로 활용(telegraf 등 모니터링 활용)

### 02-last_partition_drop.sh
* **목적** : 가장 오래된 LAST PARTITION DROP
* **구현**
1. 모든 테이블 중 PARTITION_ORDINAL_POSITION=1 인 파티션 DROP
2. 월 수행 CRONTAB 등록
3. 결과를 슬랙 등 메신저로 전송

* **주의사항**

모든 PARTITION_ORDINAL_POSITION=1 인 파티션을 DROP 하므로, 환경에 따라 커스텀하여 사용
