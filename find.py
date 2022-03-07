#coding=gbk

import sys
import os
import argparse
import re

argpCmd = argparse.ArgumentParser(description = "查找指定目录中的所有文件")
argpCmd.add_argument("-m", dest = "mode", default = "*", choices = "df*", help = "匹配模式，*(默认)：匹配所有 d：只匹配路径 f：只匹配文件")

argpCmd.add_argument("-e", dest = "pattern", default = None, help = "与文件名匹配的模式定义，只有符合条件的文件才会返回")
argpCmd.add_argument("-i", dest = "ignore", action = "store_true", help = "设置后，在匹配文件时，将忽略大小写的差异")
argpCmd.add_argument("-v", dest = "reverse", action = "store_true", help = "反向匹配，设置后，只有不满足模式的文件才会返回")

argpCmd.add_argument("directory", help = "待查找的路径名")
args = argpCmd.parse_args()

if not os.path.exists(args.directory):
	sys.stderr.write("Error(101): 无效的查询路径(%s)\n" % (args.directory))
	sys.exit(-1)

lstFile = os.walk(args.directory)
for (strPath, lstDir, lstName) in lstFile:
    if re.match(r"[dD*]", args.mode):
        for strDir in lstDir:
            strFullName = "%s\\%s" % (strPath, strDir)
            if not args.pattern:
                print(strFullName)
            else:
                objMatch = re.search(args.pattern, strFullName, re.I if args.ignore else 0)
                if objMatch and not args.reverse:
                    print(strFullName)
                elif not objMatch and args.reverse:
                    print(strFullName)

    if re.match(r"[fF*]", args.mode):
        for strName in lstName:
            strFullName = "%s\\%s" % (strPath, strName)
            if not args.pattern:
                print(strFullName)
            else:
                objMatch = re.search(args.pattern, strFullName, re.I if args.ignore else 0)
                if objMatch and not args.reverse:
                    print(strFullName)
                elif not objMatch and args.reverse:
                    print(strFullName)
