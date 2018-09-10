require 'singleton'

class MaxWeightIndependentSetAlgorithm
    attr_accessor :result
    attr_accessor :max_sum
    def execute(weights)
        @ht = impl(weights)
    end

    def impl(weights)
        sum = []
        weights.each_with_index do |element,index|
            sum[index] = 0 
        end
        sum[0] = 0
        sum[1] = weights[1]
        for i in 2...weights.length
            sum[i] = [sum[i-1], sum[i-2] + weights[i]].max 
        end

        @max_sum = sum.last

        @result = []
        i = weights.length-1;
        until i<1
            if(sum[i-1] > sum[i-2]+weights[i])
                i-=1
            else
                @result.push(i)
                i-=2  
            end
        end
    end
 end

class Loader
    include Singleton
    def read_input
      weights = []
      File.open("mwis.txt", "r") do |f|
          f.each_with_index do |line,index|
            next if index == 0
            weights[index] = line.to_i
          end
      end
      return weights
    end
end

def main 
    weights = Loader.instance.read_input
    algorithm = MaxWeightIndependentSetAlgorithm.new
    algorithm.execute(weights)
    puts "Maximum weight: " + algorithm.max_sum.to_s
    puts "Vertices in the maximum weight independent set: " + algorithm.result.sort!.to_s

    question = [1, 2, 3, 4, 17, 117, 517,997]
    solution = algorithm.result & question
    puts "Question assignment 3 " + solution.to_s # 10100110
end

main