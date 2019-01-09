system "S ",21_-4_string[.z.p];    
\l ml/init.q
\d .ml

/ Functions

/ Function to split table based on columns
chunktab:{{[x;y]flip[[[cols x][0,y]]!x[cols x][0,y]]}[x;]each (y,0N)#1_til count cols x}

/ x: data; y: id column; z: #leading columns to drop 
/ .z.pd not callable from script plain text -> in called fn
cfeatpd:{.z.pd:`u#hopen each .i.prt;				/ open ports for distribution
	data:chunktab[x;"j"$.i.slvs];				/ chunk by cols based on #slaves
	cfunc:{fresh.createfeatures[x;y;z _ cols x;fresh.getsingleinputfeatures[]]};
 	pdata:cfunc[;y;z] peach data;				
	{x uj y}/[();pdata]}					/ uj the list of tables

	
/ utils	
.i.n:rand 3000+til 10000					/ set random port to start opening
.i.prt:.i.n+til .i.slvs:abs system"s"				/ get correct number of ports 

/ if a logging directory doesn't exist create one
system "mkdir -p logs";						
/ system execution for opening ports, fresh and logs to the ports
system each ("q ml/init.q -p "),/:string[.i.prt],'" &>./logs/worker.log.",/:(string[.i.prt],\:" 2>&1 ");


// Example:
// This example works given the current path setup and assuming 
// ml is placed in $QHOME.
// $ q -s -4
// q)\l peachfresh.q
// q)tab:("SIIIIIII"; enlist ",") 0:`:../fresh/notebooks/SampleDatasets/waferdata.csv
// q)data:delete time from tab
// q).ml.cfeatpd[data;`id;1]
