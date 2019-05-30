load 'roots.rb';

2000000.times do |x|
  yn = sqrt_newton(x)
  yb = sqrt_bin(x)
  yw = sqrt_word(x)
  if (yn != yb || yb != yw || yw != yn) then
    puts("x=#{x} yn=#{yn} yb=#{yb} yw=#{yw} BAD")
  end
end
