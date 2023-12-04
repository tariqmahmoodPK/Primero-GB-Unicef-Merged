# 'Cases Referrals (To Agency)'

# Received Stats Format:
# {
#   "Directorate of Prosecution"                    => { :male => 0, :female => 0, :transgender => 0},
#   "UNICEF"                                        => { :male => 0, :female => 0, :transgender => 0},
#   "Pakistan Bait-ul-Maal"                         => { :male => 0, :female => 0, :transgender => 0},
#   "Zamung Kor"                                    => { :male => 0, :female => 0, :transgender => 0},
#   "Police"                                        => { :male => 0, :female => 0, :transgender => 0},
#   "Health Department"                             => { :male => 0, :female => 0, :transgender => 0},
#   "Elementary and Secondary Education Department" => { :male => 0, :female => 0, :transgender => 0},
#   "Labour Department"                             => { :male => 0, :female => 0, :transgender => 0},
#   "Federal Investigation Agency"                  => { :male => 0, :female => 0, :transgender => 0},
#   "Local Government Department"                   => { :male => 0, :female => 0, :transgender => 0},
#   "Aghosh Home (Al-Khidmat Foundation)"           => { :male => 0, :female => 0, :transgender => 0},
#   "Bait-Ul-Yatama"                                => { :male => 1, :female => 0, :transgender => 0},
#   "Zakat and Ushr Department"                     => { :male => 0, :female => 0, :transgender => 0},
#   "Social Welfare Department"                     => { :male => 0, :female => 0, :transgender => 0}
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
