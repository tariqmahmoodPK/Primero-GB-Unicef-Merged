# 'Community based Child Protection Committees'

# TODO Add the stats format
# Received Stats Format:
# {
#
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
