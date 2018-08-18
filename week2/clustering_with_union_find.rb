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
        "(From: " + @from.to_s + "To: " + @to.to_s + " W: " + @weight.to_s + ")"
    end
end

class ClusteringAlgorithm
    attr_accessor :maximum_spacing
    def initialize
      @maximum_spacing = 111111111
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

      edges.each { |edg|  
        if !set.connected?(edg.from, edg.to)
          puts edg
          @maximum_spacing = [edg.weight,@maximum_spacing].min
        end 
      }
    end
end

  class Loader
    include Singleton
    def load_edges 
      edges = []
      File.open("clustering.txt", "r") do |f|
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
      return edges
    end
    def load_n_of_nodes
      n_of_nodes = 0
      File.open('clustering.txt') {|f| n_of_nodes=f.readline.to_i}
      return n_of_nodes
    end
  end
  
  def main
    start = Time.now
    edges = Loader.instance.load_edges
    n_of_nodes = Loader.instance.load_n_of_nodes
    puts "Edges loaded in memory " +  (Time.now - start).to_s
    start = Time.now
    puts "Starting clustering algorithm"
    clustering = ClusteringAlgorithm.new
    n_of_clusters = 2
    clustering.execute(edges, n_of_nodes, n_of_clusters) 
    puts "Clustering took " +  (Time.now - start).to_s
    puts "Clustering result for #{n_of_clusters}"
    puts clustering.maximum_spacing
  end

  main