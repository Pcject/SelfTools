# 查找包含指定文本的文件 -r 或者 -r 是递归的，-n 是行号，-w 代表整个单词。 -l ( 字母L ) 可以添加到只有文件名。
grep  --include=*.{c,h} --exclude-dir={dir1,dir2,*.dst} -rnw 'directory' -e"pattern"