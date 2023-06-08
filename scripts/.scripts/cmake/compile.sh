#!/bin/bash

myecho() {
  echo -e "\033[34m$1\033[0m"
}

myecho "============================================="
myecho "-- COMPILE INFO --"
myecho "Current Path : $(pwd)"
myecho "Compile Time : $(date)"
myecho "============================================="

# 判断当前目录是否存在CMakeLists.txt文件
if [ ! -f "CMakeLists.txt" ]; then
  echo -e "\033[31m[ ERROR ] : There is no CMakeLists.txt file in current directory\033[0m"
  exit 1
fi

# 判断是否存在build目录，如果不存在就创建
if [ ! -d "build" ]; then
  if ! mkdir build; then
    echo -e '\033[31m[ ERROR ] : Failed Run "mkdir build"\033[0m'
    exit 1
  fi
  myecho ""
  myecho "============================================="
  myecho "mkdir build"
  myecho "============================================="
fi

# 进入build目录
myecho ""
myecho "============================================="
myecho "cd build"
myecho "============================================="
if ! cd build; then
  echo -e '\033[31m[ ERROR ] : Failed Run "cd build"\033[0m'
  exit 1
fi


# 执行cmake ..
ExecCmake() {
  myecho ""
  myecho "============================================="
  myecho "cmake .."
  myecho "============================================="
  if ! cmake ..; then
    echo -e '\033[31m[ ERROR ] : Failed Run "cmake .."\033[0m'
    exit 1
  fi
}

# 执行build
ExecBuild() {
  myecho ""
  myecho "============================================="
  myecho "make"
  myecho "============================================="
  if ! make; then
    echo -e '\033[31m[ ERROR ] : Failed Run "make"\033[0m'
    exit 1
  fi
}

# 递归查找文件并执行
find_file() {
  local path="$1"
  local file="$2"
  for entry in "$path"/*; do
    if [[ -f "$entry" && "$(basename "$entry")" == "$file" ]]; then
      # echo "找到文件: $entry"
      myecho ""
      myecho ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      myecho "Exec File Name : \033[33m$file"
      myecho "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      "$entry" # exec file
      return 0
    elif [[ -d "$entry" ]]; then
      if find_file "$entry" "$file"; then
        return 0
      fi
    fi
  done
  return 1
}

ExecFile() {
  if [[ -z "$1" ]]; then
    for file in *; do
        if [[ -x $file && ! -d $file ]]; then
            myecho ""
            myecho ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            myecho "Exec File Name : \033[33m$file"
            myecho "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            ./$file
            # break # 看需求是否需要遍历所有可执行文件
        fi
    done
  else
    # 在当前目录下递归查找文件
    if find_file "$(pwd)" "$1"; then
      # echo "存在"
      :
    else
      # echo "不存在"
      myecho ""
      myecho ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      echo -e "\033[31m[ ERROR ] : $1 not exist\033[0m"
      myecho "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    fi
  fi
}

# cmake+build+run
cbr() {
  ExecCmake
  ExecBuild
  ExecFile "$1"
}

# build+run
br() {
  ExecBuild
  ExecFile "$1"
}

if [[ "$1" == "cbr" ]]; then
  cbr "$2"
elif [[ "$1" == "br" ]]; then
  br "$2"
else 
  cbr
fi

