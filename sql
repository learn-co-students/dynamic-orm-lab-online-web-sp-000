
[1mFrom:[0m /mnt/c/Users/Owner/dev/flatiron/labs/dynamic-orm-lab-online-web-sp-000/lib/interactive_record.rb @ line 58 InteractiveRecord#save:

    [1;34m53[0m: [32mdef[0m [1;34msave[0m
    [1;34m54[0m:   sql = [31m[1;31m<<-SQL[0m[31m[0m
    [1;34m55[0m:   [1;34;4mINSERT[0m [1;34;4mINTO[0m [1;34m#{table_name_for_insert} (#{col_names_for_insert})[0m
    [1;34m56[0m:   [1;34;4mVALUES[0m ([1;34m#{values_for_insert})[0m
    [1;34m57[0m:   [1;34;4mSQL[0m
 => [1;34m58[0m:   binding.pry
    [1;34m59[0m:   [1;34;4mDB[0m[[33m:conn[0m].execute(sql)
    [1;34m60[0m: 
    [1;34m61[0m:   @id = [1;34;4mDB[0m[[33m:conn[0m].execute([31m[1;31m"[0m[31mSELECT last_insert_rowid() FROM #{table_name_for_insert}[0m[31m[1;31m"[0m[31m[0m)[[1;34m0[0m][[1;34m0[0m]
    [1;34m62[0m: 
    [1;34m63[0m: [32mend[0m

