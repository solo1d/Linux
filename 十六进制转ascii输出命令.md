```bash
cat 文件 | perl -ne 's/([0-9a-f]{2})/print chr hex $1/gie' && echo ''
```