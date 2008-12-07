import re
import os
import urllib,urllib2

"""HashFinder is a modul to find hashes of md5 and lm.
It uses milw0rm.com and passcracking.ru/com"""

def validate(hash):
   if len(hash) == 32:
      return 'md5'
   elif len(hash) == 16:
      return 'lm'
   else:
      return 1

def milw0rm(hash):
   result=urllib.urlopen('http://milw0rm.com/cracker/search.php','hash='+hash).read()
   milw0rmR=re.compile(hash+'<\/TD><TD align="middle" nowrap="nowrap" width=\d+>(.+)<\/TD><TD align="middle" nowrap="nowrap" width=\d+>cracked<\/TD>')
   if milw0rmR.search(result):
      return hash,milw0rmR.search(result).group(1)
   else:
      return 1,1
def passcracking(hash):
   result=urllib.urlopen('http://passcracking.com/index.php','datafromuser='+hash).read()
   passcrackingR=re.compile(hash+'<\/td><td bgcolor=#......>(.+)<\/td><td>\d+<\/td><\/tr><\/table>')
   if passcrackingR.search(result):
      return hash,passcrackingR.search(result).group(1)
   else:
      return 1,1
