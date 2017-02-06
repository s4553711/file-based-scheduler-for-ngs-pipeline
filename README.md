### usage
```bash
# giving nodes config for job dispatch
$ cat nodes.config 
node1
node2
node3
node4
node5

# process each job by chromosome region
$ cat list
1:1-10000
1:10000-20000
2:1-10000
2:10000-20000
3:1-10000
3:10000-20000
4:10000-20000
5:10000-20000
6:10000-20000
7:10000-20000

# submit job
$ ./queue.sh list
```
