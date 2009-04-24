require 'narray'
require 'enumerator'
require 'erb'
require 'math'
require 'rena_tecan'

module Enumerable  
  def select_with_index
    index = -1
    (block_given? && self.class == Range || self.class == Array)  ?  select { |x| index += 1; yield(x, index) }  :  self
  end  
  def select_with_index_blk(&block)
    index = -1
    (block && self.class == Range || self.class == Array)  ?  select { |x| index += 1; block.call(x, index) }  :  self
  end  
end

class String
 def to_range
   case self.count('.')
     when 2
         elements = self.split('..')
         return Range.new(elements[0].to_i, elements[1].to_i)
     when 3
         elements = self.split('...')
         return Range.new(elements[0].to_i, elements[1].to_i-1)
     else
         raise ArgumentError.new("Couldn't convert to Range:#{str}")
   end
 end
end

def analyze_rena_data(file,options)
  
  #sample_ids,white_id,layout,log_y,channels)
  
  # Arguments
  # 1. filename
  # 2. white cell group
  # 3. include or exclude the group listed below
  # 4. range of groups to include/exclude
  # 5. logarithmic axes?  none, X, Y, XY
  # 6. timepoint range

  # file = ARGV[0]
  # white = ARGV[1].nil? ? 0 : ARGV[1].to_i
  # rangeOperator = ARGV[2].nil? ? 'include' : ARGV[2]
  # range = ARGV[3].nil? ? 'all' : ARGV[3].to_range
  # log = ARGV[4].nil? ? 'none' : ARGV[4]
  # trange = ARGV[5].nil? ? 'all' : ARGV[5].to_range

  options[:white] ||= 0
  options[:time] ||= 0
  options[:fp] ||= 'rfp'
  if options[:fp] == ""
    options[:fp] = 'rfp'
  end
  options[:layout] = [[14,27,40],[  15,28,41],[  16,29,42],[  17,30,43],[  18,31,44],[  19,32,45],[  20,33,46],[  21,34,47],[  22,35,38],[  23,26,39],[  50,63,76],[  51,64,77],[  52,65,78],[  53,66,79],[  54,67,80],[  55,68,81],[  56,69,82],[  57,70,83],[  58,71,59]]  

  rangeOperator = 'include'
  range = 1..15
  log = 'none'
  trange = 'all'

  t = RenaTecan.new
  t.open(file, "\t") 

  groupedOD = Hash.new
  groupedRFU = Hash.new
  counter = 1

  options[:layout].each {|group|
    groupedOD[counter], groupedRFU[counter] = t.groupSort(group, options[:time].to_i, options[:fp])
    counter += 1
  }
  
  # Methods needed:
  # sort_plate_into_well_groupings
  # average_individual_wells
  # divide_individual_wells
  # divide_grouped_wells
  # subtract_grouped_wells
  
  # Order of operations:
  # sort plate
  # divide fluoresence by od
  # subtract white cells
  


  normalized_by_OD = t.normalize_by_OD(groupedOD, groupedRFU)
  norm_average = t.groupedAverage(normalized_by_OD)
  norm_white = t.subtract_white(norm_average,options[:white])
  norm_stddev = t.groupedStdDev(normalized_by_OD)


  stdevOD = t.groupedStdDev(groupedOD)
  stdevRFU = t.groupedStdDev(groupedRFU)
  averageRFU = t.groupedAverage(groupedRFU)
  averageOD = t.groupedAverage(groupedOD)

  rfu_subtracted_white = t.subtract_white(averageRFU,options[:white])  
  normalized_after_white = t.normalize_post(rfu_subtracted_white,averageOD)

  norm_rfu_by_iptg = t.timecourse_to_iptgcourse(norm_white)
  stdev_rfu_by_iptg = t.timecourse_to_iptgcourse(norm_stddev)

  range = 1..norm_stddev.values.size if range == 'all'
  trange = 1..norm_stddev.values.first.size if trange == 'all'

  # plot_vs_time(norm_white,norm_stddev,file+'.normalized.png','timepoint','RFU/OD','RFU/OD vs time: normalized by Sample '+white.to_s, range, log, trange, rangeOperator)
  # plot_vs_time(averageOD,stdevOD,file+'.averageOD.png','timepoint','OD','OD vs time', range, '', trange, rangeOperator)
  # plot_vs_time(averageRFU,stdevRFU,file+'.averageRFU.png','timepoint','RFU','Raw RFU vs time', range, log, trange, rangeOperator)
  # plot_vs_time(norm_rfu_by_iptg,stdev_rfu_by_iptg,file+'.iptg_curves.png','IPTG','RFU/OD','IPTG curves over time', trange.to_a, 'Y', range, 'F')

  # Prep data for display in flot via web
  js_fluorescence = convert_hash_to_js(rfu_subtracted_white,'r')
  js_od = convert_hash_to_js(averageOD,'o')
  js_norm = convert_hash_to_js(normalized_after_white,'n')

  # Grab our ERB template
  template = ERB.new(IO.readlines("templates/rfu.rhtml").to_s)
  return template.result(binding)

end