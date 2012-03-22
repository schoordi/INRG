#!/usr/bin/env ruby

class MiniRetrieve
  def run
    create_query_hash(query_directory);
    create_indices(document_directory);
    calculate_IDF_and_norms();
  end
end


if __FILE__ == $PROGRAM_NAME
  m = MiniRetrieve.new
  m.run
end
