class Job
    attr_reader :weigth  
    attr_reader :length
    attr_reader :score
    
    def initialize(weigth,length)
      @weigth = weigth
      @length = length
      @score = (weigth.to_f / length)
    end
end

class JobScheduler

  attr_accessor :total_completion

  def initialize
    @total_completion = 0
  end

  def execute jobs

    jobs.sort! {|x,y| 
      
      if(y.score == x.score)
        y.weigth <=> x.weigth
      else 
        y.score <=> x.score
      end
    } 
    
    total_length = 0
    @total_completion = 0
    jobs.each{|job|
      total_length = total_length + job.length
      @total_completion += total_length *  job.weigth
    }
  end
end

def read_input
  jobs = []
  File.open("jobs.txt", "r") do |f|
      f.each_line do |line|
          line_arr = line.split(/\s/).reject(&:empty?)
          weigth = line_arr[0].to_i
          length = line_arr[1].to_i
          jobs.push(Job.new(weigth,length))
      end
  end
  return jobs
end

def greedy_job_scheduler
  start = Time.now
  puts "Starting algorithm"
  jobs = read_input
  puts "Jobs read from file " +  (Time.now - start).to_s
  
  start = Time.now

  scheduler = JobScheduler.new 
  scheduler.execute(jobs) 
  puts "Scheduler executed " +  (Time.now - start).to_s
  puts scheduler.total_completion
end

greedy_job_scheduler