# 'Registered and Closed Cases by Month'

# Received Stats Format:
# {
#   "Resolved"=> {
#     "Jan"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Feb"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Mar"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Apr"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "May"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Jun"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Jul"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Aug"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Sep"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Oct"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Nov"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Dec"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0}
#   },
#   "Registered"=> {
#     "Jan"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Feb"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Mar"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Apr"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "May"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Jun"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Jul"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Aug"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Sep"=>{"male"=>1, "female"=>0, "transgender"=>0, "total"=>1},
#     "Oct"=>{"male"=>3, "female"=>1, "transgender"=>0, "total"=>4},
#     "Nov"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0},
#     "Dec"=>{"male"=>0, "female"=>0, "transgender"=>0, "total"=>0}
#   }
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
