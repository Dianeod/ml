/ The purpose of this script is to act as a initial test of the use of peach
/ in the context of a cross validation functions

\l p.q
\l ml/init.q

/ This function is used to break the data into the folds for the cross validation procedure
distrib:{{(raze x _ y;x y)}[x y;]each til count y}
mkalg:{[dict;algo]$[1=count kd:key[dict];
                {x[(y 0) pykw z]}[algo;kd]each (value dict)0;
                algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}
gengsearch:{[x;dict;data]mdl:.p.import[`pickle][`:loads][x];
            algs:mkalg[dict;mdl];
            {x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;data]each algs}
kffitscore:{[x;data]
           mdl:.p.import[`pickle][`:loads][x];
           r:{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[algs;data];
           }
workers:{.z.pd:`u#hopen each prt}

/ .z.pd not callable from script plain text -> in called fn
xvalpd:{[x;y;i;algo;dict]
/xvalpd:{[x;y;i;dict;algo]
	alg:.p.import[`pickle][`:dumps;<][algo];
        data:distrib[x;i],'distrib[y;i];
	xfunc:{gengsearch[x;y;z]};
	vals:xfunc[alg;dict]peach data;
        aver:$[1=count .ml.shape vals;
                avg vals;
                avg each (,'/)vals];
        kd:key[dict];
        l:1=count kd;
        pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
        (max aver;$[l;$[1<count pos;(kd)0;kd];kd]!$[l;pos;flip pos])
	}

kfxvalpd:{[x;y;i;algo]
        alg:.p.import[`pickle][`:dumps;<][algo];
        data:distrib[x;i],'distrib[y;i];
        xfunc:{kffitscore[x;y]};
        vals:xfunc[alg;]peach data;
        aver:$[1=count .ml.shape vals;
                avg vals;
                avg each (,'/)vals]}

pdlsq:{[x;y;i]
	data:distrib[x;i],'distrib[y;i];
	xfunc:{qlsq x};
	vals:xfunc peach data;
        $[1=count .ml.shape vals;
                avg vals;
                avg each (,'/)vals]}

/ utils
n:rand 3000+til 10000                                        / set random port to start opening
prt:n+til slvs:abs system"s"	                            / get correct number of ports

/ if a logging directory doesn't exist create one
system "mkdir -p logs";
/ system execution for opening ports, fresh and logs to the ports
system each ("q workerside.q -p "),/:string[prt],'" >./logs/worker.log.",/:(string[prt],\:" 2>&1 ");
