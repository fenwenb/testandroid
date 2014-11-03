#!/usr/bin/env python

import os，time,traceback
import csv
from xml.etree import ElementTree

def add_csv_result(FileName,CaseName,CaseResult):
	f=csv.writer(file(FileName,'ab'))
	f.writerow([CaseName,CaseResult])
	#f.close()

//生成结果目录
case = []
start_time = time.strtime('%Y%m%d_%H%M%S',time.localtime(time.time()))
result_dir = "./Result"+start_time

//解析xml中的testcase
tcRoot = ElementTree("./testCases.xml")
cn = tcRoot.findall("case")
for i in cn:
	cases.append(i.text)
caseList = list(set(cases))
caseList.sort(key=cases.index)
title = ['CaseNames','Verify_result']
csv_results = open(result_dir+"/"+result_dir+".csv","wb")
f_csv = csv.writer(csv_results)
f_csv.writerow(title)
#f_csv.close()

for caseName in caseList:
	case_result_dir = result_dir+"/"+caseName
	os.popen("mkdir -p %s"%(case_result_dir))
	try:
		os.sys.path.append("TestCases/MRD8/")
		a = __import__('%s.case' %caseName)//导入caseName中模块
		reload(a.case)
	except ImportError, e:
		print "can't find case:", caseName
		continue
	f = open(case_result_dir+"/"+caseName+".txt","aw")
	try:
		result = a.case.exe()
		print result
		if type(result) ==str:
			add_csv_result(result_dir+"/"+result_dir+".csv",caseName,result)
			f.write(result+"\n")
			f.flush()
	except Exception, e:
		print Exception, ':',e
		traceback.print_exc(file=f)
		f.flush()
		f.close()	
	else:
		f.write("No exception Raise\n")
		f.flush()
		f.close()
	finally:
		f.close()
//导出log文件
os.popen("adb pull /mnt/sdcard/log %s/logs_adb"%(result_dir))
os.popen("adb pull /logs %s/crashLogs"%(result_dir))

