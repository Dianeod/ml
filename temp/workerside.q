\l p.q
tab:([]n:0#0;folds:0#0;slaves:0#0;time:0#0Nn)
tabkf:([]n:0#0;folds:0#0;slaves:0#0;time:0#0Nn)
tablsq:([]n:0#0;folds:0#0;slaves:0#0;time:0#0Nn)
gengsearch:{[x;dict;data]
            0N!count tab;
	    ST:.z.P;
 	    mdl:.p.import[`pickle][`:loads][x];
            algs:mkalg[dict;mdl];
            r:{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;data]each algs;
 	    `tab insert (N;FOLDS;SLAVES;.z.P-ST);r
	    }

kffitscore:{[x;data]
	   0N!count tab;
           ST:.z.P;
	   mdl:.p.import[`pickle][`:loads][x];
	   r:{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[mdl;data];
	   `tabkf insert (N;FOLDS;SLAVES;.z.P-ST);r
	   }

mkalg:{[dict;algo]$[1=count kd:key[dict];
                {x[(y 0) pykw z]}[algo;kd]each (value dict)0;
                algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}

qlsq:{[x]0N!count tabkf;
      ST:.z.P;
      do[10;r:{(enlist x 2)lsq flip x 0}x];
      `tablsq insert (N;FOLDS;SLAVES;.z.P-ST);r
      }	
