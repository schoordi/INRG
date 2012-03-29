#!/usr/bin/env ruby

module Default
  QUERY_DIRECTORY = "queries"
  DOCUMENT_DIRECTORY = "documents"
end

class MiniRetrieve
  attr_reader :query_list, :document_list, :document_index, :document_norm, :idf
  def initialize( options = {} )
    @document_list  = Hash.new # { filename: { term: count } }
    @query_list     = Hash.new # { filename: { term: count } }
    @document_index = Hash.new # { term: { filename: [[line#, token#], ... ] } }
    @idf            = Hash.new # { term: value } inverse document frequency
    @document_norm  = Hash.new 0.0 # { filename: value }

    if options[ :documents ]
      @document_list.merge! options[ :documents ] #Array
      #TODO create index without line# or token#, or include line# and token# in the list.
    end

    if options[ :queries ]
      @query_list.merge! options[ :queries ]
    end

    if options[ :document_list ]
      @document_list.merge! tokenize_files_in_directory( options[ :document_list] ) #Directory
      @document_index.merge! index_files_in_directory( options[ :document_list] )
    end

    if options[ :query_list ]
      @query_list.merge! tokenize_files_in_directory( options[ :query_list ] )
    end

  end

  def run
    calculate_IDF_and_norms
    #process_queries
    #print_results
  end

  def tokenize_files_in_directory ( directory )
    list = Hash.new

    Dir.glob( directory + "/*" ).each do |filename|
      tokenize( filename ) do |token|
        list_token list, filename, token
      end
    end
    
    return list
  end

  def index_files_in_directory ( directory )
    index = Hash.new

    Dir.glob( directory + "/*" ).each do |filename|
      tokenize_with_indices( filename ) do |token, l_index, t_index|
        index_token index, token, filename, l_index, t_index
      end
    end

    return index
  end

  def calculate_IDF_and_norms
    @document_index.each do |word, o|
      @idf[ word ] =calculate_idf word
    end

    @document_list.each do |filename, h|
      document_norm filename
    end
  end

  def process_queries
    @accumulator    = Hash.new # { filename: value }
    @query_list.each do |q_file, query|
      q_norm = 0
      query.each do | question, count |
        @idf[ question ] = Math.log( 1 + @document_list.length ) unless @idf.key?( question )
      b =  ( count * @idf[ question ] )
        q_norm += b**2

        if @document_index.key? question
          @document_index[ question ].each do |filename, occurrences|
            a = @document_list[ filename ][ question ] * @idf[ question ]
            if @accumulator.key? filename
              @accumulator[ filename ] += a * b
            else
              @accumulator[ filename ] = a * b
            end
          end
        end
      end
      q_norm = Math.sqrt q_norm
      # TODO Norm berechnen
      #SEVI ISCH SOWAS VO OBERKRASS, WAS FÜR EN RAIM#
      # TODO query und accu zu Resultaten hinzufügen
    end
  end

  def print_results

  end

  def tokenize( filename )
    File.open( filename ).to_a.each do |line|
      line.split.each do |token|
        yield token
      end
    end
  end

  def tokenize_with_indices( filename )
    File.open( filename ).to_a.each_with_index do |line, l_index|
      line.split.each_with_index do |token, t_index|
        yield( token, l_index, t_index )
      end
    end
  end

  def index_token( index, token, filename, line_number, token_number )
    if index.key? token
      if index[ token ].key? filename
        index[ token ][ filename ] << [ line_number, token_number ]
      else
        index[ token ][ filename ] = Array.new
        index[ token ][ filename ] << [ line_number, token_number ]
      end
    else
      index[ token ] = Hash.new
      index[ token ][ filename ] = Array.new
      index[ token ][ filename ] << [ line_number, token_number ]
    end
  end

  def list_token( list, filename, token)
    if list.key? filename
      if list[ filename ].key? token
        list[ filename ][ token ] += 1
      else
        list[ filename ][ token ] = 1
      end
    else
      list[ filename ] = Hash.new
    end
  end

  def calculate_idf( word )
    Math.log( (1+@document_list.length) / (1+@document_index[ word ].length) )
  end

  def document_norm( filename )
    @document_list[ filename ].each do | word, occurrences|
      a = occurrences * @idf[ word ]
      if @document_norm.key? filename
        @document_norm[ filename ] += a**2
      else
        @document_norm[ filename ] = a**2
      end
    end

    @document_norm[ filename ] = Math.sqrt @document_norm[ filename ]
  end
end


if __FILE__ == $PROGRAM_NAME
  m = MiniRetrieve.new
  m.run
end
