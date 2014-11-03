#/usr/bin/env python

import os,sys
import xml.dom.minidom
from xml.dom.minidom import Document

def GenerateXml(caseDir,fileName):#fileName is xmlname
    impl = xml.dom.minidom.getDOMImplementation()
    dom  = impl.createDocument(None,'TestCases',None)
    root = dom.documentElement
    folders = os.listdir(caseDir)
    for i in folders:
        case = dom.createElement('case')
        casename = dom.createTextNode(i)
        case.appendChild(casename)
        root.appendChild(case)

    f = open('%s.xml'%fileName,'w')
    dom.writexml(f,addindent=' ',newl='\n',encoding='utf-8')
    f.close()

GenerateXml(sys.argv[1],sys.argv[2])

