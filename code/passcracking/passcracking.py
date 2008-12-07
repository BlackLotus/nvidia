import hashfind
import sys

for hashid in range(1,len(sys.argv)):
   hash=sys.argv[hashid]
#   print hash
   (the,password)=hashfind.crack(hash)
   if the != hash:
      print hash+' not found'
   else:
      print hash+'='+password
