#!/usr/bin/env ruby

require 'rake'

module Default
  QUERY_DIRECTORY = "queries"
  DOCUMENT_DIRECTORY = "documents"
end

class MiniRetrieve
  def initialize
    @query_list = Hash.new # { filename: { term: count } }
    @document_list = Hash.new # { filename: { term: count } }
    @document_index = Hash.new # { term: { filename: [[line#, token#], ... ] } }
  end

  def run
    create_query_list
    create_documents_lists
    puts @document_list
    #calculate_IDF_and_norms
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

    puts @document_index
  end

  def calculate_IDF_and_norms

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
end


if __FILE__ == $PROGRAM_NAME
  m = MiniRetrieve.new
  m.run
end
