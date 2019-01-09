\l ../testing.q
\l testpeach.q
workers[]
back:.z.pd;
runtest:{[n;slaves]
 0N!(n;iters:1|100&`long$500000%10*n);
 if[slaves>count back;'`toomany];
 .z.pd:`u#slaves#back;
 xvals:("i"$n%10)cut n?100f;
 0N!ST:.z.P;
 do[iters;tfunc[xvals]];
 (n;slaves;(.z.P-ST)%iters)}
tests:100 250 500 750 1000 2500 5000 7500 10000 25000 50000 100000 250000 500000 1000000 2500000 5000000 cross (1+til 8)
res3:([]n:0#0;slaves:0#0;time:0#0n)
`res3 insert u:flip runtest ./:tests
save`:res3

