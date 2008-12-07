import os
import sys
import re
import urllib

"""HashFinder is a modul to find hashes of md5 and lm.
It uses milw0rm.com and passcracking.ru/com"""

class UnknownHashFormat(Exception):
    pass

class HashNotFound(Exception):
    pass

def validate(hash):
    if len(hash) == 32:
        return 'md5'
    elif len(hash) == 16:
        return 'lm'
    else:
        raise UnknownHashFormat

def milw0rm(hash):
    result=urllib.urlopen('http://milw0rm.com/cracker/search.php','hash='+hash).read()
    milw0rmR=re.compile(hash+'<\/TD><TD align="middle" nowrap="nowrap" width=\d+>(.+)<\/TD><TD align="middle" nowrap="nowrap" width=\d+>cracked<\/TD>')
    if milw0rmR.search(result):
        return hash, milw0rmR.search(result).group(1)
    else:
        raise HashNotFound

def passcracking(hash):
    result=urllib.urlopen('http://passcracking.com/index.php','datafromuser='+hash).read()
    passcrackingR=re.compile(hash+'<\/td><td bgcolor=#......>(.+)<\/td><td>')
    if passcrackingR.search(result):
        return hash,passcrackingR.search(result).group(1)
    else:
        raise HashNotFound

def lm(hash):
        return milw0rm(hash)

def md5(hash):
    try:
        (a,b)=milw0rm(hash)
    except HashNotFound:
        (a,b)=passcracking(hash)
    return a,b

def crack(hash):
    if validate(hash)=='lm':
        return lm(hash)
    elif validate(hash)=='md5':
        (a,b)=md5(hash)
        if len(b)==32:
            (c,d)=md5(b)
            if c==1:
                return a,b
            else:
                return a,d
        else:
            return a,b

if __name__ == '__main__':
    for hashid in range(1,len(sys.argv)):
        hash=sys.argv[hashid]
        try:
            (the,password)=crack(hash)
        except UnknownHashFormat:
            print >>sys.stderr, '%s unknown hash format' % hash
        except HashNotFound:
            print '%s not found' % hash
        else:
            print '%s=%s' % (hash, password)
