h:neg hopen"J"$.z.x 0 /opens handle to server 
h(`regworker;`) / register as worker on server

/ load code I need to do work on text
\l ml/init.q

gen:{p:.p.import[`pickle][`:loads][x];.p.import[`pickle][`:dumps;<]$[z~0b;p[pyarglist y]`;p[pyarglist y;pykwargs z]]} 	/ Generalized distribution 

genkfold:{p:.p.import[`pickle][`:loads][x];.p.import[`pickle][`:dumps;<](p[`:fit][y 0;y 2][`:score][y 1;y 3]`)}		/ k-fold cross distributed

gengsearch:{[x;dict;data]mdl:.p.import[`pickle][`:loads][x];
	    algs:mkalg[dict;mdl];
            {x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;data]each algs}

mkalg:{[dict;algo]$[1=count kd:key[dict];
	        {x[(y 0) pykw z]}[algo;kd]each (value dict)0;  
		algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}
