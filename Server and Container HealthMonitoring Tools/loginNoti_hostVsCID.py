#!/usr/bin/python2
import os
import sys
from collections import OrderedDict
import pprint

pp = pprint.PrettyPrinter(indent=4)

# The description section
__author__ = "Jahidul Arafat, DevOps Engineer, Harris Web Works, USA"
__copyright__ = "Copyright 2020, The HWW Security Project"
__credits__ = ["Enamul Miraj","Matt Harris"]
__license__ = "GPL"
__version__ = "1.0.1"
__maintainer__ = "Jahidul Arafat"
__email__ = "jarafat@harriswebworks.com"
__status__ = "Development"

def hackTheIPInformation(ip):
    infoString=""
    infoDict={}
    whoisCmd="whois {}|grep -i 'netname\|descr\|country\|address\|email\|org_name\|phone\|geoloc\|sort -u'".format(ip)
    output=os.popen(whoisCmd).read().split("\n")
    
    for item in output:
        l=item.split(':')
        if not l[0]=="":
            infoDict[l[0].strip()]=l[1].strip()
    
    for k,v in infoDict.items():
        infoString+="{}:{}\n".format(k,v)
    pp.pprint(infoDict)
    #exit(infoString)
    
def hostVsContainerID(searchKey):
    
    #00
    commonDict=OrderedDict([
        ("aws","Corporate_Magento_S1"),
        ("az","us-east-1a")
    ])
    
    #01
    dartermall=OrderedDict([
        ("hostname","dartermall.harriswebworks.com"),
        ("cid",113),
        ("os","centos-7"),
        ("ip_private","172.31.0.168"),
        ("ip_public","18.214.175.251")
    ])
    
    #02
    noggins=OrderedDict([
        ("hostname","4noggins.harriswebworks.com"),
        ("cid",114),
        ("os","centos-7"),
        ("ip_private","172.31.10.103"),
        ("ip_public","34.197.203.195")
    ])
    
    #03
    rubitrux=OrderedDict([
        ("hostname", "rubitrux.harriswebworks.com"),
        ("cid",115),
        ("os","centos-7"),
        ("ip_private","172.31.5.31"),
        ("ip_public","34.233.82.242")
    ])
    
    #04
    rubitruxnginx=OrderedDict([
        ("hostname", "rubitruxnginx.harriswebworks.com"),
        ("cid",116),
        ("os","centos-7"),
        ("ip_private","172.31.0.31"),
        ("ip_public","54.208.150.157")
    ])
    
    #05
    zabeldev=OrderedDict([
        ("hostname", "zabeldev.harriswebworks.com"),
        ("cid",117),
        ("os","centos-7"),
        ("ip_private","172.31.9.139"),
        ("ip_public","54.209.47.11")
    ])
    
    #06
    devaccustandard=OrderedDict([
        ("hostname", "devaccustandard.harriswebworks.com"),
        ("cid",118),
        ("os","centos-7"),
        ("ip_private","172.31.5.38"),
        ("ip_public","34.232.132.160")
     ])
    
    #07
    brokenarrow=OrderedDict([
        ("hostname", "devaccustandard.harriswebworks.com"),
        ("cid",119),
        ("os","centos-7"),
        ("ip_private","172.31.6.222"),
        ("ip_public","18.205.55.175")
    ])
    
    #08
    florabella=OrderedDict([
        ("hostname", "florabella.harriswebworks.com"),
        ("cid",120),
        ("os","centos-7"),
        ("ip_private","172.31.7.101"),
        ("ip_public","3.219.191.74")
    ])
    
    #09
    brokenarrow=OrderedDict([
        ("hostname", "brokenarrow.harriswebworks.com"),
        ("cid",143),
        ("os","centos-7"),
        ("ip_private","172.31.9.126"),
        ("ip_public","34.224.197.49")
    ])
    
    #10
    edcosource=OrderedDict([
        ("hostname", "edcosource.harriswebworks.com"),
        ("cid",144),
        ("os","centos-7"),
        ("ip_private","172.31.9.62"),
        ("ip_public","35.172.48.218")
     ])
    
    #11
    provence=OrderedDict([
        ("hostname", "provence.harriswebworks.com"),
        ("cid",145),
        ("os","centos-7"),
        ("ip_private","172.31.8.151"),
        ("ip_public","34.192.41.182")
    ])
    
    #12
    thesolarbiz=OrderedDict([
        ("hostname", "thesolarbiz.harriswebworks.com"),
        ("cid",146),
        ("os","centos-7"),
        ("ip_private","172.31.7.20"),
        ("ip_public","34.201.74.81")
    ])
    
    #13
    drainage=OrderedDict([
        ("hostname", "drainage.harriswebworks.com"),
        ("cid",149),
        ("os","centos-7"),
        ("ip_private","172.31.11.241"),
        ("ip_public","35.170.157.164")
    ])
    
    #14
    zabelenvironmental=OrderedDict([
        ("hostname", "zabelenvironmental.harriswebworks.com"),
        ("cid",154),
        ("os","centos-7"),
        ("ip_private","172.31.12.111"),
        ("ip_public","18.211.241.13")
     ])
    
    #15
    halbrowncompany=OrderedDict([
        ("hostname", "halbrowncompany.harriswebworks.com"),
        ("cid",156),
        ("os","centos-7"),
        ("ip_private","172.31.6.15"),
        ("ip_public","54.157.38.212")
    ])
    
    #16
    thecnstore=OrderedDict([
        ("hostname", "thecnstore.harriswebworks.com"),
        ("cid",159),
        ("os","centos-7"),
        ("ip_private","172.31.9.141"),
        ("ip_public","35.170.24.251")
    ])
    
    #17
    cndev=OrderedDict([
        ("hostname", "cndev.harriswebworks.com"),
        ("cid",161),
        ("os","centos-7"),
        ("ip_private","172.31.2.44"),
        ("ip_public","34.200.161.29")
     ])
    
    #18
    m2testbox=OrderedDict([
        ("hostname", "m2testbox.harriswebworks.com"),
        ("cid",777),
        ("os","centos-7"),
        ("ip_private","172.31.11.139"),
        ("ip_public","18.214.189.236")
    ])
    
    allHostCID={
        "dartermall":dartermall,
        "noggins":noggins,
        "rubitrux":rubitrux,
        "rubitruxnginx":rubitruxnginx,
        "zabeldev":zabeldev,
        "devaccustandard":devaccustandard,
        "brokenarrow":brokenarrow,
        "edcosource":edcosource,
        "provence":provence,
        "thesolarbiz":thesolarbiz,
        "drainage":drainage,
        "zabelenvironmental":zabelenvironmental,
        "halbrowncompany":halbrowncompany,
        "thecnstore":thecnstore,
        "cndev":cndev,
        "m2testbox":m2testbox
    }
    
    infoReport=""
    
    if searchKey in allHostCID:
        for key,value in allHostCID[searchKey].items():
            infoReport+="{}:{}\n".format(key,value)
        for k,v in commonDict.items():
            infoReport+="{}:{}\n".format(k,v)
    else:
        infoReport="Site: {} not found!!!".format(searchKey)
    #pp.pprint(infoReport)
    exit(infoReport)
    

#Calling the function
#hostVsContainerID(sys.argv[1]) #here, sys.argv[1]--> the hostname
hackTheIPInformation(sys.argv[1])
    
    
    
    