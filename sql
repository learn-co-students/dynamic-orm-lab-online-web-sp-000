
[1mFrom:[0m /home/nlanese21/code/labs/mod-8/dynamic-orm-lab-online-web-sp-000/lib/interactive_record.rb:77 InteractiveRecord.find_by:

    [1;34m64[0m: [32mdef[0m [1;36mself[0m.[1;34mfind_by[0m(inputHash)
    [1;34m65[0m:     keysArray = inputHash.keys
    [1;34m66[0m:     keysString = []
    [1;34m67[0m:     valuesArray = inputHash.values
    [1;34m68[0m:     keysArray.each [32mdo[0m | selectedKey |
    [1;34m69[0m:         keysString << selectedKey.to_s
    [1;34m70[0m:     [32mend[0m
    [1;34m71[0m:     sql = [31m[1;31m"[0m[31mSELECT * FROM #{self.table_name}[0m[31m WHERE #{keysString[0]}[0m[31m = #{valuesArray[0]}[0m[31m[1;31m"[0m[31m[0m
    [1;34m72[0m:     i = [1;34m1[0m
    [1;34m73[0m:     [32mwhile[0m (i < keysString.length)
    [1;34m74[0m:         sql += [31m[1;31m"[0m[31m AND #{keysString[i]}[0m[31m = #{valuesArray[i]}[0m[31m[1;31m"[0m[31m[0m
    [1;34m75[0m:         i += [1;34m1[0m
    [1;34m76[0m:     [32mend[0m
 => [1;34m77[0m:     binding.pry
    [1;34m78[0m:     [1;34;4mDB[0m[[33m:conn[0m].execute(sql)
    [1;34m79[0m: [32mend[0m

