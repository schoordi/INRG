Use like this:
    
    irb
    require Dir.pwd+'/lib/miniretrieve'
    m = MiniRetrieve.new( {:document_list => "documents", :query_list => "queries"} )
    m.run
