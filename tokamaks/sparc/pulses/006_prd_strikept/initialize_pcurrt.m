function pcurrt = initialize_pcurrt(tok, shapes, plasma_scalars)

opts.plotit = 0;
nr = tok.nr;
nz = tok.nz;
N = length(plasma_scalars.ip.Time);
pcurrt = zeros(nz*nr, N);


for i = 1:N

  if isfield(shapes, 'pcurrt')
    p = shapes.pcurrt.Data(i,:);
  else
    ip = plasma_scalars.ip.Data(i);
    
    rb = shapes.rb.Data(i,1:end-4);
    zb = shapes.zb.Data(i,1:end-4);

    [~,p] = jphi_estimate(rb, zb, ip, tok.rg, tok.zg, opts);
  end

  pcurrt(:,i) = p(:);
end









