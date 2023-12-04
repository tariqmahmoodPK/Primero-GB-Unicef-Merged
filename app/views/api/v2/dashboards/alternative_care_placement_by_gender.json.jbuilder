# 'Cases requiring Alternative Care Placement Services'

# Received Stats Format
# {
#   "Pakistani" => {:male=>0, :female=>0, :transgender=>0},
#   "Afghan"    => {:male=>0, :female=>0, :transgender=>0},
#   "Iranian"   => {:male=>0, :female=>0, :transgender=>0},
#   "Other"     => {:male=>0, :female=>0, :transgender=>0},
# }

json.data do
  @stats.each do |key, value|
    if key.to_s.eql?("permission")
      json.set!(key, value)
    else
      json.stats do
        json.set!(key, value)
      end
    end
  end
end
