class RenaTecan
  class << self; attr_accessor :plate; end
  attr_accessor :wells
  
  @plate = [[14,27,40],[  15,28,41],[  16,29,42],[  17,30,43],[  18,31,44],[  19,32,45],[  20,33,46],[  21,34,47],[  22,35,38],[  23,26,39],[  50,63,76],[  51,64,77],[  52,65,78],[  53,66,79],[  54,67,80],[  55,68,81],[  56,69,82],[  57,70,83],[  58,71,59]]  


  def open(file, delimiter = "\t")
    counter = 1
    file.each { |line|
      @wells[counter] = Hash.new

      timecourse = line.split(delimiter)
      timecourse = timecourse[0..timecourse.size-2]

      od = timecourse.select_with_index {|x,i| x if i % 3 == 0}
      rfp = timecourse.select_with_index {|x,i| x if i % 3 == 1}
      gfp = timecourse.select_with_index {|x,i| x if i % 3 == 2}

      @wells[counter]['od'] = od
      @wells[counter]['rfp'] = rfp
      @wells[counter]['gfp'] = gfp

      counter += 1
    }
  end
  
  def initialize
    @wells = Hash.new
  end

  def groupSort(g,time,fp)
    groupedOD = []
    groupedRFU = []
        
    g.each do |w|
      @wells[w]['od'].each_index {|i|
        unless (i > time) && (time > 0)
          if groupedOD[i].nil?
            groupedOD[i] = [@wells[w]['od'][i].to_f]
          else
            groupedOD[i] << @wells[w]['od'][i].to_f
          end
        end
      }
      @wells[w][fp].each_index {|i|
        unless (i > time) && (time > 0)
          if groupedRFU[i].nil?
            groupedRFU[i] = [@wells[w][fp][i].to_f]
          else
            groupedRFU[i] << @wells[w][fp][i].to_f
          end
        end
      }
    end
    return [groupedOD, groupedRFU]
  end
  
  def groupedStdDev(grouped)
    stdev = Hash.new

    grouped.each {|k,g|
      stdev[k] = Array.new
      g.each_index {|i|
          stdev[k][i] = standard_deviation(grouped[k][i])
      }
    }
    
    return stdev
  end
    
  def groupedAverage(grouped)
    ave = Hash.new

    grouped.each {|k,g|
      ave[k] = Array.new
      g.each_index {|i|
          ave[k][i] = average(grouped[k][i])
      }
    }
    
    return ave
  end
  
  def normalize_by_OD(od, rfu)
    normalized = Hash.new

    od.each {|k,well|
      normalized[k] = Array.new
      well.each_index {|i|
        normalized[k][i] = Array.new
        od[k][i].each_index {|value|
          # p 'new'
          # p k
          # p i
          # p rfu[k][i]
          # p rfu[5].size
          # p od[k][i]
          # p normalized[k][i]
          # p value
          normalized[k][i][value] = rfu[k][i][value] / od[k][i][value]
        }
      }
    }
    
    return normalized
  end
  
  def normalize_by_well(rfu,white)
    normalized = Hash.new
    
    rfu.each {|well_index,well_values|
      normalized[well_index] = Array.new

      rfu[well_index].each_index {|timepoint|
        timepoint_white_sum = rfu[white][timepoint].inject(0) {|result,element| result+element}
        timepoint_white_sum /= 4
        # p timepoint_white_sum
        normalized[well_index][timepoint] = Array.new

        rfu[well_index][timepoint].each_index {|value|
          normalized[well_index][timepoint][value] = rfu[well_index][timepoint][value] - timepoint_white_sum
        }
      }
    }
    return normalized
  end
  
  def subtract_white(cells,whiteGroup)
    result = Hash.new
    zeros = Array.new

    if whiteGroup == 0
      cells.values.first.size.times do |i| zeros << 0 end
    else
      zeros = cells[whiteGroup]
    end
    
    cells.each{|well_index,well_values|
      result[well_index] = subtract_arrays(cells[well_index],zeros)
    }
    return result
  end
  
  def timecourse_to_iptgcourse(timecourse)
    result = Hash.new
    timepoints = timecourse.values.first.size
    groups = timecourse.values.size
    (1..timepoints).each do |timepoint|
      result[timepoint] = Array.new
      (1..groups).each do |group|
        result[timepoint] << timecourse[group][timepoint-1]
      end
    end
    return result
  end

  def normalize_post(rfu,od)
    result = Hash.new
    
    rfu.each do |key, values|
      result[key] = Array.new
      values.each_with_index do |value, index|
        result[key][index] = rfu[key][index] / od[key][index]
      end
    end
    
    return result
  end
  
end