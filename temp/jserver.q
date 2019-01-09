\p 0W /set random port
system "mkdir -p logs";
f:{[x;y]system"q jworker.q ",x," >./logs/worker.log.",x,".",string[y]," 2>&1 "}
swork:{f[string system"p";]each neg[x]+(.i.cntr+:x)+1+til x} 			   	/start 'x' workers

/ The functions below are implementations of parallel distributed python, limitations on the
/ functions however exist with the items that can be pickled. These functions work well with the
/ sklearn general architecture fit/score

\l ml/init.q

/ tracking workers
regt:(0#0)!0#.z.P
regworker:{regt[.z.w]:.z.P}
.z.pc:{regt::regt _ x}

/ split table by columns based on the number of worker processes
/ here it is assumed that the identifying column (common to each)
/ is the first column in the dataset
distrib:{{(raze x _ y;x y)}[x y;]each til count y}


/* py  = q function to be 
/* (l)ist of required arguments
/* (d)ictionary of extra params; if 0b don't take these arguments

dist2em:{[py;l;d]
 p:.p.import[`pickle];
 k:p[`:dumps;<]py;
 neg[wh:key regt]@'({[fn;py;l;d]neg[.z.w]fn[py;l;d]};`gen;k;;d)each l;
 neg[wh]@\:(::);
 p[`:loads]each wh@\:(::)}

dist2q:{[py;l;d]
 p:.p.import[`pickle];
 k:p[`:dumps;<]py;
 neg[wh:key regt]@'({[fn;py;l;d]neg[.z.w]fn[py;l;d]};`gen;k;;d)each l;
 neg[wh]@\:(::);
 p[`:loads;<]each wh@\:(::)}

dist2py:{[py;l;d]
 p:.p.import[`pickle];
 k:p[`:dumps;<]py;
 neg[wh:key regt]@'({[fn;py;l;d]neg[.z.w]fn[py;l;d]};`gen;k;;d)each l;
 neg[wh]@\:(::);
 p[`:loads;>]each wh@\:(::)}

distkfold:{[py;x;y;i]
 p:.p.import[`pickle];
 k:p[`:dumps;<]py;
 data:distrib[x;i],'distrib[y;i];
 neg[wh:key regt]@'({[fn;py;l]neg[.z.w]fn[py;l]};`genkfold;k;)each data;
 neg[wh]@\:(::);
 avg p[`:loads;<]each wh@\:(::)}


distgsearch:{[py;x;y;i;dict]
 p:.p.import[`pickle];
 k:p[`:dumps;<]py;
 data:distrib[x;i],'distrib[y;i];
 neg[wh:key regt]@'({[fn;x;dict;data] neg[.z.w]fn[x;dict;data]};`gengsearch;k;dict;)each data;
 neg[wh]@\:(::);
 scores:wh@\:(::);
 aver:$[1=count .ml.shape scores;
	avg scores;
	avg each (,'/)scores];
 kd:key[dict];
 l:1=count kd;
 pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
 (max aver;$[l;$[1<count pos;(kd)0;kd];kd]!$[l;pos;flip pos])
 }

/ utils
.i.cntr:0
