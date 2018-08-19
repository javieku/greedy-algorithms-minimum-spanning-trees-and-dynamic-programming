require 'singleton'

class UnionFind
    def initialize(n)
        @leaders = 1.upto(n).inject([]) { |leaders, i| leaders[i] = i; leaders }
    end

    def connected?(id1,id2)
        @leaders[id1] == @leaders[id2]
    end

    def union(id1,id2)
        leader_1, leader_2 = @leaders[id1], @leaders[id2]
        @leaders.map! {|i| (i == leader_1) ? leader_2 : i }
    end

    def components
      @leaders.group_by{|e| e}.map{|k, v| [k, v.length]}.delete_if { |k, v| k.nil? }
    end

    def component(id)
      @leaders[id]
    end
end

class Edge
    attr_reader :from
    attr_reader :to
    attr_reader :weight
    def initialize(from, to, weight)
    @from = from
    @to = to
    @weight = weight
    end
    def to_s
        "(From: " + @from.to_s + " To: " + @to.to_s + " W: " + @weight.to_s + ")"
    end
end

class ClusteringAlgorithm
    attr_accessor :max_spacing
    attr_accessor :min_spacing

    HIGH_INT = 999999
    LOW_INT = -1
    
    def initialize
      @max_spacing = LOW_INT
      @min_spacing = HIGH_INT
    end

    def execute(edges, n_of_nodes, clusters)
      
      set = UnionFind.new n_of_nodes
      
      edges.sort! {|x,y| x.weight <=> y.weight }
      
      n_of_clusters = n_of_nodes
      i = 0
      while (n_of_clusters > clusters) do
        edge = edges[i]
        if !set.connected?(edge.from, edge.to)
          set.union(edge.from, edge.to)
          n_of_clusters -= 1;
        end
        i += 1
      end

      
      # minimum distance among the cluster (max spacing)
      edges.each { |edg|  
        if !set.connected?(edg.from, edg.to)
          @min_spacing = [edg.weight,@min_spacing].min
        end 
      }

      # maximum distance among the clusters
      spacings = {}
      set.components.each do |key1,value1|
        spacings[key1] = Hash.new(set.components.length)
        set.components.each do |key2,value2|
           spacings[key1][key2] = HIGH_INT if key1 != key2
        end
      end
      edges.each { |edg|  
        if !set.connected?(edg.from, edg.to)
          leader_from = set.component(edg.from)
          leader_to = set.component(edg.to)
          spacings[leader_from][leader_to] = [spacings[leader_from][leader_to], edg.weight].min
          spacings[leader_to][leader_from] = [spacings[leader_to][leader_from], edg.weight].min
        end 
      }
      spacings.each do |key, values|
        max_value = values.fetch(values.max_by{|k,v| v}.first)
        @max_spacing = [max_value, @max_spacing].max
      end

      puts "Number of clusters -> #{set.components}" 
      puts "Spacings -> #{spacings}" 
    end
end

class Loader
  include Singleton
  def load_edges filename
    edges = []
    File.open(filename, "r") do |f|
        f.each_line do |line|
          edge = line.split(/\s/).reject(&:empty?)
          if edge.size < 2
            next
          end
          from = edge[0].to_i
          to = edge[1].to_i
          weigth = edge[2]
          edges.push(Edge.new(from, to, weigth.to_f))
        end
      end
      puts edges.length
    return edges
  end
  def load_n_of_nodes filename
    n_of_nodes = 0
    File.open(filename) {|f| n_of_nodes=f.readline.to_i}
    return n_of_nodes
  end
end
  
def main
  start = Time.now
  #data = "clustering-test-cases/clustering1-example-10-solution-11.txt"
  data = "clustering.txt"
  edges = Loader.instance.load_edges data
  n_of_nodes = Loader.instance.load_n_of_nodes data
  puts "Edges loaded in memory " +  (Time.now - start).to_s
  start = Time.now
  puts "Starting clustering algorithm"
  clustering = ClusteringAlgorithm.new
  n_of_clusters = 4
  clustering.execute(edges, n_of_nodes, n_of_clusters) 
  puts "Clustering took " +  (Time.now - start).to_s
  puts "Clustering result for #{n_of_clusters}"
  puts "Max distance among the clusters -> #{clustering.max_spacing}"
  puts "Min distance among the clusters -> #{clustering.min_spacing}"
end

main