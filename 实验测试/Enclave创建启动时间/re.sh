file="/nfs/home/yangjinyu/Workspaces20240103/PENGLAI-ZGC-TEE/riscv-rootfs/apps/penglai-sdk/repo/demo/host/res copy 2.txt"
# 查找Enclave启动时间所在行
grep -o '.*\[\s*\([0-9]\+\.[0-9]\+\)\].*order:9' "$file" >> t1.txt
# 提取启动时间
sed -n 's/.*\[\s*\([0-9]\+\.[0-9]\+\)\].*order:9/\1/p' "$file" >> t2.txt

grep -o '.*\[\s*\([0-9]\+\.[0-9]\+\)\].*[Penglai Driver@penglai_enclave_run].*begin' "$file" >> t3.txt

sed -n 's/.*\[\s*\([0-9]\+\.[0-9]\+\)\].*[Penglai Driver@penglai_enclave_run].*begin/\1/p' "$file" >> t4.txt

grep -o '.*\[\s*\([0-9]\+\.[0-9]\+\)\].*run.*returned.*successfully' "$file" >> t5.txt

sed -n 's/.*\[\s*\([0-9]\+\.[0-9]\+\)\].*run.*returned.*successfully/\1/p' "$file" >> t6.txt


sed -n 's/.*\[\s*\([0-9]\+\.[0-9]\+\)\].*/\1/p' "$file"
sed -n 's/.*\[\s*\([0-9]\+\.[0-9]\+\)\].*order:9/\1/p' "$file"
grep -0 '.*\[\s*\([0-9]\+\.[0-9]\+\)\].*order:9' "$file"


grep -o '\[Penglai Driver@create_enclave\] total_pages:[0-9]\+ order:[0-9]\+' "$file"