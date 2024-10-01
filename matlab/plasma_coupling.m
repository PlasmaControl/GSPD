% this is the effect on the coils/vessels due to plasma current evolution

function w = plasma_coupling(dt, tok, pcurrt)

M = [tok.mcc tok.mcv; tok.mcv' tok.mvv];
M = (M + M') /  2;                 
Minv = inv(M);

pcurrtdot = gradient(pcurrt, dt);
w = -Minv * [tok.mpc tok.mpv]' * pcurrtdot;









