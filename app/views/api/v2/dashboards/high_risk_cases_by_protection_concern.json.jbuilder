# 'High Risk Cases by Protection Concern'

# Received Stats Format:
# {
#   "Violence" =>            {:cases => 0, :percentage => 0},
#   "Exploitation" =>        {:cases => 0, :percentage => 0},
#   "Neglect" =>             {:cases => 0, :percentage => 0},
#   "Harmful practice(s)" => {:cases => 0, :percentage => 0},
#   "Abuse" =>               {:cases => 0, :percentage => 0},
#   "Other" =>               {:cases => 0, :percentage => 0}
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
