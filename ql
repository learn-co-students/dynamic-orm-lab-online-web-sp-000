
[1mFrom:[0m /mnt/c/Users/SG/dev/flatiron/labs/dynamic-orm-lab-online-web-sp-000/lib/interactive_record.rb @ line 65 InteractiveRecord.find_by:

    [1;34m56[0m: [32mdef[0m [1;36mself[0m.[1;34mfind_by[0m(options={})
    [1;34m57[0m: 
    [1;34m58[0m:     find_str = [31m[1;31m'[0m[31m[1;31m'[0m[31m[0m
    [1;34m59[0m:     options.each_with_index [32mdo[0m |(property, value), index|
    [1;34m60[0m:         find_str << [31m[1;31m"[0m[31m WHERE #{property.to_s}[0m[31m = #{value.is_a?(String) ? [1;31m"[0m[31m'#{value}[0m[31m'[1;31m"[0m[31m[0m[31m: value}[0m[31m[1;31m"[0m[31m[0m
    [1;34m61[0m:         find_str << [31m[1;31m"[0m[31m AND[1;31m"[0m[31m[0m [32mif[0m !(index == options.length-[1;34m1[0m)
    [1;34m62[0m:     [32mend[0m
    [1;34m63[0m:     [1;34m#binding.pry[0m
    [1;34m64[0m:     sql = [31m[1;31m"[0m[31mSELECT * FROM #{self.table_name}[0m[31m#{find_str}[0m[31m[1;31m"[0m[31m[0m
 => [1;34m65[0m:     binding.pry
    [1;34m66[0m:     [1;34;4mDB[0m[[33m:conn[0m].execute(sql)
    [1;34m67[0m: 
    [1;34m68[0m: [32mend[0m

