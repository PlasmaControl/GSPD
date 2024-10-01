function cmats = output_model(dpsizrdx, tok, shapes, settings)

  N = settings.N;
  t = settings.t;
  cmats = cell(N,1);
  
  for i = 1:N
    ref = structts2struct(shapes, fields(shapes), t(i));
    cdata = build_cmat(dpsizrdx, ref, tok);
    cmats{i} = struct2vec(cdata, settings.fds2control);
  end

end



function c = build_cmat(dpsizrdx, ref, tok)

  c = struct;   % this will hold all the derivatives
    
  % response of currents is identity
  nx = tok.nc + tok.nv;
  c.x = eye(nx, nx);
  c.ic = c.x(1:tok.nc,:);
  c.iv = c.x(tok.nc+1:nx,:);

  
  % flux response at control points and boundary-defining point
  for i = 1:nx
    dpsizrdxi = reshape(dpsizrdx(:,i), tok.nz, tok.nr); 
    
    c.psicp(:,i) = bicubicHermite(tok.rg, tok.zg, dpsizrdxi, ref.rb, ref.zb);
    [c.psix(i), c.psix_r(i), c.psix_z(i)] = bicubicHermite(tok.rg, tok.zg, dpsizrdxi, ref.rx, ref.zx);
    c.psitouch(i) = bicubicHermite(tok.rg, tok.zg, dpsizrdxi, ref.rtouch, ref.ztouch);
    c.psibry(i) = bicubicHermite(tok.rg, tok.zg, dpsizrdxi, ref.rbdef, ref.zbdef);   

  end
  
  % control points vs target touch/x-points
  ONE = ones(length(ref.rb), 1);
  c.diff_psicp_psix = c.psicp - ONE * c.psix;
  c.diff_psicp_psitouch = c.psicp - ONE * c.psitouch;
  c.diff_psicp_psibry = c.psicp - ONE * c.psibry;

end
































