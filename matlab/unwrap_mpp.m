function mp = unwrap_mpp(mpp, nz, nr)

ngrids = size(mpp,1);
[ridx, zidx] = meshgrid(1:nr, 1:nz);
mp = zeros(ngrids);

for j=1:ngrids
  for k = 1:ngrids
    n = mod(k-1,nz)+1 - zidx(j);
    m = floor((k-1)/nz)+1;
    mp(k,j) = mpp((m-1)*nz+abs(n)+1,ridx(j));
  end
end