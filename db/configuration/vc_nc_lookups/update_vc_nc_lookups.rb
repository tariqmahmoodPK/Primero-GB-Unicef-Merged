require 'simple_xlsx_reader'

ENV['PRIMERO_BOOTSTRAP'] = 'true'
ActiveJob::Base.queue_adapter = :async

def read_lookups_from_xlsx_file
  # Load the Excel file using simple_xlsx_reader
  xlsx_file_path = Rails.root.join('tmp', 'Tehsil VC NC.xlsx')
  xlsx = SimpleXlsxReader.open(xlsx_file_path)

  # Specify the sheet name containing the data
  sheet_name = 0 # First Sheet

  # Find the index of the 'Tehsil VC NC' column in the header row
  tehsil_vc_nc_index = xlsx.sheets[sheet_name].rows.first.index('Tehsil VC NC')

  # Initialize an empty array to store lookup entries
  lookup_entries = []

  skipped_first_row = false

  skipped_rows = 0
  total_lookup_entries = 0
  total_rows = 1

  puts "Lookups Read:"
  puts "============================================================================================================="

  # Iterate through each row in the specified sheet
  xlsx.sheets[sheet_name].rows.each do |row|
    # Skip Heading Row
    if !skipped_first_row
      skipped_first_row = true
      next # Skip the first row (header)
    end

    display_name = row[tehsil_vc_nc_index]

    # Skip rows with empty display names
    if display_name.nil? || display_name.empty?
      skipped_rows = skipped_rows + 1
    end

    # Convert the display name to the lookup entry format
    parts = display_name.split(' : ')
    id_parts = parts.map { |part| part.downcase.gsub(/[^a-z]+/, '_') }
    id = id_parts.join('___') + '_5131c80' # Append "_5131c80" to the id

    lookup_entry = {
      id: id,
      disabled: false,
      display_text: {
        en: display_name
      }
    }

    lookup_entries << lookup_entry
    total_lookup_entries = total_lookup_entries + 1

    puts "Row Number:                #{total_rows}"
    puts "LookUp Entry Number:      #{total_lookup_entries}"
    puts "Display Name:            \"#{display_name}\""
    puts "Id:                      \"#{id}\""
    puts "LookUp Entry:             #{lookup_entry}"

    total_rows = total_rows + 1

    puts "------------------------------------------------------------------------------------------"
  end

  puts "\n"
  puts "Total xlsx File Rows   = #{total_rows}"
  puts "Total LookUp Entries   = #{total_lookup_entries}"
  puts "Skipped Lookup entries = #{skipped_rows}"

  puts "============================================================================================================="

  lookup_entries
end

# -------------------------------------------------------------------------------------------------------------------------------------------------
  # Tehsil VC NC - Column Explaination with and Example
    # For Each Lookup entry we have:
      # Tehsil
      # Village Council
      # Neighbourhood Council
    # It's Display Name is formed as such:
      # Tehsil : Village Council : Neighbourhood Council
    # It's id is formed as such:
      # <Tehsil>:<Village Council>_<Village Council's number of Is>:<Neighbourhood Council>_<Neighbourhood Council's number of Is>_5131c80
    #
    # For Example:
      # Tehsil = Abbottabad
      # Village Council = Dalola-I
      # Neighbourhood Council = Malik Pura Urban-I
      #
      # 'id' Would be as follows:
        # "abbottabad___dalola_i___malik_pura_urban_i_5131c80"
      # Display Name would be as follows:
        # "Abbottabad : Dalola-I : Malik Pura Urban-I"
      #
      # ___ (Three underscores) is equal to ':' and vice versa.
      # Number of Capital 'I's is equal to the number of small 'i's.
    #
    # If given Display Name
      # "Abbottabad : Dalola-I : Malik Pura Urban-I"
      # Then Id can be gotten like this:
      # <Tehsil>___<Village Council>_<Village Council's number of Is>___<Neighbourhood Council>_<Neighbourhood Council's number of Is>_5131c80
      # If some part is not given then it is simply not added in the id.
# -------------------------------------------------------------------------------------------------------------------------------------------------

# Update the 'Village Council and Neighbourhood Council' Field
vc_nc_lookup = Lookup.find_by(unique_id: 'lookup-tehsil-vc-nc-fdef114')

new_values_en = read_lookups_from_xlsx_file

if vc_nc_lookup
  vc_nc_lookup.lookup_values_i18n = new_values_en
  vc_nc_lookup.save!
end

puts "\nLookup Entires for VC NC Updated"
puts "============================================================================================================="
