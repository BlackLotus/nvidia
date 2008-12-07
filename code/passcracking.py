import hashfind
import sys

for hashid in range(1,len(sys.argv)):
   hash=sys.argv[hashid]
   type=hashfind.validate(hash)
   if type==1:
      print hash+' is no valid hash'
   elif type=='lm':
      (a,b)=hashfind.milw0rm(hash)
      if a==hash:
         print hash+'='+b
      else:
         print hash+' not found'
   elif type=='md5':
      (a,b)=hashfind.milw0rm(hash)
      if a==hash:
         print hash+'='+b
      else:
         (a,b)=hashfind.passcracking(hash)
         if a==hash:
            print hash+'='+b
         else:
            print hash+' not found'

