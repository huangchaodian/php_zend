echo '
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>jQuery轻量级树状菜单插件代码</title>
<link href="jquery.treemenu.css" rel="stylesheet" type="text/css">
<style>
*{list-style:none;border:none;}
body{font-family:Arial;background-color:#2C3E50;}
.tree {  color:#46CFB0;width:800px;margin:100px auto;}
.tree li,
.tree li > a,
.tree li > span {
    padding: 4pt;
    border-radius: 4px;
}

.tree li a {
   color:#46CFB0;
    text-decoration: none;
    line-height: 20pt;
    border-radius: 4px;
}

.tree li a:hover {
    background-color: #34BC9D;
    color: #fff;
}

.active {
    background-color: #34495E;
    color: white;
}

.active a {
    color: #fff;
}

.tree li a.active:hover {
    background-color: #34BC9D;
}
</style>
</head>

<body>
<ul class="tree">'


cat /tmp/php.log |\
    grep ^EC|\
    awk -F : 'BEGIN{i=1}\
            /^ECRETURN/{i--;print "</ul></li>"}\
            {if(NF>2){\
				param="";\
				for(k=5;k<NF;k++){if($k=="str"){param=param" "$(k+1)}}\
				print "<li><span>"$2"("param")</span>"}\
			}\
            /^EC:/{if($4!=1){i++;printf "<ul>"}}' | sed 's/<ul><\/ul>//'
echo '
</ul>
<script src="jquery-1.11.2.min.js"></script> 
<script src="jquery.treemenu.js"></script> 
<script>
$(function(){
        $(".tree").treemenu({delay:300}).openActive();
    });
</script>


</body>
</html>'
