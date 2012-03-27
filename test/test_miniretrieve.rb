require 'test_helper'

class TestMiniRetrieve < MiniTest::Unit::TestCase
  def setup
    @m = MiniRetrieve.new( {:document_list => "../documents", :query_list => "../queries"} )
  end

  def test_initialize
    refute @m.document_list, {}
  end

end
