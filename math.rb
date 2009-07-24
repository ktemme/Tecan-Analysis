# http://warrenseen.com/blog/2006/03/13/how-to-calculate-standard-deviation/
def variance(population)
  n = 0
  mean = 0.0
  s = 0.0
  population.each { |x|
    n = n + 1
    delta = x - mean
    mean = mean + (delta / n)
    s = s + delta * (x - mean)
  }
  # if you want to calculate std deviation
  # of a sample change this to "s / (n-1)"
  return s / (n-1)
end

# calculate the standard deviation of a population
# accepts: an array, the population
# returns: the standard deviation
def standard_deviation(population)
  Math.sqrt(variance(population)) unless variance(population).nan?
end

def average(population)
  n = 0
  sum = 0.0
  population.each { |x|
    n = n+1
    sum = sum+x
  }
  mean = sum / n
  return mean
end

def subtract_arrays(a,b)
  result = Array.new
  a.each_with_index do |value,i|
    result[i] = value - b[i]
    result[i] = result[i] < 0 ? 0.1 : result[i]
  end
  return result
end

def add_arrays(a,b)
  result = Array.new
  a.each_with_index do |value,i|
    result[i] = value + b[i]
  end
  return result
end

def make_array_log(a)
  logged_a = Array.new
  a.each_index {|x|
    if a[x] < 0
      logged_a[x] = -1*Math.log10(-a[x])
    else
      logged_a[x] = Math.log10(a[x])
    end
  }
  return logged_a
end

def make_hash_log(h)
  logged_h = Hash.new

  h.each {|k,well|
    logged_h[k] = make_array_log(h[k])
  }
  return logged_h
end

def js_equiv(values)
  data = values.enum_with_index.map{|x,i| "[#{i+1},#{x}],"}.to_s
  return "[" + data[0..data.size-2] + "]"
end

def convert_hash_to_js(h,name)
  keys = h.keys.sort
  data = []
  data = keys.map{|key| js_equiv(h[key])}
  # h.each {|key,value|
    # js_equiv = value.enum_with_index.map{|x,i| "[#{i+1},#{x}],"}.to_s
    # js_equiv = "[" + js_equiv[0..js_equiv.size-2] + "]"
    # sample_names += name + key.to_s + ", " 
    # data << js_equiv
  # }
  # sample_names = sample_names[0..sample_names.size-3].sort
  
  return {:ids => keys, :data => data}
end
