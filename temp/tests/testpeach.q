\l p.q

workers:{.z.pd:`u#hopen each prt}

testfn2:{count x}
qdevpeach:{do[100;dev[x]]}

npstdpeach:{p:.p.import[`pickle;`:loads][x];
        do[100;p[y]`]}

/pythonimp tfunc:{pyd:.p.import[`pickle;`:dumps;<][.p.import[`numpy][`:std]];
/	wfunc:{npstdpeach[x;y]};
/        wfunc[pyd;] peach x}
tfunc:{ wfunc:{testfn2[x]};
	wfunc peach x}	

n:rand 3000+til 10000                                       / set random port to start opening
prt:n+til slvs:abs system"s"                                / get correct number of ports
system "mkdir -p logs";
system each ("q testworker.q -p "),/:string[prt],'" &>./logs/worker.log.",/:(string[prt],\:" 2>&1 ");
