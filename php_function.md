#php 函数调用分析

通过修改zend内核代码,将一次请求过程中所有函数调用以树状结构展示出来

## 源码获取

``` bash
git clone git://github.com/php/php-src.git
cd php-src && git checkout PHP-5.5.22 # 签出5.5.22分支 公司目前使用版本
```

## 修改zend代码

    通过分析,php在执行opcode过程中,所有函数调用均会执行
    Zend/zend_vm_execute.h 文件中的
    函数 zend_do_fcall_common_helper_SPEC。
    因此在该函数中添加日志记录所有函数调用。

``` bash
   vim Zend/zend_vm_execute.h
   526gg o #找到 zend_do_fcall_common_helper_SPEC 函数 在 LOAD_OPLINE() 下添加如下代码
   
   FILE *stream;
   if((stream = fopen("/tmp/php.log", "a+")) != NULL){
           const char * cur_scope_name="";
           const char * cur_file_name="";
           if (fbc->type == ZEND_USER_FUNCTION && fbc->common.scope) {
                   cur_scope_name = fbc->common.scope->name;
                   cur_file_name = fbc->common.scope->info.user.filename;
           }
           fprintf(stream, "EC:%s/%s:type:%d",cur_scope_name,fbc->common.function_name,fbc->type);
           ulong arg_count = opline->extended_value;
           while(arg_count>0){
                   zval **p = (zval**)EX(function_state).arguments;
                   fprintf(stream, ":ext:%d",(*(p-arg_count))->type);
                   if((*(p-arg_count))->type==6){
                           fprintf(stream, ":str:%s",(*(p-arg_count))->value.str.val);
                   }
                   arg_count--;
           }
           fprintf(stream, ":%d %s\n",opline->lineno,cur_file_name);
   }
   fclose(stream);
```
    函数调用完成后 会调用
    Zend/zend_vm_execute.h 文件中的
    函数 zend_leave_helper_SPEC .
    因此在该函数中添加函数出口日志
``` bash
    vim Zend/zend_vm_execute.h
    433gg o #找到 zend_leave_helper_SPEC 函数 在 ZEND_VM_LEAVE()下方else分支中 下添加如下代码
   
    FILE *stream;
    if((stream = fopen("/tmp/php.log", "a+")) != NULL){
        fprintf(stream, "ECRETURN\n");
    }
    fclose(stream); 
```
## 重新编译内核

``` bash
./buildconf --force
./configure && make 
#完成后便会生成sapi/cli/php 文件

```

## CI 框架测试
``` bash
    #使用ci框架进行测试
    cd .. && git clone https://github.com/bcit-ci/CodeIgniter.git
    cd CodeIgniter/
    ../php-src/sapi/cli/php -S localhost:7777 &
    curl localhost:7777/index.php
    #此时/tmp/php.log中便已经记录了一次ci请求所有函数调用
```
## 以树状结构可视化结果

``` bash 
    cat /tmp/php.log |\
    grep ^EC|\
    awk -F : 'BEGIN{i=1}\
            /^ECRETURN/{i--;print "</ul></li>"}{if(NF>2)print "<li><span>"$2"</span>"}\
            /^EC:/{if($4!=1){i++;printf "<ul>"}}' | sed 's/<ul><\/ul>//'
    #即可生成树状列表 
```
    
    http://www.jq22.com/jquery-info7449
    利用该js代码显示树状结构


[效果展示](php_function/index.html)
