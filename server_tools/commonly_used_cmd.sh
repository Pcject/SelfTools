# 查找包含指定文本的文件 -r 或者 -r 是递归的，-n 是行号，-w 代表整个单词。 -l ( 字母L ) 可以添加到只有文件名。
grep  --include=*.{c,h} --exclude-dir={dir1,dir2,*.dst} -rnw 'directory' -e"pattern"

linux下获取占用CPU资源最多的10个进程，可以使用如下命令组合：
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head


linux下获取占用内存资源最多的10个进程，可以使用如下命令组合：
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +4|head

# 删docker的日志
for log in `ls /var/lib/docker/containers/*/*-json.log`;do;echo '' > $log;done