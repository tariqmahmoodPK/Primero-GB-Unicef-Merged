# 'Closed Cases by Sex and Reason'

# Received Stats Format
# @stats = {
#   "Case goals all met"      => {:male=>0, :female=>0, :transgender=>0},
#   "Case goals substantially met and there is no further child protection concern" => {:male=>0, :female=>0, :transgender=>0},
#   "Child reached adulthood" => {:male=>0, :female=>0, :transgender=>0},
#   "Child refuses services"  => {:male=>0, :female=>0, :transgender=>0},
#   "Safety of child"         => {:male=>0, :female=>0, :transgender=>0},
#   "Death of child"          => {:male=>0, :female=>0, :transgender=>0},
#   "Other"                   => {:male=>0, :female=>0, :transgender=>0}
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
