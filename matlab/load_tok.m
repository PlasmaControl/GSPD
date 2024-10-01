% load tok and make some default mods

function tok = load_tok(fn)

tok = load(fn).tok;

% uncompress the plasma grid inductances 
if size(tok.mpp,2) == tok.nr
  tok.mpp = unwrap_mpp(tok.mpp, tok.nz, tok.nr);
end







