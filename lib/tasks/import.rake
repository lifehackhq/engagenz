namespace :import do
  task :far_north => :environment do
    region_name = "Far North"
    region = Region.find_by_name(region_name) || Region.create(name: region)

    file = open_file("#{region_name.downcase.gsub(' ', '_')}.txt")
    text = file.read

    parse_and_create_providers(text, region)

    file.close
  end

  task :import_all => :environment do
    file = open_file("import.txt")
    text = file.read

    parse_and_create_providers(text)

    file.close
  end

end

def parse_and_create_providers(text, region=nil)
  lines = text.split("\n")

  provider_line = 0
  # p = Provider.new(region_id: region.id)

  @log = File.open('log/import_errors.txt', 'w+')

  lines.each_with_index do |line, i|
    if is_a_region_title?(line)
      region_name = line.scan(/[a-zA-z]+\s*[a-zA-z\s]*[a-zA-z]+/).first.titlecase
      @region = Region.find_by_name(region_name) || Region.create(name: region_name)
      provider_line = -1
    end

    if line.empty?
      # p p
      if @p.present?
        begin
          @p.save
        rescue => e
          @log << e.message
          @log << "\n"
          @log << "#{@p.inspect}\n"
          @log << e.backtrace
          @log << "\n\n"
        end
      end

      @p = Provider.new(region_id: @region.id)
      provider_line = -1
    end

    case provider_line
    when -1
      #skip
    when 0
      printf "-----------------------------\n"
      printf "%3s %15s:  \e[32m%s\e[0m\n" % [provider_line, 'name', line]
      if line.length > 100
        @p.name = line.split(':').first
        @p.description = line.split(':')[1..-1].join(':') + ' '
      else
        @p.name = line
      end
    else
      if is_an_email?(line)
        nice_print(provider_line, "email", line)
        @p.email += line + ' '
      elsif is_an_address?(line)
        nice_print(provider_line, "address", line)
        @p.address += line + ' '
      elsif is_a_phone_number?(line)
        nice_print(provider_line, "phone_number", line)
        @p.phone_number += line + ' '
      elsif is_a_website?(line)
        nice_print(provider_line, "website", line)
        @p.website += line + ' '
      else
        nice_print(provider_line, "description", line)
        @p.description += line + ' '
      end
    end

    provider_line += 1
  end
  @log.close
end

def open_file(filename)
  File.open("lib/assets/#{filename}")
end

def is_an_address?(string)
  string.scan(/^[0-9]+[\s0-9a-zA-Z]*\s[a-zA-z]+/).present?
end

def is_a_phone_number?(string)
  string.scan(/\(?[0-9\s]+\)?[0-9\s]{6,}$/).present?
end

def is_an_email?(string)
  string.scan(/^\s*[a-zA-Z0-9\_\-\.]+@[a-zA-Z0-9\_\-\.]+\s*$/).present?
end

def is_a_website?(string)
  string.scan(/(http|www)/).present?
end

def is_a_region_title?(string)
  string.scan(/^#\s?[a-zA-z]+/).present?
end

def nice_print(provider_line, title, line)
  printf "%3s %15s:  %s\n" % [provider_line, title, line]
end



