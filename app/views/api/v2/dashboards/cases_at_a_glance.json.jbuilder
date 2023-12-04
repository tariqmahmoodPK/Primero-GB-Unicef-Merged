# 'Cases at a Glance'

# TODO Add the stats format
# Received Stats Format:
# @stats => {
#   "Registered"        => 1,
#   "Pakistani"         => 0,
#   "Other Nationality" => 0,
#   "High"              => 0,
#   "Medium"            => 0,
#   "Low"               => 0,
#   "Closed Cases"      => 0,
#   "Assigned to Me"    => 0
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
