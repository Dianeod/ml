system "S ",21_-4_string[.z.p];
\l ../init.q

/ The following script is not intended for publishing in the ml github but is here as a test
/ script for functions which are likely to be introduced into this github at a later point.

/ Comments and examples for this are now located in a large part on cmccarthy1/docs/ml/toolkit/utils
\d .ml

f1score:{2*l*k%((l:precision[x;y;z])+k:sensitivity[x;y;z])}
fbscore:{[x;y;z;b]((1+b*b)*v*l)%(v:sensitivity[x;y;z])+b*b*l:precision[x;y;z]}			/ if binary and z=0b --> python
hammingloss:{sum[0<>y-x]%count x}								/ equivalent to 1-acc for binary 
matcorr:{(-1*last deltas prd each flip(k 0;rotate[1;k 1]))%					/ implementation of Matthews correlation coefficient
		sqrt prd(sum each k:flip l),(sum each l:value confmat[x;y])}
r2score:{1-sse[x;y]%sse[x;count[x]#avg x]}
rmse:{sqrt mse[x;y]}
mae:{avg sum abs x-y}                                                   			/ Mean-absolute error
mape:{100*mae[x;y]%x}                                                   			/ Mean-absolute percentage error
rmsle:{sqrt(sum k*k:((exp 1)xlog(y+1))-(exp 1)xlog x+1)%count x}        			/ Root Mean Squared Logarithmic Error
PPV:{d:confdict[x;y];l%d[`fp]+l:d`tp}		        	         			/ Positive predictive value - useful only for binary classifiers
NPV:{d:confdict[x;y];d[`tn]%d[`tp]+d`fn}		                    			/ Negative predictive value
FDR:{1-PPV[x;y]}                                                        			/ False Discovery Rate
FOR:{1-NPV[x;y]}                                                        			/ False Omission Rate

classreport:{[x;y]k:distinct y;rnd2:{0.01*"j"$100*x};
		tab:([]class:`$string each k;
		precision:rnd2 precision[x;y]each k;
		recall:rnd2 sensitivity[x;y]each k;
		f1_score:rnd2 f1score[x;y]each k;
		support:{sum x=y}[y;]each k);
			`class xasc tab,([]class:enlist `$"avg/total";
				precision:enlist avg tab[`precision];
				recall:enlist avg tab[`recall];
				f1_score:enlist avg tab[`f1_score];
				support:sum tab[`support])}

describe:{`count`type`mean`std`min`q1`q2`q3`max!
	  flip(count;type;avg;sdev;min;percentile[;.25];percentile[;.5];percentile[;.75];max)
	  @\:/:flip(exec c from meta[x]where t in"hijefpmdznuvt")#x}

distrib:{{(raze x _ y;x y)}[x y;]each til count y}
mkalg:{[dict;algo]$[1=count kd:key[dict];
                {x[(y 0) pykw z]}[algo;kd]each (value dict)0;
                algo@'{pykwargs x}each {key[x]!y}[dict;]each (cross/)value dict]}

xval.kfsplit:{(y,0N)#til count x}
kfshuff:xval.kfshuff:{(y,0N)#shuffle x}
xval.kfstrat:{(,'/){(y,0N)#x}[;y]each value n@'shuffle each n:group x shuffle x}

kfoldx:xval.kfoldx:{[x;y;i;fn]
	data:distrib[x;i],'distrib[y;i];
	vals:{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[fn]each data;
	$[1=count shape vals;
          avg vals;
          avg each (,'/)vals]}

xval.gridsearch:{[x;y;i;algo;dict]
	alg:mkalg[dict;algo];
	data:distrib[x;i],'distrib[y;i];
	vals:{{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;y]each x}[alg]each data;
	aver:$[1=count shape vals;
                avg vals;
                avg each (,'/)vals];
	l:1=count kd:key dict;
	pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;	
	(max aver;$[l;$[1<count pos;(kd)0;kd];kd]!$[l;pos;flip pos])}

xval.gridsearchfit:{[x;y;sz;algo;dict]
	t:util.traintestsplit[x;y;sz];
	alg:mkalg[dict;algo];									/ see mkalg for outputs	
	i:xval.kfshuff[t`ytrain;5];								/ indices for k-folds
	trdata:distrib[t`xtrain;i],'distrib[t`ytrain;i];
	vals:{{x[`:fit][y 0;y 2][`:score][y 1;y 3]`}[;y]each x}[alg]each trdata;
        aver:$[1=count shape vals;
                avg vals;
                avg each (,'/)vals];        
	l:1=count kd:key dict;
	pos:$[l;(value dict)0;((cross/)value dict)] where aver=max aver;
	bst:$[l;$[1<count pos;kd 0;kd];kd]!$[l;pos;flip pos];					/ dict of best scores
	bfit:kd!value first each bst;								/ account for multiple equal scores
	bo:mkalg[bfit;algo];									/ produce the correct hyper parameter seeded algo
        fitfn:{y[`:fit][x`xtrain;x`ytrain];y[`:score][x`xtest;x`ytest]`};			/ fit and scoring function for best algo
	(bfit;fitfn[t;$[1<count bst;bo 0;bo]])}							/ boolean test handles multi param single value dicts

xval.rollxval:{[x;y;n;algo]
        i:1_(1 xprev k),'k:enlist each(n+1,0N)#til count y;                                     / indices for training and validation (1st each = train; 2nd = val)
        data:x@i;tar:y@i;                                                                       / set data and targets based on indices for data sets
        avg{[x;y;z;k]x[`:fit][(y k)0;(z k)0];
                    x[`:score][(y k)1;(z k)1]`}[algo;data;tar]each til n}

xval.chainxval:{[x;y;n;algo]
        o:{((,/)neg[1]_x;last x)}each 1_(,\)enlist each (n,0N)#til count y;                     / this creates a 'pyramid of increasing' length training set and equi length validation indices
        data:x@o; tar:y@o;
        avg{[x;y;z;k]x[`:fit][(y k)0;(z k)0];
                    x[`:score][(y k)1;(z k)1]`}[algo;data;tar]each til n-1}

xval.mcxval:{[x;y;sz;algo;n]
        val:();trn:();
        do[n;
           val,:enlist neg[k:"j"$sz*count i]#i:shuffle y;                                       / indices for validation sets
           trn,:enlist neg[k]_i];                                                               / indices for training sets
        dsplit:{[x;y;z;val;trn](x trn z; x val z;y trn z;y val z)}[x;y;;val;trn]each til n;     / returns training and validation sets for random split data
        avg{[x;y;z]x[`:fit][(y z)0;(y z)2];
                    x[`:score][(y z)1;(y z)3]`}[algo;dsplit]each til n}

xval.repkfval:{[x;y;n;k;algo]
	pred:();
        do[n;i:xval.kfshuff[y;k];pred,:kfoldx[x;y;i;algo]];
        avg pred}

xval.repkfstrat:{[x;y;n;k;algo]
        pred:();
        do[n;i:xval.kfstrat[y;k];pred,:kfoldx[x;y;i;algo]];
        avg pred}

/ utils
shuffle:{neg[n]?n:count x}

/ Functions for simplification of feature selection and additional functionality.

sigfeat:{[table;targets]
 table:(where 0=var each flip table)_table;
 bintest:{2=count distinct x};
 bintarget:bintest targets;
 bincols:where bintest each flip table;
 realcols:cols[table]except bincols;
 bintab:table[bincols];
 realtab:table[realcols];
 pvals:raze$[bintarget;
  {y[x;]each z}[targets]'[fresh.ks2samp,fresh.fishertest;(realtab;bintab)];
  {y[x;]each z}[targets]'[fresh.ktaupy,fresh.ks2samp;(realtab;bintab)]];
 (realcols,bincols)!pvals}

/ Base selection on percentile constraints
/ choose p-vals < the p percentile
percentilesigfeat:{[table;targets;p]
 where percentile[k;p]>k:sigfeat[table;targets]}

/ K most significant features from the data
ksigfeat:{[table;targets;k]
 key k#asc sigfeat[table;targets]}

/ Benjamini-Hochberg test with new formatting
benjhochsplit:{[table;targets]
 fresh.benjhochfind[sigfeat[table;targets];0.05]}

/ Correlation based Feature Selection:
/ This function is limited in scope, issues arise in horizontally large datasets
/ this is due to the need to produce all combinations of features possible on 2 separate
/ occasions (probably is a way to do once & map) 
/ it however is much faster on large row data than fresh significance testing.
/* t = table
/* tgt = target
cfs:{[t;tgt]
    t:$[99=type t;value t;t];
    fc:(flip t)cor\:tgt;
    pairs:cols[t] -1+util.combs[;n]each n:(1+til count cols t);
    k:raze{count each x}each pairs;
    rff:1^raze{avg each x}each 
	(({`$x} each string each p cross p:cols[l])!
	raze flip l:value corrmat[t])@{{util.combs[2;x]}each x}each pairs;
    rcf:1^raze{avg each x}each {x@y}[fc]each pairs;
    (key 1#desc raze[pairs]!{(x*y)%sqrt x+x*(x-1)*z}[k;rcf;rff])0}

// TESTING SECTION

/ Adjusted R2 function to account for degrees of freedom in the model.
/ x:predicted; y:actual; z:#indicators
R2adj:{1-(1-r2score[x;y])*(k-1)%(k:count[x])-z-1}                                               / adjusted r2score

/ NOTE: this is likely to be an expensive test to do if large datasets are involved
/ The following is an attempt at an implementation of
/ forward step-wise variable selection a technique which 'loops' over
/ increasing numbers of 'features' to find the cutoff where adding features no
/ longer improves the score of a machine learning algorithm.
/ Note that this works best on non deterministic models such as lin-regress/logistic-regress/SVM for example.
/* data = entire dataset from which subsets are chosen
/* targets = target vector
/* pvals = p-values calculated using sigfeat
/* py = python model being tested
/* pertst = train-test split percentage
xval.fswselect:{[data;target;py;sz]
	system"S 1";
	tts:util.traintestsplit[data;target;sz];
	ascpval:asc sigfeat[data;target];
	pickfn:{x#key y};
	ifp:2;isp:3;
	fp:pickfn[ifp;ascpval];sp:pickfn[isp;ascpval];
	while[(py[`:fit][flip(tts`xtrain)fp;tts`ytrain][`:score][flip(tts`xtest)fp;tts`ytest]`)<=
	      py[`:fit][flip(tts`xtrain)sp;tts`ytrain][`:score][flip(tts`xtest)sp;tts`ytest]`
	      ;fp:pickfn[ifp+:1;ascpval];sp:pickfn[isp+:1;ascpval]];
	fp
	}

/ On the assumption that this test of the function is being done within the temp folder
// q)n:1000
// q)x:([]n?100f;n?100f;n?100f;n?100f;n?100f;(n?1000f)+asc n?100f;asc n?100f;desc n?100f;n?100f;n?100f;n?100f)
// q)y:asc n?100f
// q)py:.p.import[`sklearn.linear_model][`:LinearRegression][]
// q)sz:0.2
// q).ml.xval.fswselect[x;y;py;sz]

/ The following is an implementation of backward step-wise feature selection.
/ The cutoff for p-value which will be considered as the maximum value is 0.157 (chosen arbitrarily but ubiqutous in stats).
/ All features up to this threshold are considered and I 1-drop from this at each iteration and 'save' the scores, then find
/ the model from this set that maximizes the score from the model.

xval.bswselect:{[data;target;py;sz]
	tts:util.traintestsplit[data;target;sz];
	ascpval:asc sigfeat[tts`xtrain;tts`ytrain];
	keyvals:where ascpval<0.157;
	vallist:(1#keyvals),\1_keyvals;
	scores:{z[`:fit][flip(x`xtrain)y;x`ytrain][`:score][flip(x`xtest)y;x`ytest]`}[tts;;py]each vallist;
	raze vallist where scores=max scores 
	}

// q)n:1000000
// q)x:([]n?100f;n?100f;n?100f;n?100f;n?100f;(n?1000f)+asc n?100f;asc n?100f;desc n?100f;n?100f;n?100f;n?100f)
// q)y:asc n?100f
// q)py:.p.import[`sklearn.linear_model][`:LinearRegression][]
// q)sz:0.2
// q).ml.xval.bswselect[x;y;py;sz]
