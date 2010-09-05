class String
  def to_filename
    gsub /\W+/, '_'
  end
end