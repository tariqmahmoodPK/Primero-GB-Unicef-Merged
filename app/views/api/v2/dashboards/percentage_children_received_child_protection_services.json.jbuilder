# 'Percentage of Children who received Child Protection Services'

# Stats Format

# @stats =  {
#   violence: {
#     cases:      stats[:violence][:cases],
#     percentage: stats[:violence][:percentage]
#   },
#   exploitation: {
#     cases:      stats[:exploitation][:cases],
#     percentage: stats[:exploitation][:percentage]
#   },
#   neglect: {
#     cases:      stats[:neglect][:cases],
#     percentage: stats[:neglect][:percentage]
#   },
#   harmful_practices: {
#     cases:      stats[:harmful_practices ][:cases],
#     percentage: stats[:harmful_practices ][:percentage]
#   },
#   abuse: {
#     cases:      stats[:abuse][:cases],
#     percentage: stats[:abuse][:percentage]
#   },
#   other: {
#     cases:      stats[:other][:cases],
#     percentage: stats[:other][:percentage]
#   },
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
