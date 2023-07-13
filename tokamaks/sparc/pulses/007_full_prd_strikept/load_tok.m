
function tok = load_tok()

tok = load('sparc_tok').tok;
G = load('./data/L').L.G;
tok.limdata = [G.zl G.rl]';
tok.mpp = unwrap_mpp(tok.mpp, tok.nz, tok.nr);





