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
    end
    def execute(total_weight,items)
        results = Array.new(items.length);
        for i in (0..items.length)
            results[i] = Array.new(total_weight+1);
        end
        for i in (0..total_weight)
            results[0][i] = 0;
        end
        
        for i in (1..items.length)
            for weight in (0..total_weight)
                if (items[i-1].weight > weight)
                    results[i][weight] = results[i-1][weight]
                else
                    results[i][weight] = [results[i-1][weight],
                                          results[i-1][weight-items[i-1].weight]+items[i-1].value].max
                end
            end
        end

        @selected_items = []
        aux = total_weight
        for i in (items.length).downto(1)
            if (items[i-1].weight > aux)
            else
                if (results[i-1][aux] <
                    results[i-1][aux-items[i-1].weight] + items[i-1].value)
                    @selected_items.push(i-1)
                    aux = aux - items[i-1].weight
                end
            end
        end

        @max_value = results[items.length][total_weight]
    end
 end

class Loader
    include Singleton
    def read_input
      weight = 0
      items = []
      File.open("knacksack.txt", "r") do |f|
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
    algorithm.execute(weight,items)
    puts "Max value fitting " + weight.to_s + " is " + algorithm.max_value.to_s
    puts "Selected items " + algorithm.selected_items.to_s 
end

main