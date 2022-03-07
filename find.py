#coding=gbk

import sys
import os
import argparse
import re

argpCmd = argparse.ArgumentParser(description = "����ָ��Ŀ¼�е������ļ�")
argpCmd.add_argument("-m", dest = "mode", default = "*", choices = "df*", help = "ƥ��ģʽ��*(Ĭ��)��ƥ������ d��ֻƥ��·�� f��ֻƥ���ļ�")

argpCmd.add_argument("-e", dest = "pattern", default = None, help = "���ļ���ƥ���ģʽ���壬ֻ�з����������ļ��Ż᷵��")
argpCmd.add_argument("-i", dest = "ignore", action = "store_true", help = "���ú���ƥ���ļ�ʱ�������Դ�Сд�Ĳ���")
argpCmd.add_argument("-v", dest = "reverse", action = "store_true", help = "����ƥ�䣬���ú�ֻ�в�����ģʽ���ļ��Ż᷵��")

argpCmd.add_argument("directory", help = "�����ҵ�·����")
args = argpCmd.parse_args()

if not os.path.exists(args.directory):
	sys.stderr.write("Error(101): ��Ч�Ĳ�ѯ·��(%s)\n" % (args.directory))
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
