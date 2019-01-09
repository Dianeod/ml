\l testing.q
\l peachxval.q
n:4000
x:flip value flip([]n?100f;asc n?100f)
y:asc n?100f
i:.ml.kfshuff[y;8]
dict:`alpha`l1_ratio!(0.75;0.25 0.5 0.75)
py:.p.import[`sklearn.linear_model][`:ElasticNet]
