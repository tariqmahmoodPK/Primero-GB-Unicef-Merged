# 'Registered Cases by Protection Concern'

# Received Stats Format:
# {
#   "Violence" =>            { male: 0, female: 0, transgender: 0 },
#   "Exploitation" =>        { male: 0, female: 0, transgender: 0 },
#   "Neglect" =>             { male: 0, female: 0, transgender: 0 },
#   "Harmful practice(s)" => { male: 0, female: 0, transgender: 0 },
#   "Abuse" =>               { male: 0, female: 0, transgender: 0 },
#   "Other" =>               { male: 0, female: 0, transgender: 0 }
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
