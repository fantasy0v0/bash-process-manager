#!/bin/bash

dir=$(pwd)

# 读取保存的pid
getPid() {
  getPid_result=$(cat $dir"/application.pid")
}

# 启动程序
start() {
  # 判断进程是否仍在运行
  if [ -f $dir"/application.pid" ]; then
    getPid
    # 如果pid有值, 且进程仍然存在, 需要立即退出并告知使用者
    if [ -n "$getPid_result" ]; then
      r=$(ps --no-heading --pid $getPid_result | wc -l)
      if [ $r -ne 0 ]; then
        echo "application is running."
        exit 1
      fi
    fi
  fi

  # 启动程序, 并放置在后台
  nohup $1 >> $dir"/application.out" 2>&1 &
  # 将新的进程号写入到文件中
  echo $! > $dir"/application.pid"
  echo "application started."
}

# 停止程序
stop() {
  getPid
  kill $getPid_result
  echo "waiting for application to exit."
  while [ -e "/proc/$getPid_result" ]
  do 
    sleep 1;
  done
  echo "application exited."
}

# 程序状态
status() {
  getPid
  ps --pid $getPid_result
}

# 判断启动配置文件是否存在
if [ ! -f $dir"/command" ]; then
  echo "File 'command' not found."
  exit 2
fi

# 获取启动命令
command=$(cat $dir"/command")
# 判断启动配置文件内容是否为空
if [ ! -n "$command" ]; then
  echo "File 'command' is empty."
  exit 3
fi

action=$1
case $action in
  start)
    start "$command"
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  *)
    echo "Unknow action: "$action"."
    ;;
esac

