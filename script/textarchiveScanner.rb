[
	'rubygems',
	'open-uri',
	'nokogiri',
	'sequel',
	'csv'
].each{|g|
	require g
}

DB = Sequel.sqlite('../datafiles/defendant_names.db')

DB.create_table? :defendants do 
	primary_key :row_id
	String :defendant
	Integer :num_matches
	String :search_result_url
	Date :scan_date
end
defendants = DB[:defendants]

today_date = (Time.now).strftime("%Y-%m-%d")

File.open("../datafiles/defendants_"+today_date+".csv","w"){|f|
	headers = [
		"Defendant",
		"Number of matches",
		"Search results URL"
	].join("\t")

	f.puts(headers)
	
	CSV.read("../datafiles/Court Calendar.csv")[4..-1].map{|row|
		if(row[4]!=nil)
			name_arr = row[4].split(',')
			first_name = name_arr[1].split(' ')[0]
			middle_name = name_arr[1].split(' ')[1] === nil ? '' : name_arr[1].split(' ')[1]
			last_name = name_arr[0]

			first_last = first_name+' '+last_name

			url = 'http://nl.newsbank.com/nl-search/we/Archives?p_product=PBPB&p_theme=pbpb&p_action=search&p_maxdocs=200&s_hidethis=no&p_field_label-0=Author&p_field_label-1=title&p_bool_label-1=AND&s_dispstring=%22'+first_name+'%20'+last_name+'%22%20AND%20date%2801/01/1989%20to%2012/31/2014%29&p_field_date-0=YMD_date&p_params_date-0=date:B,E&p_text_date-0=01/01/1989%20to%2012/31/2014%29&p_field_advanced-0=&p_text_advanced-0=%28%22'+first_name+'%20'+last_name+'%22%29&xcal_numdocs=40&p_perpage=20&p_sort=YMD_date:D&xcal_useweights=no'

			page = Nokogiri::HTML(open(url))
			p = page.css('p[style="font-size:0.917em"]')[1] # The tag which has the number of results
			num_matches = p.text.strip.scan(/\d{1,}/)[1].to_i

			match_arr = [first_last, num_matches, url]
			
			defendants.insert(
				:defendant => first_last,
				:num_matches => num_matches,
				:search_result_url => url,
				:scan_date =>  today_date
			)

			f.puts(match_arr.to_csv)
			p match_arr
		end
	}
}



