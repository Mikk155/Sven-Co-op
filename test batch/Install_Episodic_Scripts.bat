set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=1test_global3.bsp 1test_global3.cfg 1test_global3_motd.txt 1test_global4.bsp 1test_global4.cfg 1test_global4_motd.txt
set output=maps/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a
  
  move %%a %Output%
))