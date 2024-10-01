function y = measure_ys(psizr, fds2control, shapes, tok)

  t = shapes.rb.Time;
  N = length(t);
  
  for i = 1:N
    ref = structts2struct(shapes, fields(shapes), t(i));
    psizr_i = reshape(psizr(:,i), tok.nz, tok.nr);
  
    ydata = measure_y_fun(psizr_i, ref, tok);
    ydata.ic = zeros(tok.nc,1);

    y{i} = struct2vec(ydata, fds2control);
  end

end

function y = measure_y_fun(psizr, ref, tok)

  y.psicp = bicubicHermite(tok.rg, tok.zg, psizr, ref.rb', ref.zb');
  y.psitouch =  bicubicHermite(tok.rg, tok.zg, psizr, ref.rtouch, ref.ztouch);
  [y.psix, y.psix_r, y.psix_z] = bicubicHermite(tok.rg, tok.zg, psizr, ref.rx, ref.zx);
  y.psibry = bicubicHermite(tok.rg, tok.zg, psizr, ref.rbdef, ref.zbdef);
  

  ONE = ones(length(ref.rb), 1);
  y.diff_psicp_psix = y.psicp - ONE * y.psix;
  y.diff_psicp_psitouch = y.psicp - ONE * y.psitouch;
end


























