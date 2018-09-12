require 'singleton'

class Item
    attr_accessor :value
    attr_accessor :weight
    def initialize(value,weight)
        @weight = weight
        @value = value
    end
end

class KnacksackDPAlgorithm
    attr_accessor :max_value
    attr_accessor :selected_items

    def initialize
        @max_value = -1
        @selected_items = []
        @cache = {}
    end

    def execute(weight,items)
        @max_value = execute_impl(weight,0,items)    
    end

    def execute_impl(weight,i,items)

        if (items.length == 0)
            return 0
        end

        if (weight <= 0)
            return 0
        end

        if ( i >= items.length)
            return 0
        end

        key = weight.to_s+","+i.to_s
        if (@cache.include?(key))
            return @cache[key]
        end

        if(items[i].weight>weight)
            result = execute_impl(weight, i+1,items)
        else
            result = [items[i].value + execute_impl(weight-items[i].weight, i+1, items),
                     execute_impl(weight, i+1, items)].max
        end

        if (!@cache.include?(key))
            @cache[key] = result
        end

        return result;
    end
end

class Loader
    include Singleton
    def read_input
      weight = 0
      items = []
      File.open("knacksack_big.txt", "r") do |f|
          f.each_with_index do |line,index|
            if (index == 0)
                line_arr = line.split(/\s/).reject(&:empty?)
                weight = line_arr[0].to_i
            else
                line_arr = line.split(/\s/).reject(&:empty?)
                items.push(Item.new(line_arr[0].to_i,line_arr[1].to_i))
            end
          end
      end
      return weight, items
    end
end

def main 
    (weight,items) = Loader.instance.read_input
    algorithm = KnacksackDPAlgorithm.new
    start = Time.now
    puts "Starting algorithm"
    algorithm.execute(weight,items)
    puts "Took " +  (Time.now - start).to_s
    puts "Max value fitting " + weight.to_s + " is " + algorithm.max_value.to_s
    puts "Selected items " + algorithm.selected_items.to_s 
end

main