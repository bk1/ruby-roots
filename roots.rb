def check_is_nonneg_int(x, name)
  raise TypeError, "#{name}=#{x.inspect} must be Integer" unless (x.kind_of? Integer) && x >= 0
end

def check_word_len(word_len, name="word_len")
  raise TypeError, "#{name} must be a positive number <= 1024" unless (word_len.kind_of? Integer) && word_len > 0 && word_len <= 1024
end

def split_to_words(x, word_len)
  check_is_nonneg_int(x, "x")
  check_word_len(word_len)
  bit_pattern = (1 << word_len) - 1
  words = []
  while (x != 0 || words.length == 0) do
    w = x & bit_pattern
    x = x >> word_len
    words.unshift(w)
  end
  words
end

def sqrt_bin(x)
  yy = sqrt_bin_with_remainder(x)
  yy[0]
end

def sqrt_bin_with_remainder(x)
  check_is_nonneg_int(x, "x")
  if (x == 0) then
    return [0, 0]
  end

  xwords = split_to_words(x, 2)
  xi = xwords[0] - 1
  yi = 1

  1.upto(xwords.length-1) do |i|
    xi = (xi << 2) + xwords[i]
    d0 = (yi << 2) + 1
    r  = xi - d0
    b  = 0
    if (r >= 0) then
      b  = 1
      xi = r
    end
    yi = (yi << 1) + b
  end
  return [yi, xi]
end

def sqrt_word(x, n = 16)
  check_is_nonneg_int(x, "x")
  check_is_nonneg_int(n, "n")
  if (x == 0) then
    return 0
  end

  n2 = n << 1
  n1 = n+1
  check_word_len(n2, "2*n")

  xwords = split_to_words(x, n2)
  if (xwords.length == 1) then
    return sqrt_bin(xwords[0])
  end

  xi = (xwords[0] << n2) + xwords[1]
  a  = sqrt_bin_with_remainder(xi)
  yi = a[0]
  if (xwords.length <= 2) then
    return yi
  end

  xi = a[1]
  2.upto(xwords.length-1) do |i|
    xi = (xi << n2) + xwords[i]
    d0 = (yi << n1)
    q  = (xi / d0).to_i
    j  = 10
    was_negative = false
    while (true) do
      d = d0 + q
      r = xi - (q * d)
      break if (0 <= r && (r < d || was_negative))
      if (r < 0) then
        was_negative = true
        q = q-1
      else
        q = q+1
      end
      j -= 1
      if (j <= 0) then
        break
      end
    end
    xi = r
    yi = (yi << n) + q
  end
  return yi
end

def sqrt_newton(x)
  check_is_nonneg_int(x, "x")
  if (x == 0) then
    return 0
  end
  y0 = x
  u0 = x
  while (u0 > 0) do
    y0 >>= 1
    u0 >>= 2
  end
  y0 = [1, y0].max
  yi = y0
  yi_minus_1 = -1
  loop do
    yi_plus_1 = (yi + x/yi) >> 1;
#    puts("yi_minus_1=#{yi_minus_1} yi=#{yi} yi_plus_1=#{yi_plus_1}")
    if (yi_minus_1 == yi_plus_1) then
      return [yi, yi_minus_1].min
    elsif (yi == yi_plus_1) then
      return yi
    end
    yi_minus_1 = yi
    yi = yi_plus_1
  end
end

def cbrt_newton(x)
  check_is_nonneg_int(x, "x")
  if (x == 0) then
    return 0
  end
  y0 = x
  u0 = x
  while (u0 > 0) do
    y0 >>= 1
    u0 >>= 3
  end
  y0 = [y0, 1].max
  yi = y0
  yi_minus_1 = -1
  loop do
    yi_plus_1 = ((2*yi + x/(yi*yi))/3).to_i
    if (yi_minus_1 == yi_plus_1) then
      return [yi, yi_minus_1].min
    elsif (yi == yi_plus_1) then
      return yi
    end
    yi_minus_1 = yi
    yi = yi_plus_1
  end
end

def cbrt_bin(x)
  yy = cbrt_bin_with_remainder(x)
  yy[0]
end

def cbrt_bin_with_remainder(x)
  check_is_nonneg_int(x, "x")
  if (x == 0) then
    return [0, 0]
  end
  xwords = split_to_words(x, 3)
  xi = xwords[0] - 1
  yi = 1

  1.upto(xwords.length-1) do |i|
    xi = (xi << 3) + xwords[i]
    d0 = 6 * yi * (2 * yi + 1) + 1
    r  = xi - d0
    b  = 0
    if (r >= 0) then
      b  = 1
      xi = r
    end
    yi = (yi << 1) + b
  end
  return [yi, xi]
end
