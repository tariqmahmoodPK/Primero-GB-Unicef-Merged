# 'Cases Source'

# TODO Add the stats format
# Received Stats Format:
# @stats = {
#   "Helpline"=>0,
#   "Police"=>0,
#   "KPCPWC-CPUs"=>0,
#   "Walk-in"=>0,
#   "Social media"=>0,
#   "Pakistan Citizen Portal"=>0,
#   "Referred by District CP"=>0,
#   "Other Province"=>0,
#   "Other District"=>0,
#   "Newspaper"=>0,
#   "Child Protection Court"=>0,
#   "District Vigilance"=>0,
#   "Other CPU"=>0,
#   "Other"=>0
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
