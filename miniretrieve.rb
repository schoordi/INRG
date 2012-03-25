#!/usr/bin/env ruby

module Default
  QUERY_DIRECTORY = "queries"
  DOCUMENT_DIRECTORY = "documents"
end

class MiniRetrieve
  attr_reader :query_list, :document_list, :document_index, :accumulator, :document_norm, :idf
  def initialize
    @query_list     = Hash.new # { filename: { term: count } }
    @document_list  = Hash.new # { filename: { term: count } }
    @document_index = Hash.new # { term: { filename: [[line#, token#], ... ] } }
    @accumulator    = Hash.new # { filename: value }
    @idf            = Hash.new # { term: value } inverse document frequency
    @document_norm  = Hash.new 0.0 # { filename: value }
  end

  def run
    create_query_list
    create_documents_lists
    calculate_IDF_and_norms
    print @document_norm
    #process_queries
    #print_results
  end

  def create_query_list ( options = {} )
    queries = options[:directory] || Default::QUERY_DIRECTORY

    Dir.glob(queries+"/*").each do |filename|
      tokenize( filename ) do |token|
        list_token @query_list, filename, token
      end
    end
  end

  def create_documents_lists ( options = {} )
    documents = options[:directory] || Default::DOCUMENT_DIRECTORY

    Dir.glob(documents+"/*").each do |filename|
      tokenize_with_indices( filename ) do |token, l_index, t_index|
        index_token @document_index, token, filename, l_index, t_index
        list_token @document_list, filename, token
      end
    end
  end

  def calculate_IDF_and_norms
    @document_index.each do |term, o|
      @idf[ term ] = idf( @document_list.length, document_frequency(term) )
    end

    @document_list.each do |filename, h|
      document_norm filename
    end
  end

  def process_queries

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

  def idf( document_count, document_frequency )
    Math.log( (1+document_count) / (1+document_frequency) )
  end

  def document_frequency( word )
    frequency = 0

    @document_index[ word ].each do |doc, index|
      frequency += index.length
    end

    frequency
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
