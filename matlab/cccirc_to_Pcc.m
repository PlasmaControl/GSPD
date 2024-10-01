function Pcc = cccirc_to_Pcc(cccirc)

n = max(abs(cccirc));
Pcc = zeros(length(cccirc), n);  

for i = 1:n
  Pcc(cccirc == i,i) = 1;
  Pcc(cccirc == -i,i) = -1;  
end